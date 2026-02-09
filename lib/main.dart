import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/network/supabase_client.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'features/sync/presentation/sync_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientProvider.init();
  runApp(const ProviderScope(child: HuellasApp()));
}

class HuellasApp extends ConsumerWidget {
  const HuellasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).settings;
    ref.watch(syncControllerProvider);
    if (settings.keepScreenAwake) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Huellas del FOS',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
