from sqlmodel import Session, select, desc
from models.notificacao import Notificacao
from uuid import UUID

class NotificacaoRepository:
    def __init__(self, session: Session):
        self.session = session

    def create(self, notificacao: Notificacao) -> Notificacao:
        self.session.add(notificacao)
        self.session.commit()
        self.session.refresh(notificacao)
        return notificacao

    def get_ultima_por_cliente(self, cliente_id: UUID) -> Notificacao:
        statement = (
            select(Notificacao)
            .where(Notificacao.cliente_id == cliente_id)
            .order_by(desc(Notificacao.data_envio))
        )
        return self.session.exec(statement).first()