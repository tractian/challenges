import 'package:flutter/material.dart';

import '../providers/asset_tree_provider.dart';
import 'asset_tree_node.dart';
import 'location_tree_node.dart';

class AssetTree extends StatelessWidget {
  final AssetTreeProvider provider;
  final String? locationId;

  const AssetTree({
    super.key,
    required this.provider,
    this.locationId,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }

    // Se uma locationId foi especificada, constrói a árvore a partir dela
    if (locationId != null) {
      final location = provider.getLocation(locationId!);
      if (location != null) {
        return LocationTreeNode(
          location: location,
          level: 0,
          provider: provider,
        );
      }
      return const SizedBox.shrink();
    }

    // Busca localizações raiz e ativos sem vínculo
    final rootLocations = provider.getRootLocations();
    final unlinkedAssets = provider.getUnlinkedAssets();

    return SingleChildScrollView(
      child: Column(
        children: [
          ...rootLocations.map((location) => LocationTreeNode(
                key: ValueKey('location_${location.id}'),
                location: location,
                level: 0,
                provider: provider,
              )),
          ...unlinkedAssets.map((asset) => AssetTreeNode(
                key: ValueKey('asset_${asset.id}'),
                asset: asset,
                level: 0,
                provider: provider,
              )),
        ],
      ),
    );
  }
}
