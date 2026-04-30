class Peca {
  final String id;
  final String descricao;
  final double valor;
  final String dataEntrega;
  final String clienteId;
  final String status;

  Peca({
    required this.id, required this.descricao, required this.valor,
    required this.dataEntrega, required this.clienteId, required this.status
  });

  factory Peca.fromJson(Map<String, dynamic> json) {
    return Peca(
      id: json['id'],
      descricao: json['descricao'],
      valor: (json['valor'] as num).toDouble(),
      dataEntrega: json['data_entrega'],
      clienteId: json['cliente_id'],
      status: json['status'],
    );
  }
}