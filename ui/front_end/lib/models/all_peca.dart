class AllPeca {
  final String descricao;
  final double valor;
  final String dataEntrega;
  final String clienteNome;

  AllPeca({
    required this.descricao,
    required this.valor,
    required this.dataEntrega,
    required this.clienteNome,
  });

  factory AllPeca.fromJson(Map<String, dynamic> json) => AllPeca(
        descricao: json['descricao'],
        valor: (json['valor'] as num).toDouble(),
        dataEntrega: json['data_entrega'],
        clienteNome: json['cliente_nome'],
      );
}
