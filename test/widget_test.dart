import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:freshfarm/app.dart';
import 'package:freshfarm/core/network/api_client.dart';
import 'package:freshfarm/core/providers/app_providers.dart';
import 'package:freshfarm/core/storage/local_storage_service.dart';
import 'package:freshfarm/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('farmer mobile navigation and stock controls work', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final localStorageService = LocalStorageService();
    await localStorageService.init();
    final authRepository = MockAuthRepository(
      localStorageService: localStorageService,
      apiClient: ApiClient(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(localStorageService),
          apiClientProvider.overrideWithValue(ApiClient()),
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: const FreshFarmApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('North Field Farm'), findsWidgets);
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Sales this month'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    const potatoQuantity = ValueKey('quantity-public-listing-potato');
    const potatoIncrease = ValueKey('increase-public-listing-potato');
    const potatoDecrease = ValueKey('decrease-public-listing-potato');
    await tester.scrollUntilVisible(find.byKey(potatoQuantity), 300);
    expect(find.text('25 kg'), findsOneWidget);

    await tester.tap(find.byKey(potatoIncrease));
    await tester.pumpAndSettle();
    expect(find.text('26 kg'), findsOneWidget);

    await tester.tap(find.byKey(potatoDecrease));
    await tester.pumpAndSettle();
    expect(find.text('25 kg'), findsOneWidget);

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('Order book'), findsOneWidget);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL SALES'), findsOneWidget);
  });

  testWidgets('farm profile editor and product-first storefront open', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.init();
    final authRepository = MockAuthRepository(
      localStorageService: storage,
      apiClient: ApiClient(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          apiClientProvider.overrideWithValue(ApiClient()),
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: const FreshFarmApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('North Field Farm').first);
    await tester.pumpAndSettle();
    expect(find.text('Edit farm profile'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Save public profile'), findsOneWidget);
    expect(find.text('Preview as customer'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Public farm page'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your produce'), findsOneWidget);
    expect(find.text('Know more'), findsNothing);

    await tester.tap(find.text('New potato'));
    await tester.pumpAndSettle();
    expect(find.text('Request order'), findsOneWidget);
    expect(find.text('25 kg available'), findsOneWidget);
    expect(find.text('1 kg × €3.80'), findsOneWidget);
    expect(find.text('€3.80'), findsWidgets);
  });
}
