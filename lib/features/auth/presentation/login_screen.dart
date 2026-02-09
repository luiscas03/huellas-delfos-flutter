import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'correo@ejemplo.com');
  final _passCtrl = TextEditingController(text: '******');

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SizedBox(
            width: 420,
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Iniciar Sesión',
                    subtitle: 'Ingresa tus credenciales para continuar',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Correo electrónico'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(
                            hintText: 'correo@ejemplo.com',
                            prefixIcon: const Icon(Icons.mail_outline, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Contraseña'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.recover),
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: auth.loading
                              ? null
                              : () async {
                                  await ref.read(authControllerProvider.notifier).signIn(
                                        _emailCtrl.text.trim(),
                                        _passCtrl.text.trim(),
                                      );
                                  if (context.mounted) context.go(AppRoutes.dashboard);
                                },
                          child: auth.loading ? const CircularProgressIndicator() : const Text('Iniciar Sesión'),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('O CONTINÚA CON', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                          icon: const Icon(Icons.g_mobiledata, size: 22),
                          label: const Text('Continuar con Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta? '),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.register),
                              child: const Text('Regístrate'),
                            ),
                          ],
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: 8),
                          Text(auth.error!, style: const TextStyle(color: AppColors.danger)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
