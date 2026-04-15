from sqlmodel import Session, select
from models.cliente import Cliente
from uuid import UUID

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
    
    def deactivate(self, cliente_id: UUID) -> bool:
        cliente = self.session.get(Cliente, cliente_id)
        if not cliente:
            return False
        
        cliente.ativo = False
        self.session.add(cliente)
        self.session.commit()
        return True