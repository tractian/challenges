import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'locations_screen.dart';

/// Tela inicial que exibe a lista de empresas.
///
/// Esta tela implementa a visualização das empresas disponíveis, com as seguintes características:
///
/// 1. Lista de empresas com cards
/// 2. Navegação para a tela de localizações
/// 3. Feedback visual de estados
/// 4. Tratamento de erros
///
/// A estrutura é otimizada para:
/// - Carregamento eficiente de dados
/// - Navegação intuitiva
/// - Feedback visual claro
/// - Experiência de usuário fluida
class HomeScreen extends StatefulWidget {
  /// Construtor da tela.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Estado da tela inicial.
class _HomeScreenState extends State<HomeScreen> {
  /// Lista de empresas
  List<Map<String, dynamic>> companies = [];

  /// Estado de carregamento
  bool isLoading = true;

  /// Erro ocorrido durante o carregamento
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  /// Carrega as empresas da API.
  Future<void> _loadCompanies() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final fetchedCompanies = await ApiService.fetchCompanies();
      setState(() {
        companies = fetchedCompanies.map((comp) => comp).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erro ao carregar empresas: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCompanies,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Empresas')),
      body: ListView.builder(
        itemCount: companies.length,
        itemBuilder: (context, index) {
          final company = companies[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(company['name']),
              subtitle: Text(company['description']),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => LocationsScreen(companyId: company['id']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
