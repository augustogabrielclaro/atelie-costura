from schemas.pedido import AllPecasOut, PecaOut
from repositories.peca_repository import PecaRepository
from services.cliente_service import ClienteService
from models.peca import Peca
from datetime import date
from typing import List

class PecaService:
    def __init__(self, peca_repo: PecaRepository, cliente_service: ClienteService):
        self.peca_repo = peca_repo
        self.cliente_service = cliente_service

    def cadastrar_pedido_completo(self, nome_cliente: str, telefone: str, descricao_peca: str, valor: float, data_entrega: date):
        cliente = self.cliente_service.obter_ou_criar_cliente(nome_cliente, telefone)
        
        nova_peca = Peca(
            descricao=descricao_peca,
            valor=valor,
            data_entrega=data_entrega,
            cliente_id=cliente.id
        )
        peca_salva = self.peca_repo.create(nova_peca)
        return PecaOut(
            id=peca_salva.id,
            descricao=peca_salva.descricao,
            status=peca_salva.status,
            valor=peca_salva.valor,
            data_entrega=peca_salva.data_entrega,
            cliente_id=peca_salva.cliente_id,
            cliente_nome=cliente.nome,
            cliente_telefone=cliente.telefone
        )

    def listar_entregas_do_dia(self, data_alvo: date) -> List[PecaOut]:
        pecas = self.peca_repo.get_entregas_por_data(data_alvo)
        res = []
        for peca in pecas:
            cliente = self.cliente_service.repository.get_by_id(peca.cliente_id)
            res.append(PecaOut(
                id=peca.id,
                descricao=peca.descricao,
                status=peca.status,
                valor=peca.valor,
                data_entrega=peca.data_entrega,
                cliente_id=peca.cliente_id,
                cliente_nome=cliente.nome if cliente else None,
                cliente_telefone=cliente.telefone if cliente else None
            ))
        return res
    
    def listar_todas_pecas(self, skip: int = 0, limit: int = 10, search: str = "") -> List[AllPecasOut]:
        resultados = self.peca_repo.get_all_paginated(skip=skip, limit=limit, search=search)
        
        return [AllPecasOut(
            descricao=peca.descricao,
            valor=peca.valor,
            data_entrega=peca.data_entrega,
            cliente_nome=cliente_nome
        ) for peca, cliente_nome in resultados]