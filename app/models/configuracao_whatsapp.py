from sqlmodel import SQLModel, Field
from datetime import datetime, timezone
from typing import Optional
from uuid import UUID
import uuid

class ConfiguracaoWhatsapp(SQLModel, table=True):
    __tablename__ = "configuracao_whatsapp"
    
    id: UUID = Field(
        primary_key=True, 
        index=True, 
        default_factory=uuid.uuid4,
        nullable=False
    )
    telefone_id: str = Field(max_length=20)
    waba_id: Optional[str] = Field(default=None, max_length=50)
    acess_token: bytes
    data_criacao: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    data_atualizacao: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))