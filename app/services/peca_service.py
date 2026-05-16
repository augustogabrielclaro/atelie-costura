from schemas.pedido import AllPecasOut
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
        return self.peca_repo.create(nova_peca)

    def listar_entregas_do_dia(self, data_alvo: date) -> List[Peca]:
        return self.peca_repo.get_entregas_por_data(data_alvo)
    
    def listar_todas_pecas(self) -> List[AllPecasOut]:
        pecas = self.peca_repo.get_all()
        return [AllPecasOut(
            descricao=peca.descricao,
            valor=peca.valor,
            data_entrega=peca.data_entrega,
            cliente_nome=self.cliente_service.repository.get_by_id(peca.cliente_id).nome
        ) for peca in pecas]