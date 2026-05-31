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

  List<Cliente> _clientes = [];

  bool _loading = true;
  String? _erro;

  String? _editandoId; // Guarda o ID do cliente que está sendo editado
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  bool _salvando = false;

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

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final dados = await _service.listarTodosClientes();

      setState(() {
        _clientes = dados;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar clientes: $e';
        _loading = false;
      });
    }
  }

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

      _carregar();

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

        child: _buildBody(),
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

    if (_clientes.isEmpty) {
      return RefreshIndicator(
        color: roxo,

        onRefresh: _carregar,

        child: ListView(
          children: const [
            SizedBox(height: 140),
            Icon(Icons.people_outline, size: 80, color: roxo),

            SizedBox(height: 20),

            Center(
              child: Text(
                'Nenhum cliente cadastrado',
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
        itemCount: _clientes.length,
        itemBuilder: (context, index) {
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
