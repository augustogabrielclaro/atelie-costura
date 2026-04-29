from sqlmodel import SQLModel, Field
from datetime import date
import uuid
from uuid import UUID
from typing import Optional

class Peca(SQLModel, table=True):
    id: UUID = Field(
        default_factory=uuid.uuid4,
        primary_key=True,
        index=True,
        nullable=False
    )
    descricao: str
    status: str = Field(default="Pendente")
    valor: float = Field(default=0.0)
    data_entrega: date = Field(index=True)
    cliente_id: UUID = Field(foreign_key="cliente.id")