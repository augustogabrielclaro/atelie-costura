import 'package:dio/dio.dart';
import '../models/configuracao_whatsapp.dart';
import 'api_service.dart';

class ConfiguracaoWhatsappService {
  final Dio _dio = ApiService.dio;

  // ConfiguracaoWhatsappService(this._dio);

  Future<ConfiguracaoWhatsapp?> obterConfiguracao() async {
    try {
      final response = await _dio.get('/configuracao/whatsapp');
      return ConfiguracaoWhatsapp.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Erro ao buscar configuração do WhatsApp: ${e.message}');
    }
  }

  Future<void> criarConfiguracao({
    required String telefoneId,
    required String token,
    String? wabaId,
  }) async {
    try {
      await _dio.post(
        '/configuracao/whatsapp', 
        data: {
          'telefone_id': telefoneId,
          'token': token,
          'waba_id': wabaId,
        }
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erro ao criar configuração');
    }
  }

  Future<void> atualizarConfiguracao({
    String? telefoneId,
    String? token,
    String? wabaId,
  }) async {
    try {
      final data = {
        if (telefoneId != null) 'telefone_id': telefoneId,
        if (wabaId != null) 'waba_id': wabaId,
        if (token != null && token.trim().isNotEmpty) 'token': token, 
      };

      await _dio.put('/configuracao/whatsapp', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erro ao atualizar configuração');
    }
  }
}