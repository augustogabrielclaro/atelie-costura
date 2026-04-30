import 'package:dio/dio.dart';

class ApiService {
  // Ajuste o IP para o da sua máquina na rede local, pois o emulador/celular não enxerga "localhost"
  static final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000', 
    connectTimeout: const Duration(seconds: 5),
  ));
}