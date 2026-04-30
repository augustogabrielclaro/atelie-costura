import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../providers/pedido_provider.dart';

class CadastroPedidoScreen extends StatelessWidget {
  final _telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final _telefoneController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataController = TextEditingController(); // Ex: 2026-04-15

  CadastroPedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Encomenda')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _telefoneController,
              inputFormatters: [_telefoneMask],
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefone do Cliente'),
              onChanged: (val) => provider.verificarTelefone(val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: provider.nomeController,
              enabled: !provider.isNomeBloqueado, // Trava aqui
              decoration: InputDecoration(
                labelText: 'Nome do Cliente',
                suffixIcon: provider.isLoading ? const CircularProgressIndicator() : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição do Serviço (Ex: Barra)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(labelText: 'Data de Entrega (AAAA-MM-DD)'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await context.read<PedidoProvider>().salvarPedido(
                  _telefoneController.text,
                  _descricaoController.text,
                  double.parse(_valorController.text),
                  _dataController.text,
                );
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvo com sucesso!')));
              },
              child: const Text('Salvar Encomenda'),
            )
          ],
        ),
      ),
    );
  }
}