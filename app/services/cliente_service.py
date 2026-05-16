import re
from models.cliente import Cliente
from repositories.cliente_repository import ClienteRepository
from uuid import UUID
from typing import Optional
from schemas.cliente import ClienteIn, ClienteOut

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
    
    def patch_cliente(
        self,
        cliente_in: ClienteIn
    ) -> Cliente:
        cliente = self.repository.get_by_id(cliente_in.id)

        if cliente == None:
            raise Exception("Cliente não existente no banco de dados")

        cliente.nome = cliente_in.nome if cliente_in.nome != None else cliente.nome
        cliente.telefone = cliente_in.telefone if cliente_in.telefone != None else cliente.telefone
        cliente.ativo = cliente_in.ativo if cliente_in.ativo != None else cliente.ativo
        
        novo_cliente = self.repository.patch(cliente_in)

        return novo_cliente