import 'package:flutter/material.dart';
import '../models/configuracao_whatsapp.dart';
import '../services/configuracao_whatsapp_service.dart';

class WhatsappProvider extends ChangeNotifier {
  final ConfiguracaoWhatsappService _service;

  WhatsappProvider(this._service);

  ConfiguracaoWhatsapp? configAtual;
  bool isLoading = false;
  String? errorMessage;

  Future<void> carregarConfiguracao() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      configAtual = await _service.obterConfiguracao();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> salvarConfiguracao({
    required String telefoneId,
    required String token,
    String? wabaId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (configAtual == null) {
        await _service.criarConfiguracao(
          telefoneId: telefoneId,
          token: token,
          wabaId: wabaId,
        );
      } else {
        await _service.atualizarConfiguracao(
          telefoneId: telefoneId,
          token: token,
          wabaId: wabaId,
        );
      }
      
      // Recarrega os dados para atualizar o estado interno com o que está no banco
      await carregarConfiguracao();
      return true;
      
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}