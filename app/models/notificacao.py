from sqlmodel import SQLModel, Field
from datetime import datetime
from typing import Optional
import uuid
from uuid import UUID

class Notificacao(SQLModel, table=True):
    id: UUID = Field(
        default_factory=uuid.uuid4,
        primary_key=True
    )
    peca_id: UUID = Field(foreign_key="peca.id", index=True)
    cliente_id: UUID = Field(foreign_key="cliente.id", index=True)
    data_envio: datetime = Field(default_factory=datetime.now, index=True)
    status: str = Field(default="processando")
    mensagem: str
    erro_detalhe: Optional[str] = None