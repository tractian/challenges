import 'package:asset_tree/features/asset_tree/data/services/tree_processing_service.dart';
import 'package:asset_tree/features/asset_tree/domain/entities/asset.dart';
import 'package:asset_tree/features/asset_tree/domain/entities/location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TreeProcessingService', () {
    late List<Asset> testAssets;
    late List<Location> testLocations;

    setUp(() {
      testAssets = [
        Asset(
          id: '1',
          name: 'Asset 1',
          parentId: 'parent1',
          locationId: 'loc1',
          sensorType: 'energy',
          status: 'normal',
        ),
        Asset(
          id: '2',
          name: 'Asset 2',
          parentId: 'parent1',
          locationId: 'loc1',
          sensorType: 'temperature',
          status: 'alert',
        ),
        Asset(
          id: '3',
          name: 'Test Asset',
          parentId: 'parent2',
          locationId: 'loc2',
          sensorType: 'energy',
          status: 'normal',
        ),
      ];

      testLocations = [
        Location(id: 'loc1', name: 'Location 1', parentId: ''),
        Location(id: 'loc2', name: 'Location 2', parentId: ''),
      ];
    });

    test('filterAssetsInBackground should handle empty input', () async {
      final result = await TreeProcessingService.filterAssetsInBackground(
        [],
        '',
        false,
        false,
      );

      expect(result, isEmpty);
    });

    test('filterAssetsInBackground should filter assets correctly', () async {
      final result = await TreeProcessingService.filterAssetsInBackground(
        testAssets,
        'Test',
        false,
        false,
      );

      expect(result.length, 1);
      expect(result.first.name, 'Test Asset');
    });

    test('filterAssetsInBackground should apply energy filter', () async {
      final result = await TreeProcessingService.filterAssetsInBackground(
        testAssets,
        '',
        true,
        false,
      );

      expect(result.length, 2);
      expect(result.every((asset) => asset.sensorType == 'energy'), true);
    });

    test('filterAssetsInBackground should apply critical filter', () async {
      final result = await TreeProcessingService.filterAssetsInBackground(
        testAssets,
        '',
        false,
        true,
      );

      expect(result.length, 1);
      expect(result.first.status, 'alert');
    });

    test('processAssetTreeInBackground should handle empty input', () async {
      final result = await TreeProcessingService.processAssetTreeInBackground(
        [],
        [],
        '',
        false,
        false,
      );

      expect(result, isEmpty);
    });

    test('processAssetTreeInBackground should process assets correctly',
        () async {
      final result = await TreeProcessingService.processAssetTreeInBackground(
        testAssets,
        testLocations,
        '',
        false,
        false,
      );

      expect(result['child_parent1']?.length, 2);
      expect(result['child_parent2']?.length, 1);
      expect(result['loc_loc1']?.length, 2);
      expect(result['loc_loc2']?.length, 1);
    });

    test('processAssetTreeInBackground should apply filters correctly',
        () async {
      final result = await TreeProcessingService.processAssetTreeInBackground(
        testAssets,
        testLocations,
        'Test',
        false,
        false,
      );

      expect(result['child_parent2']?.length, 1);
      expect(result['loc_loc2']?.length, 1);
      expect(result['child_parent2']?.first.name, 'Test Asset');
    });

    test('processAssetTreeInBackground should use cache correctly', () async {
      // First call to populate cache
      final result1 = await TreeProcessingService.processAssetTreeInBackground(
        testAssets,
        testLocations,
        '',
        false,
        false,
      );

      // Second call should use cache
      final result2 = await TreeProcessingService.processAssetTreeInBackground(
        testAssets,
        testLocations,
        '',
        false,
        false,
      );

      expect(result1, equals(result2));
    });

    test('processAssetTreeInBackground should handle large datasets', () async {
      final largeAssets = List.generate(
        1000,
        (index) => Asset(
          id: 'asset_$index',
          name: 'Asset $index',
          parentId: 'parent_${index % 10}',
          locationId: 'loc_${index % 5}',
          sensorType: index % 2 == 0 ? 'energy' : 'temperature',
          status: index % 3 == 0 ? 'alert' : 'normal',
        ),
      );

      final largeLocations = List.generate(
        10,
        (index) =>
            Location(id: 'loc_$index', name: 'Location $index', parentId: ''),
      );

      final result = await TreeProcessingService.processAssetTreeInBackground(
        largeAssets,
        largeLocations,
        '',
        false,
        false,
      );

      expect(result.isNotEmpty, true);
      expect(result.values.every((assets) => assets.isNotEmpty), true);
    });
  });
}
