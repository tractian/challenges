# Test Tractian

Este projeto é um aplicativo Flutter desenvolvido para a Tractian, focado em visualização e gerenciamento de ativos industriais. O aplicativo permite uma visualização hierárquica de ativos e localizações, com recursos de filtragem e busca.

## 🎥 Demonstração

[![Demo Video](https://img.youtube.com/vi/V9zB5yPVIS8/maxresdefault.jpg)](https://youtube.com/shorts/V9zB5yPVIS8)

## 🚀 Funcionalidades

- Visualização hierárquica de ativos e localizações
- Filtragem por tipo de sensor (energia)
- Filtragem por status crítico
- Busca por nome de ativo
- Interface intuitiva e responsiva
- Processamento eficiente de dados com Isolates

## 🛠️ Tecnologias Utilizadas

- Flutter
- Provider (Gerenciamento de Estado)
- Isolates (Processamento em Background)
- Clean Architecture (Parcialmente implementada)

## 📦 Instalação

1. Clone o repositório:

```bash
git clone https://github.com/mateussiqueira/test-tractian.git
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Execute o aplicativo:

```bash
flutter run
```

## 🎯 Pontos de Melhoria

Se tivesse mais tempo, aqui estão os principais pontos que eu melhoraria no projeto:

### 1. Performance e Otimizações

- Implementar paginação para carregar dados em lotes
- Adicionar cache persistente com `hive` ou `shared_preferences`
- Otimizar o carregamento de imagens com `cached_network_image`
- Implementar lazy loading para nós da árvore
- Adicionar compressão de dados para reduzir o uso de memória

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
