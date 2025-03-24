import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/asset_tree_provider.dart';

/// Widget que exibe os controles de busca e filtros.
///
/// Este widget permite que o usuário:
/// - Busque por texto
/// - Filtre por sensores de energia
/// - Filtre por status crítico
class SearchControls extends StatelessWidget {
  const SearchControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Campo de busca
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar ativos...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
                onChanged: (value) {
                  context.read<AssetTreeProvider>().setSearchQuery(value);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Filtro de Energia
          IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: ValueNotifier<bool>(
                context.watch<AssetTreeProvider>().energyFilter,
              ),
              builder: (context, isActive, child) {
                return Icon(
                  Icons.electric_bolt,
                  color: isActive ? Colors.blue : Colors.grey,
                );
              },
            ),
            onPressed: () {
              final provider = context.read<AssetTreeProvider>();
              provider.setEnergyFilter(!provider.energyFilter);
            },
          ),
          // Filtro de Status Crítico
          IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: ValueNotifier<bool>(
                context.watch<AssetTreeProvider>().criticalFilter,
              ),
              builder: (context, isActive, child) {
                return Icon(
                  Icons.warning,
                  color: isActive ? Colors.red : Colors.grey,
                );
              },
            ),
            onPressed: () {
              final provider = context.read<AssetTreeProvider>();
              provider.setCriticalFilter(!provider.criticalFilter);
            },
          ),
        ],
      ),
    );
  }
}
