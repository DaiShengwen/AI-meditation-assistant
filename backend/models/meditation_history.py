from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field

class MeditationHistory(BaseModel):
    """冥想历史记录模型"""
    id: str = Field(..., description="历史记录ID")
    
    # 冥想内容
    text: str = Field(..., description="冥想文本内容")
    audio_url: str = Field(..., description="音频文件URL")
    
    # 用户输入
    moods: List[str] = Field(default_factory=list, description="选择的心情")
    description: Optional[str] = Field(None, description="用户描述")
    
    # 元数据
    title: Optional[str] = Field(None, max_length=100)
    created_at: datetime = Field(default_factory=datetime.now)
    duration: int = Field(default=300, description="冥想时长（秒）")
    
    # 用户交互
    is_favorite: bool = Field(default=False, description="是否收藏")
    play_count: int = Field(default=0, description="播放次数")
    last_played: Optional[datetime] = Field(None, description="最后播放时间")
    
    # 配置
    config: dict = Field(default_factory=dict, description="其他配置信息")

    class Config:
        json_schema_extra = {
            "example": {
                "id": "550e8400-e29b-41d4-a716-446655440000",
                "text": "让我们开始今天的冥想...",
                "audio_url": "/path/to/audio.mp3",
                "timestamp": "2024-03-21T12:00:00",
                "moods": ["平静", "专注"],
                "duration": 300,
                "title": "午后冥想",
                "is_favorite": False
            }
        }