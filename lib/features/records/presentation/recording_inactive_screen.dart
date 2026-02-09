import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import 'widgets/image_picker_grid.dart';
import 'visit_draft_controller.dart';
import 'identify_patient_controller.dart';

class RecordingInactiveScreen extends ConsumerWidget {
  const RecordingInactiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identify = ref.watch(identifyControllerProvider);
    final data = identify.interviewee ?? {};
    final fullName = (data['full_name'] ?? '').toString().trim();
    final nameText = fullName.isEmpty ? '—' : fullName;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.recordingActive),
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
          TextButton(
            onPressed: () => context.go(AppRoutes.recordingActive),
            child: const Text('Reactivar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Text('Opus    Segmento 1', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 8),
              const Text('00:31', style: TextStyle(fontSize: 36, color: AppColors.danger, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.pause, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 14),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.danger,
                    child: IconButton(
                      onPressed: () => context.go(AppRoutes.recordingSegments),
                      icon: const Icon(Icons.stop, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
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
            ],
          ),
        ),
      ),
    );
  }
}
