from pydantic import BaseModel

class MessageRequest(BaseModel):
    to_phone: str
    text: str