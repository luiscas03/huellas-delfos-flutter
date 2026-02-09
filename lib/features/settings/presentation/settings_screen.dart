import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/connection_settings.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _baseUrlController = TextEditingController();
  final _timeoutController = TextEditingController();
  final _authValueController = TextEditingController();
  final List<MapEntry<TextEditingController, TextEditingController>> _headers = [];
  AuthScheme _authScheme = AuthScheme.none;
  bool _keepAwake = true;
  bool _initialized = false;

  @override
  void dispose() {
    _baseUrlController.dispose();
    _timeoutController.dispose();
    _authValueController.dispose();
    for (final h in _headers) {
      h.key.dispose();
      h.value.dispose();
    }
    super.dispose();
  }

  void _load(SettingsState state) {
    final settings = state.settings;
    _baseUrlController.text = settings.baseUrl;
    _timeoutController.text = settings.timeoutSeconds.toString();
    _authValueController.text = settings.authValue;
    _authScheme = settings.authScheme;
    _keepAwake = settings.keepScreenAwake;
    _headers
      ..clear()
      ..addAll(settings.headers.entries.map((e) {
        return MapEntry(TextEditingController(text: e.key), TextEditingController(text: e.value));
      }));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);
    if (!_initialized) {
      _load(state);
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Configuración / Conexiones', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            SizedBox(
              width: 520,
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Base URL', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: _baseUrlController, decoration: const InputDecoration(hintText: 'https://api.tudominio.com')),
                    const SizedBox(height: 12),
                    const Text('Timeout (segundos)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: _timeoutController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '30')),
                    const SizedBox(height: 12),
                    const Text('Esquema de Auth', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<AuthScheme>(
                      value: _authScheme,
                      items: AuthScheme.values
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (value) => setState(() => _authScheme = value ?? AuthScheme.none),
                    ),
                    const SizedBox(height: 12),
                    const Text('Valor de Auth', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: _authValueController, decoration: const InputDecoration(hintText: 'Token / ApiKey')),
                    const SizedBox(height: 16),
                    const Text('Headers personalizados', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Column(
                      children: _headers
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(child: TextField(controller: e.key, decoration: const InputDecoration(hintText: 'Key'))),
                                  const SizedBox(width: 8),
                                  Expanded(child: TextField(controller: e.value, decoration: const InputDecoration(hintText: 'Value'))),
                                  IconButton(
                                    onPressed: () => setState(() => _headers.remove(e)),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _headers.add(MapEntry(TextEditingController(), TextEditingController()))),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar header'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _keepAwake,
                      onChanged: (value) => setState(() => _keepAwake = value),
                      title: const Text('Mantener pantalla activa'),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 6),
                    const Text('Accesos', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(onPressed: () => context.go(AppRoutes.myJourney), child: const Text('Mi Jornada')),
                        OutlinedButton(onPressed: () => context.go(AppRoutes.history), child: const Text('Historial')),
                        OutlinedButton(onPressed: () => context.go(AppRoutes.manualUpload), child: const Text('Cargar Visita')),
                        OutlinedButton(onPressed: () => context.go(AppRoutes.profile), child: const Text('Perfil')),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final headers = <String, String>{};
                          for (final h in _headers) {
                            if (h.key.text.trim().isEmpty) continue;
                            headers[h.key.text.trim()] = h.value.text.trim();
                          }
                          final settings = ConnectionSettings(
                            baseUrl: _baseUrlController.text.trim(),
                            timeoutSeconds: int.tryParse(_timeoutController.text.trim()) ?? 30,
                            headers: headers,
                            authScheme: _authScheme,
                            authValue: _authValueController.text.trim(),
                            keepScreenAwake: _keepAwake,
                          );
                          ref.read(settingsControllerProvider.notifier).save(settings);
                        },
                        child: state.loading ? const CircularProgressIndicator() : const Text('Guardar'),
                      ),
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: 6),
                      Text(state.error!, style: const TextStyle(color: AppColors.danger)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
