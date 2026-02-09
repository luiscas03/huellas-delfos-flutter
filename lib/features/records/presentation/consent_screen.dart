import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';

import 'visit_draft_controller.dart';
import 'identify_patient_controller.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: AppColors.textPrimary,
  );
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (!_hasSignature && _controller.isNotEmpty) {
        setState(() => _hasSignature = true);
      }
    });
  }

  Future<void> _saveSignature() async {
    final bytes = await _controller.toPngBytes();
    if (bytes == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'records', 'temp', 'signature'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final file = File(p.join(folder.path, 'signature.png'));
    await file.writeAsBytes(bytes);
    ref.read(visitDraftProvider.notifier).setSignaturePath(file.path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identify = ref.watch(identifyControllerProvider);
    final data = identify.interviewee ?? {};
    final fullName = (data['full_name'] ?? '').toString().trim();
    final documentId = (identify.currentDocument ?? data['document_id'] ?? '').toString();
    final nameText = fullName.isEmpty ? '——' : fullName;
    final docText = documentId.isEmpty ? '——' : documentId;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.description_outlined, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            const Text('Estudio de Biomarcadores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            const Text('Participación en investigación clínica', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 14),
            SizedBox(
              width: 520,
              child: AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yo, $nameText, identificado(a) con cédula $docText, declaro que he sido informado(a) sobre el propósito de este estudio y autorizo voluntariamente:',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _checkRow('La grabación de audio de esta entrevista'),
                    _checkRow('La captura de fotografías durante la visita'),
                    _checkRow('El registro de mi ubicación geográfica'),
                    _checkRow('El uso de mi información para investigación'),
                    const SizedBox(height: 12),
                    const Text(
                      'Entiendo que mi participación es completamente voluntaria, que puedo retirarme en cualquier momento, que mis datos serán tratados de forma confidencial y que los resultados podrán ser publicados de forma anónima.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    const Text('He tenido la oportunidad de hacer preguntas y han sido respondidas satisfactoriamente.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 520,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Firma del participante', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primarySoft, style: BorderStyle.solid),
                    ),
                    child: Signature(
                      controller: _controller,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(child: Text('Firme dentro del recuadro', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: _controller.clear, child: const Text('Limpiar')),
                const SizedBox(width: 10),
                TextButton(onPressed: _saveSignature, child: const Text('Guardar')),
                const SizedBox(width: 10),
                TextButton(onPressed: () => setState(() => _hasSignature = false), child: const Text('Rehacer')),
              ],
            ),
            const SizedBox(height: 8),
            const Text('06 de febrero 2026, 09:54:07', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(
              width: 520,
              child: ElevatedButton.icon(
                onPressed: _hasSignature
                    ? () async {
                        await _saveSignature();
                        if (context.mounted) context.go(AppRoutes.recordingActive);
                      }
                    : null,
                icon: const Icon(Icons.check),
                label: const Text('Autorizo y Continuar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarySoft,
                  disabledBackgroundColor: AppColors.primarySoft,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text('El participante debe firmar para continuar', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  static Widget _checkRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
