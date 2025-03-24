import '../entities/asset.dart';

abstract class AssetRepository {
  Future<void> fetchAssets(String companyId);
  List<Asset> getAssets();
  Asset? getAsset(String id);
}
