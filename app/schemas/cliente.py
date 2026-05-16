from pydantic import BaseModel
import datetime
from typing import Optional
from uuid import UUID

class ClienteIn(BaseModel):
    id: UUID
    nome: Optional[str]
    telefone: Optional[str]
    ativo: Optional[bool]

class ClienteOut(BaseModel):
    id: UUID
    nome: str
    telefone: str
    data_cadastro: datetime.datetime
    ativo: bool