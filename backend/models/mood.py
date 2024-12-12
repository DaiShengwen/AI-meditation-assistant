from pydantic import BaseModel

class Mood(BaseModel):
    id: str
    name: str
    isSelected: bool = False 