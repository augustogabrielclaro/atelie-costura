from fastapi import FastAPI, Depends, HTTPException
from sqlmodel import Session
from uuid import UUID
from typing import List
from datetime import date

from data.database import get_session, create_db_and_tables
from contextlib import asynccontextmanager

from repositories.cliente_repository import ClienteRepository
from repositories.peca_repository import PecaRepository
from repositories.notificacao_repository import NotificacaoRepository
from services.cliente_service import ClienteService
from services.peca_service import PecaService
from services.notificacao_service import NotificacaoService
from schemas.pedido import PedidoCompletoIn, PecaOut

@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()
    yield

app = FastAPI(lifespan=lifespan, title="Costura API - Maringá Style")

def get_cliente_service(session: Session = Depends(get_session)) -> ClienteService:
    repo = ClienteRepository(session)
    return ClienteService(repo)

def get_peca_service(session: Session = Depends(get_session), cliente_service: ClienteService = Depends(get_cliente_service)) -> PecaService:
    repo = PecaRepository(session)
    return PecaService(repo, cliente_service)

def get_notificacao_service(session: Session = Depends(get_session)) -> NotificacaoService:
    repo = NotificacaoRepository(session)
    return NotificacaoService(repo)

# --- ENDPOINTS ---

@app.post("/pedidos/completo", tags=["Fluxo Principal"], response_model=PecaOut)
def criar_pedido_fluxo_completo(
    payload: PedidoCompletoIn, # Agora recebe JSON Body corretamente
    peca_service: PecaService = Depends(get_peca_service)
):
    """
    Cadastra cliente (se não existir) e a peça em um único clique via Flutter.
    """
    return peca_service.cadastrar_pedido_completo(
        nome_cliente=payload.nome,
        telefone=payload.telefone,
        descricao_peca=payload.descricao,
        valor=payload.valor,
        data_entrega=payload.data_entrega
    )

@app.get("/entregas/hoje", tags=["Automação"], response_model=List[PecaOut])
def buscar_entregas_do_dia(
    data_alvo: date = None, 
    peca_service: PecaService = Depends(get_peca_service)
):
    """
    Endpoint que o script Python vai consumir para saber quem avisar hoje.
    """
    if data_alvo is None:
        data_alvo = date.today()
    return peca_service.listar_entregas_do_dia(data_alvo)

@app.post("/notificar/{cliente_id}/{peca_id}", tags=["Notificações"])
def registrar_notificacao_enviada(
    cliente_id: UUID, 
    peca_id: UUID, 
    notificacao_service: NotificacaoService = Depends(get_notificacao_service),
    cliente_service: ClienteService = Depends(get_cliente_service)
):
    """
    Registra que o disparo via WhatsApp foi feito (chamado pelo script local).
    """
    try:
        telefone = cliente_service.repository.get_by_id(cliente_id).telefone
        return notificacao_service.disparar_aviso(cliente_id, peca_id, telefone)
    except Exception as e:
        raise HTTPException(status_code=429, detail=str(e))

@app.get("/clientes/buscar", tags=["Busca"])
def buscar_cliente_por_telefone(telefone: str, cliente_service: ClienteService = Depends(get_cliente_service)):
    """
    Busca rápida para o Flutter.
    """
    tel_limpo = cliente_service.limpar_telefone(telefone)
    cliente = cliente_service.repository.get_by_telefone(tel_limpo)
    
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente não encontrado ou inativo")
    return cliente

@app.delete("/clientes/{cliente_id}", tags=["Administração"])
def deletar_cliente(cliente_id: UUID, cliente_service: ClienteService = Depends(get_cliente_service)):
    """
    Soft Delete: Apenas inativa o cliente.
    """
    sucesso = cliente_service.repository.deactivate(cliente_id)
    if not sucesso:
        raise HTTPException(status_code=404, detail="Cliente não encontrado")
    return {"msg": "Cliente desativado com sucesso"}