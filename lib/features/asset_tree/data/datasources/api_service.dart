import '../../domain/entities/asset.dart';
import '../../domain/entities/location.dart';

class ApiService {
  Future<List<Location>> fetchLocations(String companyId) async {
    // TODO: Implement API call
    final response = await Future.delayed(
      const Duration(seconds: 1),
      () => [
        {'id': '1', 'name': 'Área de Produção', 'parentId': null},
        {'id': '2', 'name': 'Linha 1', 'parentId': '1'},
        {'id': '3', 'name': 'Linha 2', 'parentId': '1'},
      ],
    );

    return (response as List).map((json) => Location.fromJson(json)).toList();
  }

  Future<List<Asset>> fetchAssets(String companyId) async {
    // TODO: Implement API call
    final response = await Future.delayed(
      const Duration(seconds: 1),
      () => [
        {
          'id': '1',
          'name': 'Máquina 1',
          'parentId': null,
          'locationId': '2',
          'sensorType': 'energy',
          'status': 'normal',
        },
        {
          'id': '2',
          'name': 'Máquina 2',
          'parentId': null,
          'locationId': '2',
          'sensorType': null,
          'status': 'alert',
        },
        {
          'id': '3',
          'name': 'Componente 1',
          'parentId': '1',
          'locationId': null,
          'sensorType': 'temperature',
          'status': 'normal',
        },
      ],
    );

    return (response as List).map((json) => Asset.fromJson(json)).toList();
  }
}
