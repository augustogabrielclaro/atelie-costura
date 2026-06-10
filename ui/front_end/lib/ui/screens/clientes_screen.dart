import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../services/cliente_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteService _service = ClienteService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Cliente> _clientes = [];

  bool _loading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _erro;

  int _skip = 0;
  final int _limit = 10;
  String _searchQuery = '';

  String? _editandoId;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  bool _salvando = false;

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
    _nomeController.dispose();
    _telefoneController.dispose();
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
      _clientes.clear();
      _editandoId = null; // Reseta a edição caso esteja buscando
    });

    try {
      final dados = await _service.listarTodosClientes(skip: _skip, limit: _limit, search: _searchQuery);
      setState(() {
        _clientes = dados;
        _loading = false;
        if (dados.length < _limit) _hasMore = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar clientes: $e';
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
      final novosDados = await _service.listarTodosClientes(skip: _skip, limit: _limit, search: _searchQuery);
      setState(() {
        if (novosDados.length < _limit) {
          _hasMore = false;
        }
        _clientes.addAll(novosDados);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // =========================
  // EDIÇÃO
  // =========================
  void _iniciarEdicao(Cliente cliente) {
    setState(() {
      _editandoId = cliente.id;
      _nomeController.text = cliente.nome;
      _telefoneController.text = cliente.telefone;
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _editandoId = null;
    });
  }

  Future<void> _salvarEdicao(String id) async {
    setState(() {
      _salvando = true;
    });

    try {
      final payload = {
        'nome': _nomeController.text,
        'telefone': _telefoneController.text,
      };
      await _service.atualizarCliente(id, payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente atualizado com Sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      setState(() {
        _salvando = false;
        _editandoId = null;
      });

      // Recarrega do zero para garantir que a lista fique sincronizada com a API
      _carregarInicial();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _salvando = false;
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
          'Clientes',
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
          hintText: 'Buscar por nome ou telefone...',
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

    if (_clientes.isEmpty) {
      return RefreshIndicator(
        color: roxo,
        onRefresh: _carregarInicial,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 140),
            Icon(Icons.people_outline, size: 80, color: roxo),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Nenhum cliente encontrado',
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
        padding: const EdgeInsets.all(16),
        itemCount: _clientes.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _clientes.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: roxo)),
            );
          }

          final cliente = _clientes[index];
          final isEditando = _editandoId == cliente.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: isEditando ? 10 : 6,
              shadowColor: roxo.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: isEditando
                    ? const BorderSide(color: roxo, width: 2)
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: isEditando
                    ? _buildModoEdicao(cliente)
                    : _buildModoLeitura(cliente),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModoLeitura(Cliente cliente) {
    return Column(
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
              child: const Icon(Icons.person, color: roxo),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                cliente.nome,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: roxoEscuro,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: roxo),
              onPressed: () => _iniciarEdicao(cliente),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.phone, color: roxo, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                cliente.telefone,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModoEdicao(Cliente cliente) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Editando Cliente',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: roxo,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nomeController,
          decoration: InputDecoration(
            labelText: 'Nome',
            labelStyle: const TextStyle(color: roxoEscuro),
            prefixIcon: const Icon(Icons.person, color: roxo),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: roxo, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _telefoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Telefone',
            labelStyle: const TextStyle(color: roxoEscuro),
            prefixIcon: const Icon(Icons.phone, color: roxo),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: roxo, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _salvando ? null : _cancelarEdicao,
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeAgua,
                foregroundColor: roxoEscuro,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _salvando ? null : () => _salvarEdicao(cliente.id!),
              child: _salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: roxoEscuro,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Salvar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}