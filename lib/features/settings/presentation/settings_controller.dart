import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/storage/local_storage_service.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
      return SettingsController(ref.watch(localStorageServiceProvider))..load();
    });

class SettingsState {
  const SettingsState({this.locale = const Locale('en')});

  final Locale? locale;

  SettingsState copyWith({Locale? locale}) {
    return SettingsState(locale: locale ?? this.locale);
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._localStorageService) : super(const SettingsState());

  final LocalStorageService _localStorageService;

  void load() {
    final languageCode = _localStorageService.getSelectedLanguageCode();
    if (languageCode != null) {
      state = state.copyWith(locale: Locale(languageCode));
    }
  }

  Future<void> updateLocale(Locale locale) async {
    await _localStorageService.saveSelectedLanguageCode(locale.languageCode);
    state = state.copyWith(locale: locale);
  }
}
