import '../data/data.dart';
import '../domain/domain.dart';
import '../presentation/providers/asset_tree_provider.dart';

class Injection {
  static final Injection _instance = Injection._internal();
  factory Injection() => _instance;
  Injection._internal();

  late final AssetRepository _assetRepository;
  late final LocationRepository _locationRepository;
  late final GetAssetTree _getAssetTree;
  late final AssetTreeProvider _assetTreeProvider;

  void initialize() {
    // Data Sources
    final apiService = ApiService();

    // Repositories
    _assetRepository = AssetRepositoryImpl(apiService);
    _locationRepository = LocationRepositoryImpl(apiService);

    // Use Cases
    _getAssetTree = GetAssetTree(_assetRepository, _locationRepository);

    // Providers
    _assetTreeProvider = AssetTreeProvider(_getAssetTree);
  }

  AssetTreeProvider get assetTreeProvider => _assetTreeProvider;
}
