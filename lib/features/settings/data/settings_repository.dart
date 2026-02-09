import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/prefs_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/connection_settings.dart';

class SettingsRepository {
  SettingsRepository(this._prefs, this._secure);

  final PrefsService _prefs;
  final SecureStorageService _secure;

  static const _settingsKey = 'connection_settings';
  static const _authValueKey = 'auth_value_secure';

  Future<ConnectionSettings> load() async {
    final raw = await _prefs.getString(_settingsKey);
    if (raw == null) {
      return ConnectionSettings.defaults;
    }
    final settings = ConnectionSettings.fromRawJson(raw);
    final authValue = await _secure.read(_authValueKey) ?? settings.authValue;
    return settings.copyWith(authValue: authValue);
  }

  Future<void> save(ConnectionSettings settings) async {
    await _prefs.setString(_settingsKey, settings.copyWith(authValue: '').toRawJson());
    if (settings.authValue.isNotEmpty) {
      await _secure.write(_authValueKey, settings.authValue);
    } else {
      await _secure.delete(_authValueKey);
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(PrefsService(), SecureStorageService());
});
