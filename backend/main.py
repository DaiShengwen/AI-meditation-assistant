from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import requests
from pathlib import Path
import json
from config.app_config import AppConfig
import asyncio
import wave
import io

app = FastAPI()

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def split_text(text):
    """按标点符号切分文本"""
    segments = []
    current = []
    
    for char in text:
        current.append(char)
        if char in ['。', '，', '；', '！', '？', '\n']:
            segments.append(''.join(current))
            current = []
    
    if current:
        segments.append(''.join(current))
    
    return segments

def merge_wav_files(wav_contents):
    """合并多个WAV文件内容"""
    output = io.BytesIO()
    
    with wave.open(output, 'wb') as outfile:
        first = True
        for content in wav_contents:
            with io.BytesIO(content) as f:
                with wave.open(f, 'rb') as infile:
                    if first:
                        outfile.setparams(infile.getparams())
                        first = False
                    outfile.writeframes(infile.readframes(infile.getnframes()))
    
    return output.getvalue()

@app.post("/api/meditate")
async def generate_meditation(request: dict):
    try:
        print("\n=== 收到冥想生成请求 ===")
        print(f"用户心情: {request.get('moods')}")
        print(f"补充描述: {request.get('description')}")
        
        # 1. 调用LLM生成文本
        print("\n=== 开始调用LLM API ===")
        llm_response = await call_llm_api(request)
        meditation_text = llm_response['choices'][0]['message']['content']
        print(f"生成的文本长度: {len(meditation_text)}字")
        print(f"文本内容:\n{meditation_text}\n")
        
        # 2. 调用TTS生成音频
        print("\n=== 开始调用TTS服务 ===")
        print(f"TTS服务地址: http://{AppConfig.SOVITS_HOST}:{AppConfig.SOVITS_PORT}")
        
        max_retries = 3
        retry_count = 0
        while retry_count < max_retries:
            try:
                print(f"\n尝试调用TTS服务 (第{retry_count + 1}次)")
                response = requests.post(
                    f"http://{AppConfig.SOVITS_HOST}:{AppConfig.SOVITS_PORT}",
                    json={
                        "text": meditation_text,
                        "cut_punc": "，。",  # 添加切分标点
                        **AppConfig.TTS_CONFIG
                    },
                    timeout=180
                )
                print(f"TTS响应状态码: {response.status_code}")
                
                if response.status_code == 200:
                    break
                else:
                    raise Exception(f"TTS服务返回错误: {response.status_code}")
                    
            except requests.exceptions.Timeout:
                retry_count += 1
                if retry_count == max_retries:
                    print("TTS服务多次超时，放弃重试")
                    raise HTTPException(
                        status_code=500,
                        detail="TTS服务响应超时，请稍后重试"
                    )
                print(f"TTS服务超时，{max_retries - retry_count}秒后重试...")
                await asyncio.sleep(3)
                
            except requests.exceptions.RequestException as e:
                print(f"TTS服务连接失败: {str(e)}")
                raise HTTPException(
                    status_code=500,
                    detail=f"TTS服务连接失败: {str(e)}"
                )
        
        # 3. 保存音频文件
        print("\n=== 保存音频文件 ===")
        audio_path = Path(AppConfig.AUDIO_CACHE_DIR) / f"{hash(meditation_text)}.wav"
        with open(audio_path, "wb") as f:
            f.write(response.content)
        print(f"文件大小: {len(response.content)/1024:.2f} KB")
        print(f"保存路径: {audio_path}")
        
        print("\n=== 请求处理完成 ===")
        return JSONResponse(
            content={
                "status": "success",
                "data": {
                    "text": meditation_text,
                    "audio_url": f"/audio/{audio_path.name}"
                }
            },
            headers={
                "Content-Type": "application/json; charset=utf-8"
            }
        )

    except Exception as e:
        print(f"\n=== 处理请求时出错 ===")
        print(f"错误信息: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

async def call_llm_api(request: dict):
    print("\n=== 准备调用LLM API ===")
    print(f"API基础地址: {AppConfig.OPENAI_API_BASE}")
    print(f"API Key是否设置: {'是' if AppConfig.OPENAI_API_KEY else '否'}")
    
    url = AppConfig.OPENAI_API_BASE + "/chat/completions"
    headers = {
        "Authorization": f"Bearer {AppConfig.OPENAI_API_KEY}"
    }
    
    data = {
        "model": "gpt-3.5-turbo",
        "messages": [
            {
                "role": "system",
                "content": "你是一位专业的冥想引导师。"
            },
            {
                "role": "user",
                "content": f"生成一段50字的冥想文本。用户的情绪是：{request.get('moods')}。{request.get('description')}"
            }
        ]
    }
    
    try:
        print(f"发送请求到: {url}")
        response = requests.post(url, headers=headers, json=data)
        print(f"LLM响应状态码: {response.status_code}")
        
        if response.status_code != 200:
            error_detail = response.json().get('error', {}).get('message', '未知错误')
            print(f"LLM返回错误: {error_detail}")
            raise Exception(f"LLM API调用失败: {error_detail}")
            
        result = response.json()
        print("LLM调用成功")
        return result
        
    except requests.exceptions.RequestException as e:
        print(f"LLM请求异常: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"LLM服务连接失败: {str(e)}"
        )

@app.get("/audio/{filename}")
async def get_audio(filename: str):
    audio_path = Path(AppConfig.AUDIO_CACHE_DIR) / filename
    if not audio_path.exists():
        raise HTTPException(status_code=404, detail="音频文件不存在")
    return FileResponse(
        audio_path,
        media_type="audio/wav",
        headers={
            "Access-Control-Allow-Origin": "*",
            "Cache-Control": "no-cache"
        }
    )

if __name__ == "__main__":
    import uvicorn
    AppConfig.validate()
    uvicorn.run(app, host=AppConfig.HOST, port=AppConfig.PORT)
