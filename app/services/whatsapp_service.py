import os
import requests
from dotenv import load_dotenv

load_dotenv()

class WhatsappService:
    def __init__(self):
        self.token = os.getenv("WHATSAPP_TOKEN")
        self.phone_number_id = os.getenv("PHONE_NUMBER_ID")
        self.url = f"https://graph.facebook.com/v18.0/{self.phone_number_id}/messages"
        self.headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }

    def send_text_message(self, to_phone: str, text: str):
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
            response = requests.post(self.url, json=payload, headers=self.headers, timeout=10)
            response.raise_for_status()

            return response.json()
        
        except requests.exceptions.RequestException as req_error:
            print(f"[Network Error] Falha ao comunicar com a Meta: {req_error}")

            return {"error": {"message": "Falha de comunicação com os servidores do WhatsApp"}}