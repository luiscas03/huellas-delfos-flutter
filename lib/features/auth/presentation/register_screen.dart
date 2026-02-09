import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
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
                    title: 'Crear Cuenta',
                    subtitle: 'Completa tus datos para registrarte',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton.icon(
                          onPressed: () => context.go(AppRoutes.login),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Volver al inicio de sesión'),
                          style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                        ),
                        const SizedBox(height: 8),
                        const Text('Nombre completo'),
                        const SizedBox(height: 8),
                        const TextField(decoration: InputDecoration(hintText: 'Juan Pérez')),
                        const SizedBox(height: 14),
                        const Text('Cédula'),
                        const SizedBox(height: 8),
                        const TextField(decoration: InputDecoration(hintText: '1234567890')),
                        const SizedBox(height: 14),
                        const Text('Correo electrónico'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(
                            hintText: 'correo@ejemplo.com',
                            prefixIcon: const Icon(Icons.mail_outline, size: 20),
                          ),
                        ),
                        const SizedBox(height: 14),
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
                        const SizedBox(height: 14),
                        const Text('Confirmar contraseña'),
                        const SizedBox(height: 8),
                        TextField(
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
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: auth.loading
                              ? null
                              : () async {
                                  await ref.read(authControllerProvider.notifier).signUp(
                                        _emailCtrl.text.trim(),
                                        _passCtrl.text.trim(),
                                      );
                                  if (context.mounted) context.go(AppRoutes.dashboard);
                                },
                          child: auth.loading ? const CircularProgressIndicator() : const Text('Crear Cuenta'),
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
                            const Text('¿Ya tienes cuenta? '),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: const Text('Inicia sesión'),
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
