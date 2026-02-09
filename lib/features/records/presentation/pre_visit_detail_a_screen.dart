import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import 'widgets/stepper_bar.dart';
import 'identify_patient_controller.dart';

class PreVisitDetailAScreen extends ConsumerWidget {
  const PreVisitDetailAScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identify = ref.watch(identifyControllerProvider);
    final data = identify.interviewee ?? {};
    final fullName = (data['full_name'] ?? '').toString().trim();
    final documentId = (identify.currentDocument ?? data['document_id'] ?? '').toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const StepperBar(current: 1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _patientCard(fullName, documentId),
            const SizedBox(height: 16),
            SizedBox(
              width: 520,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.preVisitDetailB),
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _patientCard(String fullName, String documentId) {
    final nameText = fullName.isEmpty ? '—' : fullName;
    final docText = documentId.isEmpty ? '—' : documentId;
    return SizedBox(
      width: 520,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person_outline, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nameText, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('CC: $docText', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text('Datos manuales', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _availabilityCard() {
    return const SizedBox.shrink();
  }
}
