import 'package:asset_tree/features/asset_tree/domain/entities/asset.dart';
import 'package:asset_tree/features/asset_tree/domain/entities/location.dart';
import 'package:asset_tree/features/asset_tree/domain/usecases/get_asset_tree.dart';
import 'package:asset_tree/features/asset_tree/presentation/providers/asset_tree_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([GetAssetTree])
import 'asset_tree_provider_test.mocks.dart';

void main() {
  group('AssetTreeProvider', () {
    late AssetTreeProvider provider;
    late MockGetAssetTree mockGetAssetTree;
    late List<Asset> testAssets;
    late List<Location> testLocations;

    setUp(() async {
      mockGetAssetTree = MockGetAssetTree();
      when(mockGetAssetTree.execute(any)).thenAnswer((_) async {});

      testAssets = [
        Asset(
          id: 'parent1',
          name: 'Parent Asset 1',
          parentId: '',
          locationId: 'loc1',
          sensorType: 'energy',
          status: 'normal',
        ),
        Asset(
          id: 'child1',
          name: 'Child Asset 1',
          parentId: 'parent1',
          locationId: 'loc1',
          sensorType: 'temperature',
          status: 'alert',
        ),
        Asset(
          id: 'standalone',
          name: 'Standalone Asset',
          parentId: '',
          locationId: 'loc2',
          sensorType: 'energy',
          status: 'normal',
        ),
      ];

      testLocations = [
        Location(id: 'loc1', name: 'Location 1', parentId: ''),
        Location(id: 'loc2', name: 'Location 2', parentId: ''),
      ];

      when(mockGetAssetTree.getUnlinkedAssets()).thenReturn(testAssets);
      when(mockGetAssetTree.getRootLocations()).thenReturn(testLocations);

      provider = AssetTreeProvider(mockGetAssetTree);
      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('initial state should be correct after loading', () async {
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.searchText, '');
      expect(provider.hasEnergyFilter, false);
      expect(provider.hasCriticalFilter, false);
    });

    test('loadData should update state correctly', () async {
      provider.loadData('company_id');
      expect(provider.isLoading, true);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('loadData should handle errors correctly', () async {
      when(mockGetAssetTree.execute(any)).thenThrow(Exception('Test error'));
      await provider.loadData('company_id');

      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Test error'));
    });

    test('setSearchText should update search text', () async {
      await provider.setSearchText('test');
      expect(provider.searchText, 'test');

      // Wait for debounce and processing
      await Future.delayed(const Duration(milliseconds: 400));
      expect(provider.isLoading, false);
    });

    test('toggleEnergyFilter should update filter state', () async {
      await provider.toggleEnergyFilter();
      expect(provider.hasEnergyFilter, true);

      // Wait for background processing
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider.isLoading, false);
    });

    test('toggleCriticalFilter should update filter state', () async {
      await provider.toggleCriticalFilter();
      expect(provider.hasCriticalFilter, true);

      // Wait for background processing
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider.isLoading, false);
    });

    test('toggleNodeExpansion should update node state', () {
      provider.toggleNodeExpansion('node1');
      expect(provider.isNodeExpanded('node1'), true);
    });

    test('dispose should clean up resources', () async {
      // Create a new provider instance for this test
      final disposableProvider = AssetTreeProvider(mockGetAssetTree);
      await Future.delayed(
          const Duration(milliseconds: 100)); // Wait for initial load

      // Dispose and verify no errors
      disposableProvider.dispose();
      expect(() => disposableProvider.notifyListeners(), throwsFlutterError);
    });

    test('hasVisibleChildren should check correctly', () async {
      await provider.loadData('company_id');
      await Future.delayed(
          const Duration(milliseconds: 100)); // Wait for processing

      final parentAsset = testAssets.firstWhere((a) => a.id == 'parent1');
      final standaloneAsset =
          testAssets.firstWhere((a) => a.id == 'standalone');

      expect(provider.hasVisibleChildren(parentAsset), true);
      expect(provider.hasVisibleChildren(standaloneAsset), false);
    });
  });
}
