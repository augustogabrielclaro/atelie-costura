from sqlmodel import SQLModel, Field
from datetime import datetime
import uuid
from uuid import UUID


class Cliente(SQLModel, table=True):
    id: UUID = Field(
        default_factory=uuid.uuid4,
        primary_key=True,
        index=True,
        nullable=False
    )
    nome: str
    telefone: str = Field(index=True)
    data_cadastro: datetime = Field(default_factory=datetime.now)
    ativo: bool = Field(default=True)


