import '../entities/location.dart';

abstract class LocationRepository {
  Future<void> fetchLocations(String companyId);
  List<Location> getLocations();
  Location? getLocation(String id);
}
