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

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: roxo,

        title: const Text(
          'Todas as Peças',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

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
  // BODY
  // =========================

  Widget _buildBody() {
    // LOADING
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: verdeAgua));
    }

    // ERRO
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Card(
            elevation: 6,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),

                  const SizedBox(height: 16),

                  Text(
                    _erro!,
                    textAlign: TextAlign.center,

                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: roxo,
                      foregroundColor: Colors.white,
                    ),

                    onPressed: _carregar,

                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // LISTA VAZIA
    if (_pecas.isEmpty) {
      return RefreshIndicator(
        color: roxo,

        onRefresh: _carregar,

        child: ListView(
          children: const [
            SizedBox(height: 140),

            Icon(Icons.inventory_2_outlined, size: 80, color: roxo),

            SizedBox(height: 20),

            Center(
              child: Text(
                'Nenhuma peça cadastrada',
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

        itemCount: _pecas.length,

        itemBuilder: (context, index) {
          final peca = _pecas[index];

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
                    // DESCRIÇÃO
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

                    const SizedBox(height: 20),

                    // =========================
                    // CLIENTE
                    // =========================
                    Row(
                      children: [
                        const Icon(Icons.person, color: roxo, size: 20),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            peca.clienteNome,

                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // ENTREGA
                    // =========================
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: roxo, size: 20),

                        const SizedBox(width: 8),

                        Text(
                          peca.dataEntrega,

                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // VALOR
                    // =========================
                    Align(
                      alignment: Alignment.centerRight,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: verdeAgua.withOpacity(0.18),

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Text(
                          'R\$ ${peca.valor.toStringAsFixed(2)}',

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: roxoEscuro,
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
