from sqlmodel import Session, select
from models.cliente import Cliente
from uuid import UUID
from schemas.cliente import ClienteIn


class ClienteRepository:
    def __init__(self, session: Session):
        self.session = session

    def get_by_telefone(self, telefone: str) -> Cliente:
        statement = select(Cliente).where(
            Cliente.telefone == telefone, 
            Cliente.ativo == True
        )
        return self.session.exec(statement).first()

    def create(self, cliente: Cliente) -> Cliente:
        if self.get_by_telefone(cliente.telefone) != None:
            raise ValueError("Um cliente ativo já está cadastrado com esse telefone!")
        self.session.add(cliente)
        self.session.commit()
        self.session.refresh(cliente)
        return cliente

    def get_by_id(self, cliente_id: UUID) -> Cliente:
        return self.session.get(Cliente, cliente_id)
    
    def get_all(self) -> list[Cliente]:
        statement = select(Cliente)
        cliente_list = self.session.exec(statement).all()
        return cliente_list
    
    def get_all_ativos(self) -> list[Cliente]:
        statement = select(Cliente).where(Cliente.ativo == True)
        cliente_list = self.session.exec(statement).all()
        return cliente_list
    
    def get_all_ativos_paginated(self, skip: int = 0, limit: int = 10, search: str = "") -> list[Cliente]:
        statement = select(Cliente).where(Cliente.ativo == True)
        
        if search:
            statement = statement.where(
                (Cliente.nome.icontains(search)) | (Cliente.telefone.icontains(search))
            )
            
        statement = statement.offset(skip).limit(limit)
        return self.session.exec(statement).all()
    
    def deactivate(self, cliente_id: UUID) -> bool:
        cliente = self.session.get(Cliente, cliente_id)
        if not cliente:
            return False
        
        cliente.ativo = False
        self.session.add(cliente)
        self.session.commit()
        return True
    
    def patch(self, cliente: Cliente, update_data: dict) -> Cliente:
        for key, value in update_data.items():
            setattr(cliente, key, value)

        self.session.add(cliente)
        self.session.commit()
        self.session.refresh(cliente)
        return cliente