import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../datasources/api_service.dart';

class AssetRepositoryImpl implements AssetRepository {
  final ApiService _apiService;
  List<Asset> _assets = [];

  AssetRepositoryImpl(this._apiService);

  @override
  Future<void> fetchAssets(String companyId) async {
    _assets = await _apiService.fetchAssets(companyId);
  }

  @override
  List<Asset> getAssets() {
    return _assets;
  }

  @override
  Asset? getAsset(String id) {
    try {
      return _assets.firstWhere((asset) => asset.id == id);
    } catch (e) {
      return null;
    }
  }
}
