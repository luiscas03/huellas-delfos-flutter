import 'dart:convert';

enum AuthScheme { none, bearerToken, apiKeyHeader }

class ConnectionSettings {
  final String baseUrl;
  final int timeoutSeconds;
  final Map<String, String> headers;
  final AuthScheme authScheme;
  final String authValue;
  final bool keepScreenAwake;

  const ConnectionSettings({
    required this.baseUrl,
    required this.timeoutSeconds,
    required this.headers,
    required this.authScheme,
    required this.authValue,
    required this.keepScreenAwake,
  });

  ConnectionSettings copyWith({
    String? baseUrl,
    int? timeoutSeconds,
    Map<String, String>? headers,
    AuthScheme? authScheme,
    String? authValue,
    bool? keepScreenAwake,
  }) {
    return ConnectionSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      headers: headers ?? this.headers,
      authScheme: authScheme ?? this.authScheme,
      authValue: authValue ?? this.authValue,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
    );
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'timeoutSeconds': timeoutSeconds,
        'headers': headers,
        'authScheme': authScheme.name,
        'authValue': authValue,
        'keepScreenAwake': keepScreenAwake,
      };

  factory ConnectionSettings.fromJson(Map<String, dynamic> json) {
    return ConnectionSettings(
      baseUrl: json['baseUrl'] ?? '',
      timeoutSeconds: json['timeoutSeconds'] ?? 30,
      headers: Map<String, String>.from(json['headers'] ?? {}),
      authScheme: AuthScheme.values.firstWhere(
        (e) => e.name == (json['authScheme'] ?? 'none'),
        orElse: () => AuthScheme.none,
      ),
      authValue: json['authValue'] ?? '',
      keepScreenAwake: json['keepScreenAwake'] ?? true,
    );
  }

  String toRawJson() => jsonEncode(toJson());
  factory ConnectionSettings.fromRawJson(String raw) =>
      ConnectionSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  static const defaults = ConnectionSettings(
    baseUrl: '',
    timeoutSeconds: 30,
    headers: {},
    authScheme: AuthScheme.none,
    authValue: '',
    keepScreenAwake: true,
  );
}
