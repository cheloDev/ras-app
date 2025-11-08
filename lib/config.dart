// dart
// File: `lib/config.dart`
class ApiEndpoints {
  static const String siniestroUpload = 'api/siniestro/upload/';
  static const String siniestroGetByPatente = 'api/siniestro/get-by-patente/';
  static const String login = 'api/login';
  static const String checkToken = 'api/check-token';
// agregar otros endpoints aquí...
}

class ApiConfig {
  // Cambiar aquí para todos los entornos
  static const String baseUrl = 'http://localhost:8010/';

  // Construye Uri a partir del path del endpoint
  static Uri uri(String endpointPath) => Uri.parse('$baseUrl$endpointPath');

// Si prefieres formatear con parámetros:
// static Uri uriWithParams(String endpointPath, [Map<String,String>? params]) {
//   final uri = Uri.parse('$baseUrl$endpointPath');
//   return params == null ? uri : uri.replace(queryParameters: params);
// }
}