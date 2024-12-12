import os
from dotenv import load_dotenv
from pathlib import Path

# 加载环境变量
load_dotenv()

class AppConfig:
    # LLM配置
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
    OPENAI_API_BASE = "https://api.openai-hk.com/v1"
    
    # TTS配置
    SOVITS_HOST = "116.136.130.168"
    SOVITS_PORT = 32268
    
    # TTS参数
    TTS_CONFIG = {
        "text_language": "zh",
        "top_k": 15,
        "top_p": 0.6,
        "temperature": 0.6,
        "speed": 1.0
    }

    # 服务器配置
    HOST = "0.0.0.0"
    PORT = 8000

    # 缓存配置
    CACHE_DIR = "cache"
    AUDIO_CACHE_DIR = f"{CACHE_DIR}/audio"

    @classmethod
    def validate(cls):
        if not cls.OPENAI_API_KEY:
            raise ValueError("未设置OPENAI_API_KEY环境变量")
        Path(cls.AUDIO_CACHE_DIR).mkdir(parents=True, exist_ok=True)