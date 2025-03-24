import '../entities/asset.dart';
import '../entities/location.dart';
import '../repositories/asset_repository.dart';
import '../repositories/location_repository.dart';

class GetAssetTree {
  final AssetRepository _assetRepository;
  final LocationRepository _locationRepository;

  GetAssetTree(this._assetRepository, this._locationRepository);

  Future<void> execute(String companyId) async {
    await Future.wait([
      _assetRepository.fetchAssets(companyId),
      _locationRepository.fetchLocations(companyId),
    ]);
  }

  Location? getLocation(String id) {
    return _locationRepository.getLocation(id);
  }

  List<Location> getRootLocations() {
    return _locationRepository
        .getLocations()
        .where((loc) => loc.parentId == null)
        .toList();
  }

  List<Location> getSubLocations(String parentId) {
    return _locationRepository
        .getLocations()
        .where((loc) => loc.parentId == parentId)
        .toList();
  }

  List<Asset> getUnlinkedAssets() {
    return _assetRepository
        .getAssets()
        .where((asset) => asset.locationId == null && asset.parentId == null)
        .toList();
  }

  List<Asset> getLocationAssets(String locationId) {
    return _assetRepository
        .getAssets()
        .where((asset) => asset.locationId == locationId)
        .toList();
  }

  List<Asset> getChildAssets(String parentId) {
    return _assetRepository
        .getAssets()
        .where((asset) => asset.parentId == parentId)
        .toList();
  }
}

class AssetTreeResult {
  final List<Location> locations;
  final List<Asset> assets;

  const AssetTreeResult({required this.locations, required this.assets});
}
