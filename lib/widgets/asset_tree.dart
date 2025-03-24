import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/asset_tree_provider.dart';
import 'asset_tree_node.dart';
import 'location_tree_node.dart';

/// Widget que exibe a árvore de ativos.
///
/// Este widget implementa a visualização da árvore de ativos, com as seguintes características:
///
/// 1. Integração com o AssetTreeProvider
/// 2. Suporte a expansão/colapso de nós
/// 3. Indentação visual da hierarquia
/// 4. Linhas de conexão entre nós
///
/// A estrutura é otimizada para:
/// - Renderização eficiente de grandes árvores
/// - Manutenção do estado de expansão
/// - Navegação intuitiva
/// - Feedback visual claro
class AssetTree extends StatelessWidget {
  final String companyId;
  final String? locationId;

  const AssetTree({
    super.key,
    required this.companyId,
    this.locationId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetTreeProvider>(
      builder: (context, provider, _) {
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
            return SingleChildScrollView(
              child: LocationTreeNode(
                key: ValueKey('location_${location.id}'),
                location: location,
                level: 0,
                provider: provider,
              ),
            );
          }
          return const SizedBox.shrink();
        }

        // Busca localizações raiz e ativos sem vínculo
        final rootLocations = provider.getRootLocations();
        final unlinkedAssets = provider.getUnlinkedAssets();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...rootLocations.map(
                (location) => LocationTreeNode(
                  key: ValueKey('root_location_${location.id}'),
                  location: location,
                  level: 0,
                  provider: provider,
                ),
              ),
              ...unlinkedAssets.map(
                (asset) => AssetTreeNode(
                  key: ValueKey('unlinked_asset_${asset.id}'),
                  asset: asset,
                  level: 0,
                  provider: provider,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
