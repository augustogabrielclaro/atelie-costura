import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../models/peca.dart';
import '../models/cliente.dart';
import 'api_service.dart';

class PecaService {
  final Dio _dio = ApiService.dio;

  Future<Cliente?> buscarClientePorTelefone(String telefone) async {
    try {
      final response = await _dio.get('/clientes/buscar', queryParameters: {'telefone': telefone});
      return Cliente.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('Bateu 404: Cliente não existe no banco. Tudo certo, fluxo normal!');
        return null; 
      }
      debugPrint('Erro real do Dio: ${e.message}');
      throw Exception('Erro ao buscar cliente na API');
    } catch (e) {
      debugPrint('Erro desconhecido: $e');
      return null;
    }
  }

  Future<Peca> criarPedidoCompleto(Map<String, dynamic> payload) async {
    final response = await _dio.post('/pedidos/completo', data: payload);
    return Peca.fromJson(response.data);
  }

  Future<List<Peca>> listarEntregasHoje() async {
    final response = await _dio.get('/entregas/hoje');
    return (response.data as List).map((p) => Peca.fromJson(p)).toList();
  }

  Future<void> notificarCliente(String clienteId, String pecaId, String telefone) async {
    await _dio.post('/notificar/$clienteId/$pecaId', queryParameters: {'telefone': telefone});
  }
}