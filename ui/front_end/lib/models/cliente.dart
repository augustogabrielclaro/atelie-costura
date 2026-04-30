class Cliente {
  final String? id;
  final String nome;
  final String telefone;

  Cliente({this.id, required this.nome, required this.telefone});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'],
      telefone: json['telefone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'telefone': telefone,
  };
}