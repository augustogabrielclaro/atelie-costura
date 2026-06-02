import uuid
import os
import json

from fastapi import FastAPI, Depends, HTTPException, Query, Response, Request
from sqlmodel import Session
from typing import List
from datetime import date
from fastapi.middleware.cors import CORSMiddleware

from schemas.cliente import ClienteOut, ClienteIn
from data.database import get_session, create_db_and_tables
from contextlib import asynccontextmanager

from repositories.cliente_repository import ClienteRepository
from repositories.peca_repository import PecaRepository
from repositories.notificacao_repository import NotificacaoRepository
from repositories.configuracao_whatsapp_repository import ConfiguracaoWhatsappRepository
from services.cliente_service import ClienteService
from services.peca_service import PecaService
from services.notificacao_service import NotificacaoService
from services.whatsapp_service import WhatsappService
from services.configuracao_whatsapp_service import ConfiguracaoWhatsappService
from schemas.pedido import PedidoCompletoIn, PecaOut, AllPecasOut
from schemas.notificacao import *
from schemas.whatsapp import *

VERIFY_TOKEN = os.getenv("WHATSAPP_VERIFY_TOKEN")

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

def get_configuracao_whatsapp_service(session: Session = Depends(get_session)) -> ConfiguracaoWhatsappService:
    repo = ConfiguracaoWhatsappRepository(session)
    return ConfiguracaoWhatsappService(repo)

def get_whatsapp_service(config_service: ConfiguracaoWhatsappService = Depends(get_configuracao_whatsapp_service)) -> WhatsappService:
    return WhatsappService(config_service)

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

@app.get("/clientes", tags=["Busca"], response_model=List[ClienteOut])
def listar_todos_clientes(cliente_service: ClienteService = Depends(get_cliente_service)):
    return cliente_service.repository.get_all_ativos()

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

@app.post("/configuracao/whatsapp", tags=["Configuração"], response_model=ConfiguracaoWhatsappResponse)
def configurar_whatsapp(
    dados: ConfiguracaoWhatsappCreate,
    configuracao_service: ConfiguracaoWhatsappService = Depends(get_configuracao_whatsapp_service)
):
    try:
        config = configuracao_service.configurar_envio(
            telefone_envio=dados.telefone_envio,
            token=dados.access_token,
            waba_id=dados.waba_id
        )
        
        return ConfiguracaoWhatsappResponse(
            telefone_envio=config.telefone_envio,
            waba_id=config.waba_id,
            possui_token=True
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/configuracao/whatsapp", tags=["Configuração"], response_model=ConfiguracaoWhatsappResponse)
def obter_configuracao_whatsapp(configuracao_service: ConfiguracaoWhatsappService = Depends(get_configuracao_whatsapp_service)):
    config = configuracao_service.obter_configuracao_publica()
    
    if not config:
        raise HTTPException(status_code=404, detail="Configuração do WhatsApp não encontrada")
    
    return ConfiguracaoWhatsappResponse(
        telefone_envio=config.telefone_envio,
        waba_id=config.waba_id,
        possui_token=True
    )

@app.put("/configuracao/whatsapp", tags=["Configuração"])
def atualizar_configuracao(
    dados: ConfiguracaoWhatsappUpdate,
    configuracao_service: ConfiguracaoWhatsappService = Depends(get_configuracao_whatsapp_service)
):
    try:
        configuracao_service.configurar_envio(
            telefone_envio=dados.telefone_envio,
            waba_id=dados.waba_id,
            token=dados.access_token 
        )

        return {"mensagem": "Configuração atualizada com sucesso"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# --- WEBHOOK ---

@app.post("/api/whatsapp/send", tags=["WhatsApp"])
def send_message(
    payload: MessageRequest,
    whatsapp_service: WhatsappService = Depends(get_whatsapp_service)
):
    """
    Envia a mensagem de texto para um número do WhatsApp.
    """

    result = whatsapp_service.send_text_message(payload.to_phone, payload.text)
    
    if "error" in result:
        mensagem_erro = result["error"].get("message", "Erro desconhecido na Meta")
        raise HTTPException(status_code=400, detail=f"Falha no envio: {mensagem_erro}")
        
    return {"status": "sucesso", "meta_response": result}

@app.get("/api/whatsapp/webhook", tags=["WhatsApp"])
def verify_webhook(
    hub_mode: str = Query(None, alias="hub.mode"),
    hub_challenge: str = Query(None, alias="hub.challenge"),
    hub_verify_token: str = Query(None, alias="hub.verify_token")
):
    """
    Endpoint de verificação da Meta

    Necessário apenas durante a configuração inicial no painel de desenvolvedores da Meta.
    A Meta faz uma requisição GET para validar se a URL pertence a você.
    """

    if hub_mode != "subscribe" or hub_verify_token != VERIFY_TOKEN:
        raise HTTPException(status_code=403, detail="Token inválido")
    
    return Response(content=str(hub_challenge), media_type="text/plain")

@app.post("/api/whatsapp/webhook", tags=["WhatsApp"])
async def receive_webhook(request: Request):
    """
    Recebe os eventos disparados pelo WhatsApp.

    Captura dois tipos de eventos:
    **Novas Mensagens**
    **Atualizações de Status**
    """
    
    data = await request.json()

    try:
        entries = data.get("entry", [])
        for entry in entries:
            changes = entry.get("changes", [])
            for change in changes:
                value = change.get("value", {})
                
                messages = value.get("messages", [])
                for message in messages:
                    if message.get("type") == "text":
                        texto = message.get("text", {}).get("body", "")
                        numero_origem = message.get("from", "Desconhecido")
                        print(f"[RECEBIDO] Mensagem de {numero_origem}: {texto}")

                statuses = value.get("statuses", [])
                for status in statuses:
                    status_atual = status.get("status")
                    destinatario = status.get("recipient_id")
                    
                    if status_atual == "failed":
                        print(f"[FALHA NO ENVIO] Para: {destinatario}")
                        errors = status.get("errors", [])
                        for error in errors:
                            error_data = error.get("error_data", {})
                            details = error_data.get("details", "Sem detalhes")
                            codigo = error.get("code", "N/A")
                            motivo = error.get("title", "Desconhecido")
                            print(f"    -> Código: {codigo} | Motivo: {motivo} | Detalhes: {details}")
                    else:
                        print(f"[STATUS ATUALIZADO] Para: {destinatario} | Status da mensagem: {status_atual}")
                        
    except Exception as e:
        print(f"Erro ao processar webhook: {e}")
        
    return Response(content="EVENT_RECEIVED", status_code=200)