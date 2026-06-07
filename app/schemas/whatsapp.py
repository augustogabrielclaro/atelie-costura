from pydantic import BaseModel
from typing import Optional

class MessageRequest(BaseModel):
    to_phone: str
    text: str

class ConfiguracaoWhatsappCreate(BaseModel):
    telefone_id: str
    waba_id: str | None = None
    token: str

class ConfiguracaoWhatsappUpdate(BaseModel):
    telefone_id: str | None = None
    waba_id: str | None = None
    token: str | None = None

class ConfiguracaoWhatsappResponse(BaseModel):
    telefone_id: str
    waba_id: str | None = None
    possui_token: bool