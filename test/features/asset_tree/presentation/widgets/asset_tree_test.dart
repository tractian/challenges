import 'package:asset_tree/features/asset_tree/domain/entities/asset.dart';
import 'package:asset_tree/features/asset_tree/domain/entities/location.dart';
import 'package:asset_tree/features/asset_tree/presentation/providers/asset_tree_provider.dart';
import 'package:asset_tree/features/asset_tree/presentation/widgets/asset_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<AssetTreeProvider>()])
import 'asset_tree_test.mocks.dart';

void main() {
  late MockAssetTreeProvider mockProvider;
  late List<Location> mockLocations;
  late List<Asset> mockAssets;

  setUp(() {
    mockProvider = MockAssetTreeProvider();
    mockLocations = [
      Location(
        id: 'loc1',
        name: 'Location 1',
        parentId: '',
      ),
    ];
    mockAssets = [
      Asset(
        id: 'asset1',
        name: 'Asset 1',
        locationId: 'loc1',
        parentId: '',
        sensorType: 'temperature',
        status: 'normal',
      ),
      Asset(
        id: 'asset2',
        name: 'Asset 2',
        locationId: 'loc1',
        parentId: 'asset1',
        sensorType: 'energy',
        status: 'alert',
      ),
    ];

    // Setup default stubs
    when(mockProvider.isLoading).thenReturn(false);
    when(mockProvider.error).thenReturn(null);
    when(mockProvider.getRootLocations()).thenReturn(mockLocations);
    when(mockProvider.getUnlinkedAssets()).thenReturn([]);
    when(mockProvider.getSubLocations(any)).thenReturn([]);
    when(mockProvider.getLocationAssets(any)).thenReturn([]);
    when(mockProvider.getChildAssets(any)).thenReturn([]);
    when(mockProvider.isNodeExpanded(any)).thenReturn(false);
    when(mockProvider.shouldShowAssetWithParents(any)).thenReturn(true);
    when(mockProvider.shouldShowAsset(any)).thenReturn(true);
  });

  group('AssetTree', () {
    testWidgets('should show loading indicator when loading',
        (WidgetTester tester) async {
      when(mockProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetTree(provider: mockProvider),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when error occurs',
        (WidgetTester tester) async {
      when(mockProvider.error).thenReturn('Test error');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetTree(provider: mockProvider),
          ),
        ),
      );

      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('should show locations when data is loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetTree(provider: mockProvider),
          ),
        ),
      );

      expect(find.text('Location 1'), findsOneWidget);
    });

    testWidgets('should show assets when location is expanded',
        (WidgetTester tester) async {
      when(mockProvider.isNodeExpanded('loc1')).thenReturn(true);
      when(mockProvider.getLocationAssets('loc1')).thenReturn([mockAssets[0]]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetTree(provider: mockProvider),
          ),
        ),
      );

      expect(find.text('Asset 1'), findsOneWidget);
    });

    testWidgets('should show child assets when asset is expanded',
        (WidgetTester tester) async {
      // Show the location and its assets
      when(mockProvider.isNodeExpanded('loc1')).thenReturn(true);
      when(mockProvider.getLocationAssets('loc1')).thenReturn([mockAssets[0]]);

      // Show the child assets when parent is expanded
      when(mockProvider.isNodeExpanded('asset1')).thenReturn(true);
      when(mockProvider.getChildAssets('asset1')).thenReturn([mockAssets[1]]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetTree(provider: mockProvider),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Location 1'), findsOneWidget);
      expect(find.text('Asset 1'), findsOneWidget);
      expect(find.text('Asset 2'), findsOneWidget);
    });

    testWidgets('should handle empty data gracefully',
        (WidgetTester tester) async {
      when(mockProvider.getRootLocations()).thenReturn([]);
      when(mockProvider.getUnlinkedAssets()).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetTree(provider: mockProvider),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });
  });
}
