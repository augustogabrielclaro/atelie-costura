class ConfiguracaoWhatsapp {
  final String telefoneId;
  final String? wabaId;
  final bool possuiToken;

  ConfiguracaoWhatsapp({
    required this.telefoneId,
    this.wabaId,
    required this.possuiToken,
  });

  factory ConfiguracaoWhatsapp.fromJson(Map<String, dynamic> json) {
    return ConfiguracaoWhatsapp(
      telefoneId: json['telefone_id'] ?? '',
      wabaId: json['waba_id'],
      possuiToken: json['possui_token'] ?? false,
    );
  }
}