from typing import Optional
from pathlib import Path
import hashlib
import sys
import os

# 添加正确的项目根目录到Python路径
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.append(root_dir)
from meditation_app.meditation_backend.config.app_config import AppConfig

class CacheService:
    def __init__(self):
        self.audio_cache_dir = Path(AppConfig.AUDIO_CACHE_DIR)
        self.text_cache_dir = Path(AppConfig.TEXT_CACHE_DIR)
        
        # 创建缓存目录
        self.audio_cache_dir.mkdir(parents=True, exist_ok=True)
        self.text_cache_dir.mkdir(parents=True, exist_ok=True)
    
    def _get_cache_key(self, text: str) -> str:
        """生成缓存键"""
        return hashlib.md5(text.encode()).hexdigest()
    
    def get_cached_audio(self, text: str) -> Optional[str]:
        """获取缓存的音频文件路径"""
        cache_key = self._get_cache_key(text)
        audio_path = self.audio_cache_dir / f"{cache_key}.wav"
        return str(audio_path) if audio_path.exists() else None
    
    def get_cached_text(self, text: str) -> Optional[str]:
        """获取缓存的文本"""
        cache_key = self._get_cache_key(text)
        text_path = self.text_cache_dir / f"{cache_key}.txt"
        return text_path.read_text() if text_path.exists() else None
    
    def cache_audio(self, text: str, audio_path: str) -> None:
        """缓存音频文件"""
        cache_key = self._get_cache_key(text)
        target_path = self.audio_cache_dir / f"{cache_key}.wav"
        Path(audio_path).rename(target_path)
    
    def cache_text(self, text: str, generated_text: str) -> None:
        """缓存生成的文本"""
        cache_key = self._get_cache_key(text)
        text_path = self.text_cache_dir / f"{cache_key}.txt"
        text_path.write_text(generated_text)
    
    def clear_cache(self) -> None:
        """清除所有缓存"""
        for file in self.audio_cache_dir.glob("*"):
            file.unlink()
        for file in self.text_cache_dir.glob("*"):
            file.unlink() 