from pydantic import BaseModel
import datetime
from typing import Optional
from uuid import UUID

class ClienteIn(BaseModel):
    nome: Optional[str] = None
    telefone: Optional[str] = None
    ativo: Optional[bool]= None

class ClienteOut(BaseModel):
    id: UUID
    nome: str
    telefone: str
    data_cadastro: datetime.datetime
    ativo: bool