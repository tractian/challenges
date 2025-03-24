import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/api_service.dart';

class LocationRepositoryImpl implements LocationRepository {
  final ApiService _apiService;
  List<Location> _locations = [];

  LocationRepositoryImpl(this._apiService);

  @override
  Future<void> fetchLocations(String companyId) async {
    _locations = await _apiService.fetchLocations(companyId);
  }

  @override
  List<Location> getLocations() {
    return _locations;
  }

  @override
  Location? getLocation(String id) {
    try {
      return _locations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }
}
