from datetime import datetime
from typing import List, Dict
import json
from pathlib import Path
from ..models.meditation_history import MeditationHistory
from ..config.app_config import AppConfig

class HistoryService:
    def __init__(self):
        self.history_file = Path(AppConfig.HISTORY_FILE)
        self.history_file.parent.mkdir(parents=True, exist_ok=True)
        
        if not self.history_file.exists():
            self.history_file.write_text("[]")

    def add_history(self, meditation_data: Dict) -> MeditationHistory:
        """添加新的冥想记录

        Args:
            meditation_data: 包含冥想信息的字典

        Returns:
            MeditationHistory: 新创建的历史记录
        """
        histories = self.get_histories()
        
        # 创建新的历史记录
        new_history = MeditationHistory(
            text=meditation_data["text"],
            audio_path=meditation_data["audioPath"],
            moods=meditation_data["moods"],
            duration_seconds=meditation_data["duration"],
            title=meditation_data.get("title"),  # 可选字段
            is_favorite=meditation_data.get("is_favorite", False)  # 可选字段
        )
        
        # 转换为字典并添加到列表
        history_dict = new_history.model_dump()
        histories.append(history_dict)
        
        # 保留最近100条记录
        if len(histories) > 100:
            histories = histories[-100:]
            
        # 保存到文件
        self.history_file.write_text(json.dumps(histories, ensure_ascii=False))
        
        return new_history

    def get_histories(self) -> List[Dict]:
        """获取所有历史记录"""
        try:
            data = json.loads(self.history_file.read_text())
            return [MeditationHistory(**item).model_dump() for item in data]
        except Exception as e:
            print(f"读取历史记录失败: {e}")
            return []

    def update_history(self, history_id: str, updates: Dict) -> MeditationHistory:
        """更新历史记录

        Args:
            history_id: 要更新的记录ID
            updates: 要更新的字段

        Returns:
            MeditationHistory: 更新后的记录
        """
        histories = self.get_histories()
        
        for i, history in enumerate(histories):
            if history["id"] == history_id:
                histories[i].update(updates)
                self.history_file.write_text(json.dumps(histories, ensure_ascii=False))
                return MeditationHistory(**histories[i])
                
        raise ValueError(f"未找到ID为{history_id}的记录")

    def toggle_favorite(self, history_id: str) -> bool:
        """切换收藏状态

        Args:
            history_id: 历史记录ID

        Returns:
            bool: 新的收藏状态
        """
        histories = self.get_histories()
        
        for i, history in enumerate(histories):
            if history["id"] == history_id:
                new_state = not history.get("is_favorite", False)
                histories[i]["is_favorite"] = new_state
                self.history_file.write_text(json.dumps(histories, ensure_ascii=False))
                return new_state
                
        raise ValueError(f"未找到ID为{history_id}的记录")

    def clear_history(self):
        """清除所有历史记录"""
        self.history_file.write_text("[]") 