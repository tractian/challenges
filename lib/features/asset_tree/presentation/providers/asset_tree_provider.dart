import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/services/tree_processing_service.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/get_asset_tree.dart';

class AssetTreeProvider extends ChangeNotifier {
  final GetAssetTree _getAssetTree;
  bool _isLoading = false;
  String? _error;
  String _searchText = '';
  bool _hasEnergyFilter = false;
  bool _hasCriticalFilter = false;
  final Map<String, bool> _expandedNodes = {};
  Map<String, List<Asset>> _filteredAssetsCache = {};
  final Map<String, List<Location>> _locationsCache = {};
  List<Asset> _allAssets = [];
  List<Location> _allLocations = [];
  Timer? _debounceTimer;
  bool _isDirty = false;
  Timer? _notifyTimer;

  AssetTreeProvider(this._getAssetTree) {
    loadData('company_id');
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchText => _searchText;
  bool get hasEnergyFilter => _hasEnergyFilter;
  bool get hasCriticalFilter => _hasCriticalFilter;

  Future<void> loadData(String companyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _getAssetTree.execute(companyId);
      _allAssets = _getAssetTree.getUnlinkedAssets();
      _allLocations = _getAssetTree.getRootLocations();
      await _processTreeInBackground();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _processTreeInBackground() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await TreeProcessingService.processAssetTreeInBackground(
        _allAssets,
        _allLocations,
        _searchText,
        _hasEnergyFilter,
        _hasCriticalFilter,
      );
      _filteredAssetsCache = result;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSearchText(String text) async {
    if (_searchText == text) return;
    _searchText = text;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _processTreeInBackground();
    });
  }

  Future<void> toggleEnergyFilter() async {
    _hasEnergyFilter = !_hasEnergyFilter;
    await _processTreeInBackground();
  }

  Future<void> toggleCriticalFilter() async {
    _hasCriticalFilter = !_hasCriticalFilter;
    await _processTreeInBackground();
  }

  void toggleNodeExpansion(String nodeId) {
    _expandedNodes[nodeId] = !(_expandedNodes[nodeId] ?? false);
    _scheduleNotify();
  }

  bool isNodeExpanded(String nodeId) {
    return _expandedNodes[nodeId] ?? false;
  }

  List<Asset> getChildAssets(String parentId) {
    final cacheKey = 'child_$parentId';
    if (_filteredAssetsCache.containsKey(cacheKey)) {
      return _filteredAssetsCache[cacheKey]!;
    }

    final assets =
        _allAssets
            .where((asset) => asset.parentId == parentId)
            .where(shouldShowAssetWithParents)
            .toList();

    _filteredAssetsCache[cacheKey] = assets;
    return assets;
  }

  List<Location> getSubLocations(String parentId) {
    final cacheKey = 'sub_$parentId';
    if (_locationsCache.containsKey(cacheKey)) {
      return _locationsCache[cacheKey]!;
    }

    final locations =
        _allLocations.where((loc) => loc.parentId == parentId).toList();
    _locationsCache[cacheKey] = locations;
    return locations;
  }

  List<Asset> getLocationAssets(String locationId) {
    final cacheKey = 'loc_$locationId';
    if (_filteredAssetsCache.containsKey(cacheKey)) {
      return _filteredAssetsCache[cacheKey]!;
    }

    final assets =
        _allAssets
            .where((asset) => asset.locationId == locationId)
            .where(shouldShowAssetWithParents)
            .toList();

    _filteredAssetsCache[cacheKey] = assets;
    return assets;
  }

  List<Location> getRootLocations() {
    return _allLocations;
  }

  List<Asset> getUnlinkedAssets() {
    return _allAssets;
  }

  Location? getLocation(String locationId) {
    try {
      return _allLocations.firstWhere((loc) => loc.id == locationId);
    } catch (e) {
      return null;
    }
  }

  bool shouldShowAsset(Asset asset) {
    if (_searchText.isNotEmpty) {
      final name = asset.name.toLowerCase();
      if (!name.contains(_searchText)) {
        return false;
      }
    }

    if (_hasEnergyFilter && asset.sensorType != 'energy') {
      return false;
    }

    if (_hasCriticalFilter && asset.status != 'alert') {
      return false;
    }

    return true;
  }

  bool hasVisibleChildren(Asset asset) {
    return getChildAssets(asset.id).isNotEmpty;
  }

  bool shouldShowAssetWithParents(Asset asset) {
    if (_searchText.isEmpty && !_hasEnergyFilter && !_hasCriticalFilter) {
      return true;
    }

    if (shouldShowAsset(asset)) {
      return true;
    }

    return hasVisibleChildren(asset);
  }

  void clearCache() {
    _filteredAssetsCache.clear();
    _locationsCache.clear();
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
    super.dispose();
  }
}
