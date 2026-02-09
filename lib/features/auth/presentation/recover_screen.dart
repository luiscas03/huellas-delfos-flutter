import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/auth_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class RecoverScreen extends ConsumerStatefulWidget {
  const RecoverScreen({super.key});

  @override
  ConsumerState<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends ConsumerState<RecoverScreen> {
  final _emailCtrl = TextEditingController(text: 'correo@ejemplo.com');

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
                    title: 'Recuperar Contraseña',
                    subtitle: 'Te enviaremos un enlace para restablecer tu contraseña',
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
                        const Text('Correo electrónico'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(
                            hintText: 'correo@ejemplo.com',
                            prefixIcon: const Icon(Icons.mail_outline, size: 20),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: auth.loading
                              ? null
                              : () async {
                                  await ref.read(authControllerProvider.notifier).resetPassword(_emailCtrl.text.trim());
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Correo de recuperación enviado')),
                                    );
                                  }
                                },
                          child: auth.loading ? const CircularProgressIndicator() : const Text('Enviar Enlace'),
                        ),
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
