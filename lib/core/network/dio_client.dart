import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/presentation/settings_controller.dart';
import '../../features/settings/domain/connection_settings.dart';

class DioClient {
  DioClient(this._ref) {
    _dio = Dio();
    _configure(_ref.read(settingsControllerProvider).settings);
    _ref.listen<SettingsState>(settingsControllerProvider, (previous, next) {
      _configure(next.settings);
    });
  }

  late final Dio _dio;
  final Ref _ref;

  Dio get dio => _dio;

  void _configure(ConnectionSettings settings) {
    _dio.options.baseUrl = settings.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: settings.timeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: settings.timeoutSeconds);

    final headers = <String, dynamic>{};
    headers.addAll(settings.headers);

    switch (settings.authScheme) {
      case AuthScheme.bearerToken:
        if (settings.authValue.isNotEmpty) {
          headers['Authorization'] = 'Bearer ${settings.authValue}';
        }
        break;
      case AuthScheme.apiKeyHeader:
        if (settings.authValue.isNotEmpty) {
          headers['X-API-KEY'] = settings.authValue;
        }
        break;
      case AuthScheme.none:
        break;
    }

    _dio.options.headers = headers;

    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('Dio error: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: false));
    }
  }
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref);
});
