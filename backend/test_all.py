import asyncio
import os
from dotenv import load_dotenv
import requests
import json
import sys

# 添加正确的项目根目录到Python路径
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(root_dir)

from meditation_app.meditation_backend.config.app_config import AppConfig

# 加载环境变量
load_dotenv()

async def test_all():
    """运行所有测试"""
    try:
        # 1. 测试LLM API
        print("\n=== 测试LLM API ===")
        text = await test_llm_api()
        print(f"生成的文本: {text[:100]}...")

        # 2. 测试TTS API
        print("\n=== 测试TTS API ===")
        audio_path = await test_tts_api(text)
        print(f"生成的音频: {audio_path}")

        print("\n所有测试通过!")
        return True

    except Exception as e:
        print(f"\n测试失败: {e}")
        return False

async def test_llm_api():
    """测试LLM API"""
    url = "https://api.openai-hk.com/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {os.getenv('OPENAI_API_KEY')}"
    }
    
    data = {
        "max_tokens": 1200,
        "model": "gpt-3.5-turbo",
        "temperature": 0.8,
        "messages": [
            {
                "role": "system",
                "content": "你是一位专业的冥想引导师。"
            },
            {
                "role": "user",
                "content": "生成一段2分钟的冥想文本，主题是放松。"
            }
        ]
    }

    response = requests.post(url, headers=headers, json=data)
    if response.status_code != 200:
        raise Exception(f"LLM API调用失败: {response.status_code}")
    
    return response.json()['choices'][0]['message']['content']

async def test_tts_api(text: str):
    """测试TTS API"""
    print("\n=== 测试TTS API ===")
    response = requests.post(
        f"http://{AppConfig.SOVITS_HOST}:{AppConfig.SOVITS_PORT}",
        json={
            "text": text,
            **AppConfig.TTS_CONFIG
        }
    )
    
    if response.status_code != 200:
        raise Exception(f"TTS API调用失败: {response.status_code}")
        
    # 保存测试音频
    audio_path = "test_output.wav"
    with open(audio_path, "wb") as f:
        f.write(response.content)
        
    print(f"测试音频已保存: {audio_path}")
    return audio_path

if __name__ == "__main__":
    asyncio.run(test_all()) 