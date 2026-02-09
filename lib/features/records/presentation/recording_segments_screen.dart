import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import 'widgets/image_picker_grid.dart';
import 'widgets/audio_segment_tile.dart';
import 'recording_controller.dart';
import 'visit_draft_controller.dart';
import 'identify_patient_controller.dart';

class RecordingSegmentsScreen extends ConsumerWidget {
  const RecordingSegmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identify = ref.watch(identifyControllerProvider);
    final data = identify.interviewee ?? {};
    final fullName = (data['full_name'] ?? '').toString().trim();
    final nameText = fullName.isEmpty ? '—' : fullName;
    final segments = ref.watch(recordingControllerProvider).segments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.recordingInactive),
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grabación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(nameText, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.screen_lock_landscape, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text('Pantalla inactiva', style: TextStyle(fontSize: 11, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Text('Opus    Segmento 2', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 8),
              const Text('00:37', style: TextStyle(fontSize: 36, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Total: 00:37 · 1 segmento(s)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 12),
              SizedBox(
                width: 260,
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.recordingActive),
                  icon: const Icon(Icons.mic),
                  label: const Text('Continuar grabando'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 420,
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: ImagePickerGrid(
                    title: 'Fotos durante la entrevista',
                    onAdd: (file) => ref.read(visitDraftProvider.notifier).addImage(file),
                    onRemove: (file) => ref.read(visitDraftProvider.notifier).removeImage(file),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 420,
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Segmentos grabados', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      if (segments.isEmpty)
                        const Text('Aún no hay segmentos', style: TextStyle(color: AppColors.textSecondary))
                      else
                        ...segments.asMap().entries.map((entry) {
                          final index = entry.key;
                          final segment = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AudioSegmentTile(
                              segment: segment,
                              label: 'Segmento ${index + 1}',
                              onDelete: () => ref.read(recordingControllerProvider.notifier).removeAt(index),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 420,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.closure),
                  child: const Text('Finalizar grabación'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
