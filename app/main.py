from fastapi import FastAPI, Depends, HTTPException
from sqlmodel import Session
from uuid import UUID
from typing import List

# Importando nossa fundação
from data.database import get_session
from repositories.cliente_repository import ClienteRepository
from repositories.peca_repository import PecaRepository
from repositories.notificacao_repository import NotificacaoRepository
from services.cliente_service import ClienteService
from services.peca_service import PecaService
from services.notificacao_service import NotificacaoService
from data.database import create_db_and_tables
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()
    yield

app = FastAPI(lifespan=lifespan, title="Costura API - Maringá Style")

# --- ENDPOINTS ---

@app.post("/pedidos/completo", tags=["Fluxo Principal"])
def criar_pedido_fluxo_completo(
    nome: str, 
    telefone: str, 
    descricao: str, 
    session: Session = Depends(get_session)
):
    """
    Cadastra cliente (se não existir) e a peça em um único clique.
    """
    cliente_repo = ClienteRepository(session)
    peca_repo = PecaRepository(session)
    cliente_service = ClienteService(cliente_repo)
    peca_service = PecaService(peca_repo, cliente_service)
    
    return peca_service.cadastrar_pedido_completo(nome, telefone, descricao)

@app.post("/notificar/{cliente_id}/{peca_id}", tags=["Notificações"])
def notificar_cliente(
    cliente_id: UUID, 
    peca_id: UUID, 
    telefone: str, 
    session: Session = Depends(get_session)
):
    """
    Dispara o aviso via Zap (com a trava de 5 minutos).
    """
    notif_repo = NotificacaoRepository(session)
    notificao_service = NotificacaoService(notif_repo)
    
    try:
        return notificao_service.disparar_aviso(cliente_id, peca_id, telefone)
    except Exception as e:
        raise HTTPException(status_code=429, detail=str(e))

@app.get("/clientes/buscar", tags=["Busca"])
def buscar_cliente_por_telefone(telefone: str, session: Session = Depends(get_session)):
    """
    Busca rápida para o Flutter dar o 'Olá, Nome!' ao digitar o telefone.
    """
    repo = ClienteRepository(session)
    service = ClienteService(repo)
    tel_limpo = service.limpar_telefone(telefone)
    
    cliente = repo.get_by_telefone(tel_limpo)
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente não encontrado ou inativo")
    return cliente

@app.delete("/clientes/{cliente_id}", tags=["Administração"])
def deletar_cliente(cliente_id: UUID, session: Session = Depends(get_session)):
    """
    Soft Delete: Apenas inativa o cliente.
    """
    repo = ClienteRepository(session)
    sucesso = repo.deactivate(cliente_id)
    if not sucesso:
        raise HTTPException(status_code=404, detail="Cliente não encontrado")
    return {"msg": "Cliente desativado com sucesso"}