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

  // =========================
  // CORES
  // =========================

  static const roxo = Color(0xFF4A148C);
  static const roxoEscuro = Color(0xFF2A0A4A);
  static const verdeAgua = Color(0xFF64FFDA);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // =========================
  // CARREGAR DADOS
  // =========================

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
    });

    try {
      final dados = await _service.listarEntregasHoje();

      setState(() {
        _entregas = dados;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao carregar entregas: $e'),
        ),
      );
    }
  }

  // =========================
  // NOTIFICAÇÃO
  // =========================

  Future<void> _dispararAviso(Peca peca) async {
    try {
      await _service.notificarCliente(peca.clienteId, peca.id, "5544999999999");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: verdeAgua,
          content: Text(
            'Notificação enviada!',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Aguarde 5min: $e'),
        ),
      );
    }
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),

      // =========================
      // APPBAR
      // =========================
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: roxo,

        title: const Text(
          'Entregas do Dia',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // =========================
      // BODY
      // =========================
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F2FF), Color(0xFFE7DDFD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: _buildBody(),
      ),
    );
  }

  // =========================
  // BODY CONTENT
  // =========================

  Widget _buildBody() {
    // LOADING
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: verdeAgua));
    }

    // LISTA VAZIA
    if (_entregas.isEmpty) {
      return RefreshIndicator(
        color: roxo,

        onRefresh: _carregar,

        child: ListView(
          children: const [
            SizedBox(height: 140),

            Icon(Icons.local_shipping_outlined, size: 80, color: roxo),

            SizedBox(height: 20),

            Center(
              child: Text(
                'Nenhuma entrega para hoje',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: roxoEscuro,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // LISTA
    return RefreshIndicator(
      color: roxo,

      onRefresh: _carregar,

      child: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: _entregas.length,

        itemBuilder: (context, index) {
          final peca = _entregas[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),

            child: Card(
              elevation: 6,
              shadowColor: roxo.withOpacity(0.15),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // =========================
                    // HEADER
                    // =========================
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: verdeAgua.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: const Icon(Icons.checkroom, color: roxo),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            peca.descricao,

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: roxoEscuro,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // VALOR
                    // =========================
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: roxo, size: 20),

                        const SizedBox(width: 8),

                        Text(
                          'R\$ ${peca.valor.toStringAsFixed(2)}',

                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =========================
                    // BOTÃO WHATSAPP
                    // =========================
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roxo,
                          foregroundColor: Colors.white,

                          elevation: 4,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        onPressed: () => _dispararAviso(peca),

                        icon: const Icon(Icons.phone_android),

                        label: const Text(
                          'Enviar Notificação',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
