import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';
import '../domain/connection_settings.dart';

class SettingsState {
  final ConnectionSettings settings;
  final bool loading;
  final String? error;

  const SettingsState({
    required this.settings,
    this.loading = false,
    this.error,
  });

  SettingsState copyWith({
    ConnectionSettings? settings,
    bool? loading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._repo)
      : super(const SettingsState(settings: ConnectionSettings.defaults)) {
    load();
  }

  final SettingsRepository _repo;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final settings = await _repo.load();
      state = state.copyWith(settings: settings, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> save(ConnectionSettings settings) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.save(settings);
      state = state.copyWith(settings: settings, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController(ref.watch(settingsRepositoryProvider));
});
