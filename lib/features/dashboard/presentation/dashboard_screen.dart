import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/current_user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../records/data/records_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<List<Map<String, dynamic>>> _loadStats() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      return [
        {'visitas': 0, 'entrevistas': 0, 'no_disponible': 0, 'tiempo': '00:00:00'}
      ];
    }
    final visitor = await client
        .from('visitors')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    final visitorId = visitor?['id'];
    final sessions = visitorId != null
        ? await client.from('recording_sessions').select().eq('visitor_id', visitorId).limit(100)
        : await client.from('recording_sessions').select().limit(100);
    final total = sessions.length;
    final completed = sessions.where((s) => s['interview_completed'] == true).length;
    final notAvailable = sessions.where((s) => s['not_available_reason'] != null).length;
    final seconds = sessions.fold<int>(0, (sum, s) => sum + (s['duration_seconds'] ?? 0) as int);
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return [
      {
        'visitas': total,
        'entrevistas': completed,
        'no_disponible': notAvailable,
        'tiempo': '$hours:$minutes:$secs',
      }
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final visitorAsync = ref.watch(currentVisitorProvider);
    final pendingAsync = ref.watch(_pendingCountProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileAsync.maybeWhen(
                    data: (p) => (p?['full_name'] as String?) ?? 'Usuario',
                    orElse: () => 'Usuario',
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  visitorAsync.maybeWhen(
                    data: (v) => 'Cédula: ${(v?['document_id'] as String?) ?? '—'}',
                    orElse: () => 'Cédula: —',
                  ),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.settings),
            icon: const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text('LB', style: TextStyle(color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(Icons.show_chart, size: 16, color: AppColors.primary),
                          ),
                          SizedBox(width: 8),
                          Text('Estadísticas', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list, size: 16),
                        label: const Text('Filtros'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: AppColors.border),
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _loadStats(),
                    builder: (context, snapshot) {
                      final data = snapshot.data ?? const [
                        {'visitas': 0, 'entrevistas': 0, 'no_disponible': 0, 'tiempo': '00:00:00'}
                      ];
                      final s = data.first;
                      return Column(
                        children: [
                          Row(
                            children: [
                              _statBlock(color: const Color(0xFFD8E4FF), label: 'Visitas', value: s['visitas'].toString(), icon: Icons.people_outline, iconColor: const Color(0xFF5A7DFF)),
                              const SizedBox(width: 10),
                              _statBlock(color: const Color(0xFFDDF2E7), label: 'Entrevistas', value: s['entrevistas'].toString(), icon: Icons.person_pin_circle_outlined, iconColor: const Color(0xFF3CBF73)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _statBlock(color: const Color(0xFFF9E5D6), label: 'No disponible', value: s['no_disponible'].toString(), icon: Icons.person_off_outlined, iconColor: const Color(0xFFE0944E)),
                              const SizedBox(width: 10),
                              _statBlock(
                                color: const Color(0xFFFFF1C9),
                                label: 'Sin sincronizar',
                                value: pendingAsync.maybeWhen(data: (v) => v.toString(), orElse: () => '0'),
                                icon: Icons.sync_problem,
                                iconColor: const Color(0xFFCC8A00),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F3FB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.schedule, color: AppColors.primary),
                                const SizedBox(width: 8),
                                const Text('Tiempo total', style: TextStyle(color: AppColors.textSecondary)),
                                const SizedBox(width: 12),
                                Text(s['tiempo'].toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text('No hay visitas para el filtro seleccionado', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                GestureDetector(
                  onTap: () => context.go(AppRoutes.identify),
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Nueva Visita', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => context.go(AppRoutes.myJourney),
                  child: _roundAction(Icons.calendar_today, 'Mi Jornada'),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.history),
                  child: _roundAction(Icons.history, 'Historial'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
              child: Column(
                children: const [
                  Icon(Icons.schedule, color: AppColors.textSecondary),
                  SizedBox(height: 6),
                  Text('No tienes visitas registradas aún'),
                  SizedBox(height: 2),
                  Text('Comienza creando una nueva visita', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('v1.4.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  static Widget _statBlock({
    required Color color,
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  static Widget _roundAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

final _pendingCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(recordsRepositoryProvider);
  final pending = await repo.getPendingSync();
  return pending.length;
});
