import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/providers/app_providers.dart';
import 'core/storage/local_storage_service.dart';
import 'features/auth/data/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  final apiClient = ApiClient();
  final authRepository = MockAuthRepository(
    localStorageService: localStorageService,
    apiClient: apiClient,
  );

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
        apiClientProvider.overrideWithValue(apiClient),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: const FreshFarmApp(),
    ),
  );
}
