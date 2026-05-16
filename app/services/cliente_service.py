import re
import uuid
from models.cliente import Cliente
from fastapi import HTTPException, status
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
        id: UUID,
        cliente_in: ClienteIn
    ) -> Cliente:
        cliente = self.repository.get_by_id(id)

        if cliente == None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Cliente não existente no banco de dados!"
            )

        update_data = cliente_in.model_dump(exclude_unset=True)

        if "telefone" in update_data:
            if self.repository.get_by_telefone(self.limpar_telefone(update_data["telefone"])) != None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Já existe um cliente ativo com esse telefone!"
                )
            update_data["telefone"] = self.limpar_telefone(update_data["telefone"])

        return self.repository.patch(cliente, update_data)