from pydantic import BaseModel
from datetime import date
from typing import Optional
from uuid import UUID

class NotificacaoIn(BaseModel):
    cliente_id: str
    peca_id: str

class NotificacaoOut(BaseModel):
    id: UUID
    nome_cliente: str
    mensagem: str