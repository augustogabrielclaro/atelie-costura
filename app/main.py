from fastapi import FastAPI, Depends, HTTPException
from sqlmodel import Session
import uuid
from typing import List
from datetime import date
from fastapi.middleware.cors import CORSMiddleware

from schemas.cliente import ClienteOut, ClienteIn
from data.database import get_session, create_db_and_tables
from contextlib import asynccontextmanager

from repositories.cliente_repository import ClienteRepository
from repositories.peca_repository import PecaRepository
from repositories.notificacao_repository import NotificacaoRepository
from services.cliente_service import ClienteService
from services.peca_service import PecaService
from services.notificacao_service import NotificacaoService
from schemas.pedido import PedidoCompletoIn, PecaOut, AllPecasOut
from schemas.notificacao import *

@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()
    yield

app = FastAPI(lifespan=lifespan, title="Costura API - Maringá Style")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
    payload: PedidoCompletoIn,
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

@app.get("/pecas/all", tags=["Busca"], response_model=List[AllPecasOut])
def listar_todas_pecas(peca_service: PecaService = Depends(get_peca_service)):
    """
    Endpoint para listar todas as peças, usado para debug e conferência.
    """
    return peca_service.listar_todas_pecas()

@app.post("/notificar/enviar", tags=["Notificações"], response_model=NotificacaoOut)
def registrar_notificacao_enviada(
    payload: NotificacaoIn,
    notificacao_service: NotificacaoService = Depends(get_notificacao_service),
    cliente_service: ClienteService = Depends(get_cliente_service)
):
    """
    Registra que o disparo via WhatsApp foi feito.
    """
    try:
        cliente = cliente_service.repository.get_by_id(uuid.UUID(payload.cliente_id))
        telefone = cliente.telefone
        notificacao = notificacao_service.disparar_aviso(cliente.id, uuid.UUID(payload.peca_id), telefone)
        return NotificacaoOut(
            id=notificacao.id,
            nome_cliente=cliente.nome,
            mensagem=notificacao.mensagem
        )
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
def deletar_cliente(cliente_id: str, cliente_service: ClienteService = Depends(get_cliente_service)):
    """
    Soft Delete: Apenas inativa o cliente.
    """
    sucesso = cliente_service.repository.deactivate(uuid.UUID(cliente_id))
    if not sucesso:
        raise HTTPException(status_code=404, detail="Cliente não encontrado")
    return {"msg": "Cliente desativado com sucesso"}

@app.patch("/clientes/{cliente_id}", tags=["Administração"], response_model=ClienteOut)
def editar_cliente(
    cliente_id: str,
    cliente_in: ClienteIn, 
    cliente_service: ClienteService = Depends(get_cliente_service)
):
    """
    Edita os dados do cliente. O telefone é limpo e validado durante o processamento.
    """
    return cliente_service.patch_cliente(uuid.UUID(cliente_id), cliente_in)