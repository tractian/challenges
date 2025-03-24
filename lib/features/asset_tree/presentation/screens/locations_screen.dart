import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/asset_tree_provider.dart';
import '../widgets/asset_tree.dart';
import '../widgets/filter_chips.dart';
import '../widgets/search_controls.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: _LocationsAppBar(), body: _LocationsBody());
  }
}

class _LocationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LocationsAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Locations'), centerTitle: true);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LocationsBody extends StatelessWidget {
  const _LocationsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SearchAndFiltersSection(),
        Expanded(child: _AssetTreeSection()),
      ],
    );
  }
}

class _SearchAndFiltersSection extends StatelessWidget {
  const _SearchAndFiltersSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<AssetTreeProvider>(
        builder:
            (context, provider, _) => Column(
              children: [
                SearchControls(onSearchChanged: provider.setSearchText),
                const SizedBox(height: 8),
                FilterChips(
                  onEnergyFilterChanged: (_) => provider.toggleEnergyFilter(),
                  onCriticalFilterChanged:
                      (_) => provider.toggleCriticalFilter(),
                  hasEnergyFilter: provider.hasEnergyFilter,
                  hasCriticalFilter: provider.hasCriticalFilter,
                ),
              ],
            ),
      ),
    );
  }
}

class _AssetTreeSection extends StatelessWidget {
  const _AssetTreeSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetTreeProvider>(
      builder: (context, provider, _) => AssetTree(provider: provider),
    );
  }
}
