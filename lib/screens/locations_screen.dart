import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/asset_tree_provider.dart';
import '../widgets/asset_tree.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/search_controls.dart';

/// Tela que exibe a lista de localizações e a árvore de ativos.
///
/// Esta tela implementa a visualização das localizações e seus ativos, com as seguintes características:
///
/// 1. Lista de localizações com ExpansionTile
/// 2. Árvore de ativos por localização
/// 3. Filtros de busca e status
/// 4. Feedback visual de estados
///
/// A estrutura é otimizada para:
/// - Navegação intuitiva entre localizações
/// - Filtragem eficiente de ativos
/// - Feedback visual claro
/// - Experiência de usuário fluida
class LocationsScreen extends StatelessWidget {
  final String companyId;

  const LocationsScreen({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AssetTreeProvider(companyId: companyId),
      child: const _LocationsView(),
    );
  }
}

class _LocationsView extends StatelessWidget {
  const _LocationsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssetTreeProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Erro: ${provider.error}',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Recarrega os dados
                  context.read<AssetTreeProvider>().loadData();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Localizações', showBackButton: true),
      body: Column(
        children: [
          // Controles de busca e filtros
          const SearchControls(),
          // Árvore de ativos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AssetTree(
                companyId: provider.companyId,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
