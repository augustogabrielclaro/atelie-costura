from pydantic import BaseModel
from typing import Optional

class MessageRequest(BaseModel):
    to_phone: str
    text: str

class ConfiguracaoWhatsappCreate(BaseModel):
    telefone_envio: str
    waba_id: str | None = None
    access_token: str

class ConfiguracaoWhatsappUpdate(BaseModel):
    telefone_envio: str | None = None
    waba_id: str | None = None
    access_token: str | None = None

class ConfiguracaoWhatsappResponse(BaseModel):
    telefone_envio: str
    waba_id: str | None = None
    possui_token: bool