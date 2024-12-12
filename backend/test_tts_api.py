import requests
import os
from datetime import datetime

class TTSClient:
    def __init__(self, host="localhost", port=9880):
        """初始化TTS客户端
        
        Args:
            host: API服务器地址
            port: API服务器端口
        """
        self.base_url = f"http://{host}:{port}"
        
    def tts(self,
            text: str,
            output_dir: str = "outputs",
            refer_wav_path: str = "static/vocal1.wav_0000156800_0000330240.wav",
            prompt_text: str = "请你慢慢平躺下来，盖好被子",
            text_language: str = "zh",
            prompt_language: str = "zh",
            speed: float = 1.0,
            cut_punc: str = None  # 文本切分符号，由服务器处理
    ) -> str:
        """调用TTS API生成语音"""
        
        # 准备请求数据
        payload = {
            "text": text,
            "text_language": text_language,
            "refer_wav_path": refer_wav_path,
            "prompt_text": prompt_text,
            "prompt_language": prompt_language,
            "speed": speed
        }
        
        # 如果指定了切分符号，添加到请求中
        if cut_punc is not None:
            payload["cut_punc"] = cut_punc
            
        try:
            # 发送请求
            response = requests.post(
                f"{self.base_url}/",
                json=payload,
                stream=True
            )
            
            # 检查响应
            if response.status_code != 200:
                print(f"错误: {response.status_code}")
                print(response.text)
                return None
                
            # 创建输出目录
            os.makedirs(output_dir, exist_ok=True)
            
            # 生成输出文件名
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = os.path.join(output_dir, f"tts_{timestamp}.wav")
            
            # 保存音频文件
            with open(output_path, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
                    
            print(f"已生成音频: {output_path}")
            return output_path
            
        except Exception as e:
            print(f"请求失败: {str(e)}")
            return None

def main():
    # 创建客户端
    client = TTSClient(host="localhost", port=9880)
    
    # 测试文本
    test_text = """让我们开始今天的冥想。请找一个舒适的姿势坐下或躺下，轻轻闭上双眼。深深地吸一口气，然后缓缓地呼出来。感受你的呼吸，如同温柔的海浪，来来往往。让你的身体完全放松，从头顶开始，一直到脚尖。"""
    
    # 使用句号切分生成语音
    output_path = client.tts(
        text=test_text,
        output_dir="outputs",
        speed=1.0,
        cut_punc="。"  # 使用中文句号切分
    )
    
    if output_path:
        print(f"文本已转换为音频: {output_path}")
    else:
        print("转换失败")

if __name__ == "__main__":
    main()