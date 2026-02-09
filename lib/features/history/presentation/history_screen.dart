import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_tables.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../records/data/edge_functions_repository.dart';

final historyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = Supabase.instance.client;
  final res = await client.from(SupabaseTables.recordingSessions).select().order('created_at', ascending: false).limit(100);
  return res.cast<Map<String, dynamic>>();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Historial', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: historyAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return const Text('No tienes visitas registradas aún', style: TextStyle(color: AppColors.textSecondary));
            }
            return Column(
              children: list.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: 520,
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sesión ${item['id']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Estado: ${item['status'] ?? ''}', style: const TextStyle(color: AppColors.textSecondary)),
                                Text('Duración: ${item['duration_seconds'] ?? 0}s', style: const TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final edge = ref.read(edgeFunctionsRepositoryProvider);
                              await edge.syncGoogleSheets({
                                'action': 'delete',
                                'session': {
                                  'id': item['id'],
                                  'duration_seconds': item['duration_seconds'] ?? 0,
                                  'audio_url': item['audio_url'],
                                  'photos_urls': item['photos_urls'] ?? [],
                                  'status': item['status'],
                                  'interview_completed': item['interview_completed'] ?? false,
                                  'not_available_reason': item['not_available_reason'],
                                  'google_drive_url': item['google_drive_url'],
                                }
                              });
                              await Supabase.instance.client
                                  .from(SupabaseTables.recordingSessions)
                                  .delete()
                                  .eq('id', item['id']);
                              ref.invalidate(historyProvider);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
        ),
      ),
    );
  }
}
