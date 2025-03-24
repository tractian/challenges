import 'dart:convert';

import 'package:http/http.dart' as http;

/// Serviço responsável pela comunicação com a API.
///
/// Este serviço implementa as chamadas à API para buscar dados de ativos,
/// com as seguintes características:
///
/// 1. Estrutura de dados consistente com a API real
/// 2. Tratamento de erros
/// 3. Tipagem forte dos dados
///
/// A estrutura é otimizada para:
/// - Desenvolvimento rápido sem dependência da API real
/// - Fácil migração para a API real
/// - Manutenção da consistência dos dados
class ApiService {
  /// URL base da API
  static const String baseUrl = 'https://fake-api.tractian.com';

  /// Busca as empresas disponíveis.
  ///
  /// Retorna uma lista de empresas com a seguinte estrutura:
  /// ```json
  /// {
  ///   "id": "string",
  ///   "name": "string",
  ///   "description": "string"
  /// }
  /// ```
  ///
  /// Em caso de erro, lança uma exceção com a mensagem de erro.
  static Future<List<Map<String, dynamic>>> fetchCompanies() async {
    final response = await http.get(Uri.parse('$baseUrl/companies'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (data is Map<String, dynamic>) {
        return [data];
      }
    }
    throw Exception('Falha ao carregar empresas: ${response.statusCode}');
  }

  /// Busca as localizações de uma empresa.
  ///
  /// [companyId] - ID da empresa para buscar as localizações
  ///
  /// Retorna uma lista de localizações com a seguinte estrutura:
  /// ```json
  /// {
  ///   "id": "string",
  ///   "name": "string",
  ///   "parentId": "string?"
  /// }
  /// ```
  ///
  /// Em caso de erro, lança uma exceção com a mensagem de erro.
  static Future<List<Map<String, dynamic>>> fetchLocations(
    String companyId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/companies/$companyId/locations'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (data is Map<String, dynamic>) {
        return [data];
      }
    }
    throw Exception('Falha ao carregar localizações: ${response.statusCode}');
  }

  /// Busca os ativos de uma empresa.
  ///
  /// [companyId] - ID da empresa para buscar os ativos
  ///
  /// Retorna uma lista de ativos com a seguinte estrutura:
  /// ```json
  /// {
  ///   "id": "string",
  ///   "name": "string",
  ///   "parentId": "string?",
  ///   "locationId": "string?",
  ///   "sensorId": "string?",
  ///   "sensorType": "string?",
  ///   "status": "string?",
  ///   "gatewayId": "string?"
  /// }
  /// ```
  ///
  /// Em caso de erro, lança uma exceção com a mensagem de erro.
  static Future<List<Map<String, dynamic>>> fetchAssets(
    String companyId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/companies/$companyId/assets'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (data is Map<String, dynamic>) {
        return [data];
      }
    }
    throw Exception('Falha ao carregar ativos: ${response.statusCode}');
  }
}
