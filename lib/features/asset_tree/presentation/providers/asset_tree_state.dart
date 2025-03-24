import '../../domain/entities/asset.dart';
import '../../domain/entities/location.dart';

class AssetTreeState {
  final List<Location> locations;
  final List<Asset> assets;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final bool showEnergySensors;
  final bool showCriticalStatus;
  final Map<String, bool> expandedNodes;

  const AssetTreeState({
    this.locations = const [],
    this.assets = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.showEnergySensors = false,
    this.showCriticalStatus = false,
    this.expandedNodes = const {},
  });

  AssetTreeState copyWith({
    List<Location>? locations,
    List<Asset>? assets,
    bool? isLoading,
    String? error,
    String? searchQuery,
    bool? showEnergySensors,
    bool? showCriticalStatus,
    Map<String, bool>? expandedNodes,
  }) {
    return AssetTreeState(
      locations: locations ?? this.locations,
      assets: assets ?? this.assets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      showEnergySensors: showEnergySensors ?? this.showEnergySensors,
      showCriticalStatus: showCriticalStatus ?? this.showCriticalStatus,
      expandedNodes: expandedNodes ?? this.expandedNodes,
    );
  }
}
