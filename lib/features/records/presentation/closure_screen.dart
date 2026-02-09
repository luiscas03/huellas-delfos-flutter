import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import 'widgets/image_picker_grid.dart';
import '../domain/record_entity.dart';
import '../presentation/records_controller.dart';
import '../../sync/presentation/sync_controller.dart';
import '../../auth/presentation/current_user_provider.dart';
import 'recording_controller.dart';
import 'visit_draft_controller.dart';
import '../../../core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'identify_patient_controller.dart';

class ClosureScreen extends ConsumerWidget {
  const ClosureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identify = ref.watch(identifyControllerProvider);
    final data = identify.interviewee ?? {};
    final fullName = (data['full_name'] ?? '').toString().trim();
    final documentId = (identify.currentDocument ?? data['document_id'] ?? '').toString();
    final nameText = fullName.isEmpty ? '—' : fullName;
    final docText = documentId.isEmpty ? '—' : documentId;
    final draft = ref.watch(visitDraftProvider);
    final segments = ref.watch(recordingControllerProvider).segments;
    final totalSeconds = segments.fold<int>(0, (sum, s) => sum + s.duration.inSeconds);
    final durationText = _formatDuration(totalSeconds);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.recordingSegments),
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        title: const Text('Cierre de Visita', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              SizedBox(
                width: 520,
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Resumen de la visita', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Text('Paciente:\n$nameText', style: const TextStyle(fontSize: 12))),
                          Expanded(child: Text('Cédula:\n$docText', style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text('Segmentos de audio:\n${segments.length}', style: const TextStyle(fontSize: 12))),
                          Expanded(child: Text('Duración total:\n$durationText', style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 520,
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.success,
                            child: Icon(Icons.description, size: 14, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text('Consentimiento registrado', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('06 de febrero 2026, 09:54', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: draft.signaturePath == null
                            ? const Center(child: Text('Firma'))
                            : Image.file(File(draft.signaturePath!), fit: BoxFit.contain),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 520,
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: const ImagePickerGrid(title: 'Fotos adicionales (opcional)'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Al confirmar, se subirán el audio, las fotos y la firma a la nube y se sincronizarán con Google Sheets.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 520,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final connectivity = await Connectivity().checkConnectivity();
                    final isOnline = connectivity != ConnectivityResult.none;
                    Map<String, dynamic>? visitor;
                    Map<String, dynamic>? profile;
                    try {
                      visitor = await ref.read(currentVisitorProvider.future).timeout(const Duration(seconds: 2));
                    } catch (_) {
                      visitor = null;
                    }
                    try {
                      profile = await ref.read(currentProfileProvider.future).timeout(const Duration(seconds: 2));
                    } catch (_) {
                      profile = null;
                    }
                    try {
                      final totalDuration = segments.fold<int>(0, (sum, s) => sum + s.duration.inSeconds);
                      final nameParts = fullName.split(' ').where((p) => p.isNotEmpty).toList();
                      final nombre = nameParts.isEmpty ? '' : nameParts.first;
                      final apellido = nameParts.length <= 1 ? '' : nameParts.sublist(1).join(' ');
                      final record = RecordEntity(
                        status: isOnline ? RecordStatus.synced : RecordStatus.pending,
                        createdAt: DateTime.now(),
                        patientId: docText,
                        patientName: nameText,
                        payload: {
                          'interviewee': {
                            'nombre': nombre,
                            'apellido': apellido,
                            'cedula': docText,
                            'telefono': (data['phone'] ?? '').toString(),
                            'address': (data['address'] ?? '').toString(),
                            'city': (data['city'] ?? '').toString(),
                            'latitude': data['latitude'],
                            'longitude': data['longitude'],
                          },
                          'visitor': {
                            'id': (visitor?['id'] ?? profile?['external_visitor_id'] ?? '').toString(),
                            'full_name': (visitor?['full_name'] ?? profile?['full_name'] ?? '').toString(),
                            'document_id': (visitor?['document_id'] ?? profile?['document_id'] ?? '').toString(),
                            'email': (visitor?['email'] ?? profile?['email'] ?? '').toString(),
                          },
                          'session': {
                            'duration_seconds': totalDuration,
                            'audio_url': null,
                            'audio_segments': segments
                                .map((s) => {'path': s.path, 'duration': s.duration.inSeconds})
                                .toList(),
                            'photos_urls': [],
                            'status': 'completed',
                            'not_available_reason': null,
                            'interview_completed': true,
                            'signature_url': null,
                          },
                          'local_files': {
                            'audio': segments.map((s) => s.path).toList(),
                            'images': draft.images.map((f) => f.path).toList(),
                            'signature': draft.signaturePath ?? '',
                          }
                        },
                      );
                      final id = await ref.read(recordsControllerProvider.notifier).createRecord(record);
                      for (final img in draft.images) {
                        if (await img.exists()) {
                          await ref.read(recordsControllerProvider.notifier).addMedia(
                            recordId: id,
                            type: MediaType.image,
                            file: img,
                          );
                        }
                      }
                      for (final seg in segments) {
                        final file = File(seg.path);
                        if (await file.exists()) {
                          await ref.read(recordsControllerProvider.notifier).addMedia(
                            recordId: id,
                            type: MediaType.audio,
                            file: file,
                            durationMs: seg.duration.inMilliseconds,
                          );
                        }
                      }
                      if (draft.signaturePath != null) {
                        final sigFile = File(draft.signaturePath!);
                        if (await sigFile.exists()) {
                          await ref.read(recordsControllerProvider.notifier).addMedia(
                            recordId: id,
                            type: MediaType.signature,
                            file: sigFile,
                          );
                        }
                      }
                      await ref.read(recordsControllerProvider.notifier).addPendingSync(id, record.payload);
                      if (isOnline) {
                        ref.read(syncControllerProvider.notifier).syncPending();
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isOnline ? 'Registro sincronizado' : 'Registro pendiente de sincronizar')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se pudo finalizar: $e')),
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        context.go(AppRoutes.dashboard);
                      }
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar y Finalizar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '00:$m:$s';
  }
}
