from repositories.peca_repository import PecaRepository
from services.cliente_service import ClienteService
from models.peca import Peca

class PecaService:
    def __init__(self, peca_repo: PecaRepository, cliente_service: ClienteService):
        self.peca_repo = peca_repo
        self.cliente_service = cliente_service

    def cadastrar_pedido_completo(self, nome_cliente: str, telefone: str, descricao_peca: str):
        cliente = self.cliente_service.obter_ou_criar_cliente(nome_cliente, telefone)
        
        nova_peca = Peca(
            descricao=descricao_peca,
            cliente_id=cliente.id
        )
        return self.peca_repo.create(nova_peca)