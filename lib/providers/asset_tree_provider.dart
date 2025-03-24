import 'dart:async';

import 'package:flutter/material.dart';

import '../models/asset.dart';
import '../models/location.dart';
import '../services/api_service.dart';

/// Provider responsável por gerenciar a árvore de ativos.
///
/// Este provider implementa a lógica de construção e filtragem da árvore de ativos,
/// com as seguintes características:
///
/// 1. Construção da árvore hierárquica
/// 2. Filtros de busca e status
/// 3. Gerenciamento de estado de expansão
/// 4. Otimização de performance
///
/// A estrutura é otimizada para:
/// - Construção eficiente da árvore
/// - Filtragem sem perda de contexto
/// - Atualização seletiva de nós
/// - Experiência de usuário fluida
class AssetTreeProvider extends ChangeNotifier {
  final String companyId;
  List<Location> _locations = [];
  List<Asset> _assets = [];
  bool _isLoading = false;
  String? _error;

  // Filtros
  String _searchQuery = '';
  bool _showEnergySensors = false;
  bool _showCriticalStatus = false;

  // Cache e otimizações
  final Map<String, List<Asset>> _assetCache = {};
  final Map<String, List<Location>> _locationCache = {};
  Timer? _debounceTimer;
  bool _isDirty = false;
  Timer? _notifyTimer;

  // Estado de expansão dos nós
  final Map<String, ValueNotifier<bool>> _expansionNotifiers = {};

  AssetTreeProvider({required this.companyId}) {
    loadData();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get energyFilter => _showEnergySensors;
  bool get criticalFilter => _showCriticalStatus;

  /// Carrega os dados de localizações e ativos da API.
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final locationsJson = await ApiService.fetchLocations(companyId);
      final assetsJson = await ApiService.fetchAssets(companyId);
      _locations =
          locationsJson.map((json) => Location.fromJson(json)).toList();
      _assets = assetsJson.map((json) => Asset.fromJson(json)).toList();
      _clearCache();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar dados: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca os ativos da empresa.
  Future<List<Asset>> fetchAssets(String companyId) async {
    try {
      final assetsJson = await ApiService.fetchAssets(companyId);
      return assetsJson.map((json) => Asset.fromJson(json)).toList();
    } catch (e) {
      _error = 'Erro ao carregar ativos: $e';
      notifyListeners();
      return [];
    }
  }

  /// Define a query de busca.
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query.toLowerCase();
    _clearCache();
    _scheduleNotify();
  }

  /// Define o filtro de sensores de energia.
  void setEnergyFilter(bool value) {
    if (_showEnergySensors == value) return;
    _showEnergySensors = value;
    _clearCache();
    _scheduleNotify();
  }

  /// Define o filtro de status crítico.
  void setCriticalFilter(bool value) {
    if (_showCriticalStatus == value) return;
    _showCriticalStatus = value;
    _clearCache();
    _scheduleNotify();
  }

  /// Alterna o estado de expansão de um nó.
  void toggleNodeExpansion(String nodeId) {
    final notifier = _expansionNotifiers[nodeId] ?? ValueNotifier<bool>(false);
    notifier.value = !notifier.value;
    _expansionNotifiers[nodeId] = notifier;
    _scheduleNotify();
  }

  /// Verifica se um nó está expandido.
  bool isNodeExpanded(String nodeId) {
    return _expansionNotifiers[nodeId]?.value ?? false;
  }

  /// Verifica se um ativo deve ser exibido com base nos filtros.
  bool shouldShowAsset(Asset asset) {
    if (_searchQuery.isNotEmpty) {
      final name = asset.name.toLowerCase();
      if (!name.contains(_searchQuery)) {
        return false;
      }
    }

    if (_showEnergySensors && asset.sensorType != 'energy') {
      return false;
    }

    if (_showCriticalStatus && asset.status != 'alert') {
      return false;
    }

    return true;
  }

  /// Verifica se um ativo tem filhos que devem ser exibidos.
  bool hasVisibleChildren(Asset asset) {
    return _assets.any(
      (child) =>
          child.parentId == asset.id && shouldShowAssetWithParents(child),
    );
  }

  /// Verifica se um ativo deve ser exibido (incluindo seus pais).
  bool shouldShowAssetWithParents(Asset asset) {
    if (_searchQuery.isEmpty && !_showEnergySensors && !_showCriticalStatus) {
      return true;
    }

    if (shouldShowAsset(asset)) {
      return true;
    }

    return hasVisibleChildren(asset);
  }

  /// Retorna a cor do status do ativo.
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'alert':
        return Colors.red;
      case 'operating':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Location? getLocation(String locationId) {
    try {
      return _locations.firstWhere((loc) => loc.id == locationId);
    } catch (e) {
      return null;
    }
  }

  List<Location> getRootLocations() {
    return _locations.where((loc) => loc.parentId == null).toList();
  }

  List<Location> getSubLocations(String parentId) {
    final cacheKey = 'sub_$parentId';
    if (_locationCache.containsKey(cacheKey)) {
      return _locationCache[cacheKey]!;
    }

    final locations =
        _locations.where((loc) => loc.parentId == parentId).toList();
    _locationCache[cacheKey] = locations;
    return locations;
  }

  List<Asset> getUnlinkedAssets() {
    return _assets
        .where((asset) => asset.locationId == null && asset.parentId == null)
        .toList();
  }

  List<Asset> getLocationAssets(String locationId) {
    final cacheKey = 'loc_$locationId';
    if (_assetCache.containsKey(cacheKey)) {
      return _assetCache[cacheKey]!;
    }

    final assets = _assets
        .where((asset) => asset.locationId == locationId)
        .where(shouldShowAssetWithParents)
        .toList();

    _assetCache[cacheKey] = assets;
    return assets;
  }

  List<Asset> getChildAssets(String parentId) {
    final cacheKey = 'child_$parentId';
    if (_assetCache.containsKey(cacheKey)) {
      return _assetCache[cacheKey]!;
    }

    final assets = _assets
        .where((asset) => asset.parentId == parentId)
        .where(shouldShowAssetWithParents)
        .toList();

    _assetCache[cacheKey] = assets;
    return assets;
  }

  void _clearCache() {
    _assetCache.clear();
    _locationCache.clear();
  }

  void _scheduleNotify() {
    _isDirty = true;
    _notifyTimer?.cancel();
    _notifyTimer = Timer(const Duration(milliseconds: 16), () {
      if (_isDirty) {
        _isDirty = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _notifyTimer?.cancel();
    for (final notifier in _expansionNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }
}
