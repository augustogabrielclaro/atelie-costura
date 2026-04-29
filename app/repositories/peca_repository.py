from sqlmodel import Session, select
from models.peca import Peca
from uuid import UUID
from datetime import date
from typing import List

class PecaRepository:
    def __init__(self, session: Session):
        self.session = session

    def create(self, peca: Peca) -> Peca:
        self.session.add(peca)
        self.session.commit()
        self.session.refresh(peca)
        return peca

    # Nova função para a automação do robô
    def get_entregas_por_data(self, data_alvo: date) -> List[Peca]:
        statement = select(Peca).where(
            Peca.data_entrega == data_alvo,
            Peca.status == "Pendente"
        )
        return self.session.exec(statement).all()