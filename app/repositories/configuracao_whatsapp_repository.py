from sqlmodel import Session, select
from models.configuracao_whatsapp import ConfiguracaoWhatsapp 
from typing import Optional

class ConfiguracaoWhatsappRepository:
    def __init__(self, session: Session):
        self.session = session

    def get(self) -> Optional[ConfiguracaoWhatsapp]:
        statement = select(ConfiguracaoWhatsapp)

        return self.session.exec(statement).first()

    def save(self, configuracao: ConfiguracaoWhatsapp) -> ConfiguracaoWhatsapp:
        self.session.add(configuracao)
        self.session.commit()
        self.session.refresh(configuracao)

        return configuracao