import os
from datetime import datetime, timezone
from fernet import Fernet
from models.configuracao_whatsapp import ConfiguracaoWhatsapp
from repositories.configuracao_whatsapp_repository import ConfiguracaoWhatsappRepository

class ConfiguracaoWhatsappService:
    def __init__(self, repository: ConfiguracaoWhatsappRepository):
        self.repository = repository
        
        chave_secreta = os.getenv("META_CRYPT_KEY")
        if not chave_secreta:
            raise ValueError("Chave de criptografia não configurada no ambiente.")
            
        self.fernet = Fernet(chave_secreta.encode())

    def configurar_envio(self, telefone_id: str = None, token: str = None, waba_id: str = None) -> ConfiguracaoWhatsapp:
        """
        Atualiza a configuração existente ou cria uma nova se for a primeira vez.
        """
        config = self.repository.get()
        
        if config:
            if telefone_id:
                config.telefone_id = telefone_id
            if waba_id is not None:
                config.waba_id = waba_id
            if token:
                config.acess_token = self.fernet.encrypt(token.encode())
                
            config.data_atualizacao = datetime.now(timezone.utc)
        else:
            if not telefone_id or not token:
                raise ValueError("Id do telefone e token são obrigatórios no primeiro cadastro.")
                
            config = ConfiguracaoWhatsapp(
                telefone_id=telefone_id,
                waba_id=waba_id,
                acess_token=self.fernet.encrypt(token.encode())
            )

        return self.repository.save(config)


    def obter_configuracao_publica(self) -> ConfiguracaoWhatsapp | None:
        """
        Busca a configuração sem descriptografar o token
        """

        return self.repository.get()

    def obter_credenciais(self) -> dict | None:
        """
        Busca a configuração e descriptografa o token (uso interno para disparar msgs)
        """

        config = self.repository.get()

        if not config:
            return None
        
        token_descriptografado = self.fernet.decrypt(config.acess_token).decode()
        
        return {
            "telefone_id": config.telefone_id,
            "waba_id": config.waba_id,
            "access_token": token_descriptografado
        }