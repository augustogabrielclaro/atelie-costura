from sqlmodel import Session
from models.peca import Peca
from uuid import UUID

class PecaRepository:
    def __init__(self, session: Session):
        self.session = session

    def create(self, peca: Peca) -> Peca:
        self.session.add(peca)
        self.session.commit()
        self.session.refresh(peca)
        return peca