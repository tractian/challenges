import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import '../../domain/entities/asset.dart';
import '../../domain/entities/location.dart';

void _filterAssetsIsolate(_FilterAssetsMessage message) {
  if (message.assets.isEmpty) {
    message.sendPort.send([]);
    return;
  }

  final filteredAssets = message.assets.where((asset) {
    if (message.searchText.isNotEmpty) {
      final name = asset.name.toLowerCase();
      if (!name.contains(message.searchText)) {
        return false;
      }
    }

    if (message.hasEnergyFilter && asset.sensorType != 'energy') {
      return false;
    }

    if (message.hasCriticalFilter && asset.status != 'alert') {
      return false;
    }

    return true;
  }).toList();

  message.sendPort.send(filteredAssets);
}

void _processBatchIsolate(_ProcessBatchMessage message) {
  if (message.batch.isEmpty) {
    message.sendPort.send({});
    return;
  }

  final result = <String, List<Asset>>{};
  final searchLower = message.searchText.toLowerCase();

  for (final asset in message.batch) {
    if (!_shouldIncludeAsset(
      asset,
      searchLower,
      message.hasEnergyFilter,
      message.hasCriticalFilter,
    )) {
      continue;
    }

    final parentKey = 'child_${asset.parentId}';
    final locationKey = 'loc_${asset.locationId}';

    result[parentKey] = [...(result[parentKey] ?? []), asset];
    result[locationKey] = [...(result[locationKey] ?? []), asset];
  }

  message.sendPort.send(result);
}

bool _shouldIncludeAsset(
  Asset asset,
  String searchText,
  bool hasEnergyFilter,
  bool hasCriticalFilter,
) {
  if (searchText.isNotEmpty) {
    final name = asset.name.toLowerCase();
    if (!name.contains(searchText)) {
      return false;
    }
  }

  if (hasEnergyFilter && asset.sensorType != 'energy') {
    return false;
  }

  if (hasCriticalFilter && asset.status != 'alert') {
    return false;
  }

  return true;
}

class TreeProcessingService {
  static const int _batchSize = 100;
  static const int _maxIsolates = 4;
  static final Map<String, Map<String, List<Asset>>> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);
  static final _isolatePool = Queue<Isolate>();
  static final _processingQueue = Queue<Future<void>>();
  static const bool _isProcessing = false;

  static Future<List<Asset>> filterAssetsInBackground(
    List<Asset> assets,
    String searchText,
    bool hasEnergyFilter,
    bool hasCriticalFilter,
  ) async {
    if (assets.isEmpty) {
      return [];
    }

    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _filterAssetsIsolate,
      _FilterAssetsMessage(
        assets: assets,
        searchText: searchText.toLowerCase(),
        hasEnergyFilter: hasEnergyFilter,
        hasCriticalFilter: hasCriticalFilter,
        sendPort: receivePort.sendPort,
      ),
    );

    final result = await receivePort.first as List<dynamic>;
    isolate.kill();
    receivePort.close();

    return result.cast<Asset>();
  }

  static Future<Map<String, List<Asset>>> processAssetTreeInBackground(
    List<Asset> assets,
    List<Location> locations,
    String searchText,
    bool hasEnergyFilter,
    bool hasCriticalFilter,
  ) async {
    if (assets.isEmpty) {
      return {};
    }

    final cacheKey = _generateCacheKey(
      searchText,
      hasEnergyFilter,
      hasCriticalFilter,
    );

    if (_cache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheDuration) {
        return _cache[cacheKey]!;
      }
    }

    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _processBatchIsolate,
      _ProcessBatchMessage(
        batch: assets,
        searchText: searchText.toLowerCase(),
        hasEnergyFilter: hasEnergyFilter,
        hasCriticalFilter: hasCriticalFilter,
        sendPort: receivePort.sendPort,
      ),
    );

    final result = await receivePort.first as Map<String, dynamic>;
    isolate.kill();
    receivePort.close();

    final typedResult = result.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).cast<Asset>(),
      ),
    );

    _cache[cacheKey] = typedResult;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return typedResult;
  }

  static String _generateCacheKey(
    String searchText,
    bool hasEnergyFilter,
    bool hasCriticalFilter,
  ) {
    return '$searchText|$hasEnergyFilter|$hasCriticalFilter';
  }
}

class _FilterAssetsMessage {
  final List<Asset> assets;
  final String searchText;
  final bool hasEnergyFilter;
  final bool hasCriticalFilter;
  final SendPort sendPort;

  _FilterAssetsMessage({
    required this.assets,
    required this.searchText,
    required this.hasEnergyFilter,
    required this.hasCriticalFilter,
    required this.sendPort,
  });
}

class _ProcessBatchMessage {
  final List<Asset> batch;
  final String searchText;
  final bool hasEnergyFilter;
  final bool hasCriticalFilter;
  final SendPort sendPort;

  _ProcessBatchMessage({
    required this.batch,
    required this.searchText,
    required this.hasEnergyFilter,
    required this.hasCriticalFilter,
    required this.sendPort,
  });
}
