from sqlmodel import SQLModel, Field
import uuid
from uuid import UUID

class Peca(SQLModel, table=True):
    id: UUID = Field(
        default_factory=uuid.uuid4,
        primary_key=True,
        index=True,
        nullable=False
    )
    descricao: str
    status: str = Field(default="Pendente")
    cliente_id: UUID = Field(foreign_key="cliente.id")