import 'package:flutter/material.dart';
import '../../models/peca.dart';
import '../../services/peca_service.dart';

class EntregasDiariasScreen extends StatefulWidget {
  const EntregasDiariasScreen({super.key});

  @override
  State<EntregasDiariasScreen> createState() => _EntregasDiariasScreenState();
}

class _EntregasDiariasScreenState extends State<EntregasDiariasScreen> {
  final PecaService _service = PecaService();
  List<Peca> _entregas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final dados = await _service.listarEntregasHoje();
    setState(() {
      _entregas = dados;
      _loading = false;
    });
  }

  Future<void> _dispararAviso(Peca peca) async {
    try {
      // Como o endpoint pede o telefone, no mundo real você traria o telefone do cliente no join do backend.
      // Aqui vamos simular um envio chamando a rota de notificação.
      await _service.notificarCliente(peca.clienteId, peca.id, "5544999999999");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notificação enviada!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aguarde 5min: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entregas do Dia')),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _entregas.length,
            itemBuilder: (context, index) {
              final peca = _entregas[index];
              return ListTile(
                title: Text(peca.descricao),
                subtitle: Text('Valor: R\$ ${peca.valor}'),
                trailing: IconButton(
                  icon: const Icon(Icons.phone_android, color: Colors.green),
                  onPressed: () => _dispararAviso(peca),
                ),
              );
            },
          ),
    );
  }
}