import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/asset_tree_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';
import 'locations_screen.dart';

/// Screen that shows the list of companies.
class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Empresas'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.fetchCompanies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar empresas: ${snapshot.error}'),
            );
          }

          final companies = snapshot.data ?? [];

          if (companies.isEmpty) {
            return const Center(child: Text('Nenhuma empresa encontrada'));
          }

          return ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(company['name'] ?? 'Sem nome'),
                  subtitle: Text(company['description'] ?? 'Sem descrição'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => ChangeNotifierProvider(
                              create:
                                  (context) => AssetTreeProvider(
                                    companyId: company['id'],
                                  ),
                              child: LocationsScreen(companyId: company['id']),
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
