import 'dart:async';
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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<AllPeca> _pecas = [];

  bool _loading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _erro;

  int _skip = 0;
  final int _limit = 10;
  String _searchQuery = '';

  // =========================
  // CORES
  // =========================
  static const roxo = Color(0xFF4A148C);
  static const roxoEscuro = Color(0xFF2A0A4A);
  static const verdeAgua = Color(0xFF64FFDA);

  @override
  void initState() {
    super.initState();
    _carregarInicial();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        _carregarMais();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // =========================
  // LOGICA DE BUSCA
  // =========================
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != value) {
        setState(() {
          _searchQuery = value;
        });
        _carregarInicial();
      }
    });
  }

  // =========================
  // CARREGAR DADOS
  // =========================

  Future<void> _carregarInicial() async {
    setState(() {
      _loading = true;
      _erro = null;
      _skip = 0;
      _hasMore = true;
      _pecas.clear();
    });

    try {
      final dados = await _service.listarTodasPecas(skip: _skip, limit: _limit, search: _searchQuery);
      setState(() {
        _pecas = dados;
        _loading = false;
        if (dados.length < _limit) _hasMore = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar peças: $e';
        _loading = false;
      });
    }
  }

  Future<void> _carregarMais() async {
    if (_isLoadingMore || !_hasMore || _loading) return;

    setState(() {
      _isLoadingMore = true;
      _skip += _limit;
    });

    try {
      final novosDados = await _service.listarTodasPecas(skip: _skip, limit: _limit, search: _searchQuery);
      setState(() {
        if (novosDados.length < _limit) {
          _hasMore = false;
        }
        _pecas.addAll(novosDados);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
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
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // =========================
  // SEARCH BAR
  // =========================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por descrição ou cliente...',
          prefixIcon: const Icon(Icons.search, color: roxo),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // =========================
  // BODY
  // =========================

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: verdeAgua));
    }

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
                    onPressed: _carregarInicial,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_pecas.isEmpty) {
      return RefreshIndicator(
        color: roxo,
        onRefresh: _carregarInicial,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Icon(Icons.inventory_2_outlined, size: 80, color: roxo),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Nenhuma peça encontrada',
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

    return RefreshIndicator(
      color: roxo,
      onRefresh: _carregarInicial,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _pecas.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          
          if (index == _pecas.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: roxo)),
            );
          }

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