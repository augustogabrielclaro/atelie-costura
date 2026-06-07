import os
import requests
from dotenv import load_dotenv
from services.configuracao_whatsapp_service import ConfiguracaoWhatsappService

load_dotenv()

class WhatsappService:
    def __init__(self, configuracao_service: ConfiguracaoWhatsappService):
        self.configuracao_service = configuracao_service

    def send_text_message(self, to_phone: str, text: str):
        credenciais = self.configuracao_service.obter_credenciais()

        if not credenciais:
            return {"error": {"message": "Credenciais do WhatsApp não configuradas no sistema."}}

        telefone_id = credenciais["telefone_id"]
        token = credenciais["access_token"]

        url = f"https://graph.facebook.com/v25.0/{telefone_id}/messages"
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": to_phone,
            "type": "text",
            "text": {
                "preview_url": False,
                "body": text
            }
        }

        try:
            response = requests.post(url, json=payload, headers=headers, timeout=10)
            response.raise_for_status()

            return response.json()
        
        except requests.exceptions.RequestException as req_error:
            print(f"[Network Error] Falha ao comunicar com a Meta: {req_error}")

            return {"error": {"message": "Falha de comunicação com os servidores do WhatsApp"}}