import 'package:flutter/material.dart';

import '../../domain/entities/asset.dart';
import '../providers/asset_tree_provider.dart';

class AssetTreeNode extends StatelessWidget {
  final Asset asset;
  final int level;
  final AssetTreeProvider provider;

  const AssetTreeNode({
    super.key,
    required this.asset,
    required this.level,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (!provider.shouldShowAssetWithParents(asset)) {
      return const SizedBox();
    }

    final childAssets = provider.getChildAssets(asset.id);
    final hasChildren = childAssets.isNotEmpty;
    final isExpanded = provider.isNodeExpanded(asset.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: level * 16.0),
          child: InkWell(
            onTap:
                hasChildren
                    ? () => provider.toggleNodeExpansion(asset.id)
                    : null,
            child: ListTile(
              leading: Icon(
                asset.sensorType == 'energy'
                    ? Icons.electric_bolt
                    : Icons.devices,
                color: asset.status == 'alert' ? Colors.red : null,
              ),
              title: Text(asset.name),
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
            itemCount: childAssets.length,
            itemBuilder: (context, index) {
              return AssetTreeNode(
                key: ValueKey('child_asset_${childAssets[index].id}'),
                asset: childAssets[index],
                level: level + 1,
                provider: provider,
              );
            },
          ),
      ],
    );
  }
}
