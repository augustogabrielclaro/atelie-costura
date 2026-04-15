import re
from models.cliente import Cliente
from repositories.cliente_repository import ClienteRepository
from uuid import UUID

class ClienteService:
    def __init__(self, repository: ClienteRepository):
        self.repository = repository

    def limpar_telefone(self, telefone: str) -> str:
        apenas_numeros = re.sub(r'\D', '', telefone)
        if len(apenas_numeros) == 11:
            return f"55{apenas_numeros}"
        return apenas_numeros

    def obter_ou_criar_cliente(self, nome: str, telefone: str) -> Cliente:
        tel_limpo = self.limpar_telefone(telefone)
        existente = self.repository.get_by_telefone(tel_limpo)
        
        if existente:
            return existente
            
        novo = Cliente(nome=nome, telefone=tel_limpo)
        return self.repository.create(novo)