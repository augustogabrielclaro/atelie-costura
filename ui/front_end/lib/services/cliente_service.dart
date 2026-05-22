import 'package:dio/dio.dart';
import '../models/cliente.dart';
import 'api_service.dart';

class ClienteService {
  final Dio _dio = ApiService.dio;

  Future<List<Cliente>> listarTodosClientes() async {
    final response = await _dio.get('/clientes');
    return (response.data as List).map((c) => Cliente.fromJson(c)).toList();
  }

  Future<Cliente> buscarClientePorId(String id) async {
    final response = await _dio.get('/clientes/$id');
    return Cliente.fromJson(response.data);
  }

  Future<Cliente> criarCliente(Map<String, dynamic> payload) async {
    final response = await _dio.post('/clientes', data: payload);
    return Cliente.fromJson(response.data);
  }

  Future<Cliente> atualizarCliente(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch('/clientes/$id', data: payload);
    return Cliente.fromJson(response.data);
  }

  Future<void> deletarCliente(String id) async {
    await _dio.delete('/clientes/$id');
  }
}
