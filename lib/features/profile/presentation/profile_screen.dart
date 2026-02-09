import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_tables.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/current_user_provider.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _docCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Perfil', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            SizedBox(
              width: 520,
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: profileAsync.when(
                  data: (p) {
                    if (!_loaded && p != null) {
                      _nameCtrl.text = (p['full_name'] ?? '').toString();
                      _docCtrl.text = (p['document_id'] ?? '').toString();
                      _phoneCtrl.text = (p['phone'] ?? '').toString();
                      _loaded = true;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nombre', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(controller: _nameCtrl),
                        const SizedBox(height: 10),
                        const Text('Documento', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(controller: _docCtrl),
                        const SizedBox(height: 10),
                        const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(controller: _phoneCtrl),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final user = Supabase.instance.client.auth.currentUser;
                            if (user == null) return;
                            await Supabase.instance.client.from(SupabaseTables.profiles).update({
                              'full_name': _nameCtrl.text.trim(),
                              'document_id': _docCtrl.text.trim(),
                              'phone': _phoneCtrl.text.trim(),
                            }).eq('id', user.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
                            }
                          },
                          child: const Text('Guardar'),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 520,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (mounted) Navigator.of(context).pop();
                },
                child: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
