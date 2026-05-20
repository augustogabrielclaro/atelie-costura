import 'package:flutter/material.dart';
import '../services/peca_service.dart';
import '../models/cliente.dart';

class PedidoProvider extends ChangeNotifier {
  final PecaService _service = PecaService();
  
  bool isLoading = false;
  bool isNomeBloqueado = false;
  Cliente? clienteEncontrado;

  final nomeController = TextEditingController();

  Future<void> verificarTelefone(String telefone) async {
    final telLimpo = telefone.replaceAll(RegExp(r'\D'), '');
    
    if (telLimpo.length == 11) {
      isLoading = true;
      notifyListeners();

      try {
        clienteEncontrado = await _service.buscarClientePorTelefone(telLimpo);
        
        if (clienteEncontrado != null) {
          nomeController.text = clienteEncontrado!.nome;
          isNomeBloqueado = true; // Achou! Trava o nome
        } else {
          nomeController.clear();
          isNomeBloqueado = false; // Não achou, libera pra digitar
        }
      } catch (e) {
        debugPrint("Caiu no catch do Provider: $e");
        nomeController.clear();
        isNomeBloqueado = false;
      } finally {
        isLoading = false;
        notifyListeners();
      }
    } else {
      isNomeBloqueado = false;
      clienteEncontrado = null;
      notifyListeners();
    }
  } 

  Future<void> salvarPedido(String telefone, String descricao, double valor, String data) async {
    final payload = {
      "nome": nomeController.text,
      "telefone": telefone.replaceAll(RegExp(r'\D'), ''),
      "descricao": descricao,
      "valor": valor,
      "data_entrega": data
    };
    await _service.criarPedidoCompleto(payload);
    nomeController.clear();
    isNomeBloqueado = false;
    notifyListeners();
  }
}