import 'package:flutter/material.dart';
import '../../models/all_peca.dart';
import '../../services/peca_service.dart';

class PecasListScreen extends StatefulWidget {
  const PecasListScreen({super.key});

  @override
  State<PecasListScreen> createState() => _PecasListScreenState();
}

class _PecasListScreenState extends State<PecasListScreen> {
  final PecaService _service = PecaService();
  List<AllPeca> _pecas = [];
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final dados = await _service.listarTodasPecas();
      setState(() {
        _pecas = dados;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar peças: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todas as Peças')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_erro!, textAlign: TextAlign.center),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: _pecas.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Nenhuma peça cadastrada')),
              ],
            )
          : ListView.builder(
              itemCount: _pecas.length,
              itemBuilder: (context, index) {
                final peca = _pecas[index];
                return ListTile(
                  title: Text(peca.descricao),
                  subtitle: Text(
                    'Cliente: ${peca.clienteNome}  •  Entrega: ${peca.dataEntrega}',
                  ),
                  trailing: Text('R\$ ${peca.valor.toStringAsFixed(2)}'),
                );
              },
            ),
    );
  }
}
