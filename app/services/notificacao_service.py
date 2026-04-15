from datetime import datetime
from repositories.notificacao_repository import NotificacaoRepository
from models.notificacao import Notificacao
from uuid import UUID

class NotificacaoService:
    def __init__(self, repo_notificacao: NotificacaoRepository):
        self.repo_notificacao = repo_notificacao

    def pode_notificar(self, cliente_id: UUID) -> bool:
        ultima = self.repo_notificacao.get_ultima_por_cliente(cliente_id)
        if not ultima:
            return True

        delta = (datetime.now() - ultima.data_envio).total_seconds() / 60
        return delta >= 5

    def disparar_aviso(self, cliente_id: UUID, peca_id: UUID, telefone: str):
        if not self.pode_notificar(cliente_id):
            raise Exception("Aguarde 5 minutos para notificar este cliente novamente.")

        print(f"Enviando Zap para {telefone}...")
        
        log = Notificacao(
            cliente_id=cliente_id,
            peca_id=peca_id,
            mensagem="Sua peça está pronta!",
            status="sucesso"
        )
        self.repo_notificacao.create(log)
        return True