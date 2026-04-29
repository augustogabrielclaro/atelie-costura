from pydantic import BaseModel
from datetime import date
from typing import Optional
from uuid import UUID

class PedidoCompletoIn(BaseModel):
    nome: str
    telefone: str
    descricao: str
    valor: float
    data_entrega: date

class PecaOut(BaseModel):
    id: UUID
    descricao: str
    status: str
    valor: float
    data_entrega: date
    cliente_id: UUID