import 'package:flutter/material.dart';

import '../../domain/entities/location.dart';
import '../providers/asset_tree_provider.dart';
import 'asset_tree_node.dart';

class LocationTreeNode extends StatelessWidget {
  final Location location;
  final int level;
  final AssetTreeProvider provider;

  const LocationTreeNode({
    super.key,
    required this.location,
    required this.level,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final subLocations = provider.getSubLocations(location.id);
    final locationAssets = provider.getLocationAssets(location.id);
    final hasChildren = subLocations.isNotEmpty || locationAssets.isNotEmpty;
    final isExpanded = provider.isNodeExpanded(location.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: level * 16.0),
          child: InkWell(
            onTap:
                hasChildren
                    ? () => provider.toggleNodeExpansion(location.id)
                    : null,
            child: ListTile(
              leading: const Icon(Icons.folder),
              title: Text(location.name),
              trailing:
                  hasChildren
                      ? Icon(isExpanded ? Icons.expand_less : Icons.expand_more)
                      : null,
            ),
          ),
        ),
        if (isExpanded && hasChildren)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subLocations.length + locationAssets.length,
            itemBuilder: (context, index) {
              if (index < subLocations.length) {
                return LocationTreeNode(
                  key: ValueKey('sub_location_${subLocations[index].id}'),
                  location: subLocations[index],
                  level: level + 1,
                  provider: provider,
                );
              } else {
                final assetIndex = index - subLocations.length;
                return AssetTreeNode(
                  key: ValueKey(
                    'location_asset_${locationAssets[assetIndex].id}',
                  ),
                  asset: locationAssets[assetIndex],
                  level: level + 1,
                  provider: provider,
                );
              }
            },
          ),
      ],
    );
  }
}
