from sqlmodel import Session, select
from models.peca import Peca
from models.cliente import Cliente
from uuid import UUID
from datetime import date
from typing import List, Tuple
from schemas.pedido import AllPecasOut

class PecaRepository:
    def __init__(self, session: Session):
        self.session = session

    def create(self, peca: Peca) -> Peca:
        self.session.add(peca)
        self.session.commit()
        self.session.refresh(peca)
        return peca

    def get_entregas_por_data(self, data_alvo: date) -> List[Peca]:
        statement = select(Peca).where(
            Peca.data_entrega == data_alvo,
            Peca.status == "Pendente"
        )
        return self.session.exec(statement).all()
    
    def get_all(self) -> List[AllPecasOut]:
        statement = select(Peca)
        peca_list = self.session.exec(statement).all()
        return peca_list
    
    def get_all_paginated(self, skip: int = 0, limit: int = 10, search: str = "") -> List[Tuple[Peca, str]]:
        statement = select(Peca, Cliente.nome).join(Cliente, Peca.cliente_id == Cliente.id)
        
        if search:
            statement = statement.where(
                (Peca.descricao.icontains(search)) | (Cliente.nome.icontains(search))
            )
            
        statement = statement.offset(skip).limit(limit)
        return self.session.exec(statement).all()