import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import 'widgets/image_picker_grid.dart';
import 'recording_service.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/permissions.dart';
import 'recording_controller.dart';
import 'visit_draft_controller.dart';
import 'identify_patient_controller.dart';

class RecordingActiveScreen extends ConsumerStatefulWidget {
  const RecordingActiveScreen({super.key});

  @override
  ConsumerState<RecordingActiveScreen> createState() => _RecordingActiveScreenState();
}

class _RecordingActiveScreenState extends ConsumerState<RecordingActiveScreen> {
  final RecordingService _recordingService = RecordingService();
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final granted = await PermissionsHelper.requestMic(context);
    if (!granted) return;
    await _recordingService.start();
    setState(() => _isRecording = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stop() async {
    final segment = await _recordingService.stop();
    _timer?.cancel();
    setState(() => _isRecording = false);
    if (segment != null) {
      ref.read(recordingControllerProvider.notifier).addSegment(segment);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identify = ref.watch(identifyControllerProvider);
    final data = identify.interviewee ?? {};
    final fullName = (data['full_name'] ?? '').toString().trim();
    final nameText = fullName.isEmpty ? '—' : fullName;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.consent),
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
          const Chip(
            label: Text('Pantalla activa', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D6F))),
            backgroundColor: Color(0xFFCFEFE1),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.recordingInactive),
            child: const Text('Simular inactiva'),
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
              Text(_format(_elapsed), style: const TextStyle(fontSize: 36, color: AppColors.danger, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.surface,
                    child: IconButton(
                      onPressed: _isRecording ? _stop : _start,
                      icon: Icon(_isRecording ? Icons.pause : Icons.play_arrow, color: AppColors.textSecondary),
                    ),
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

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '00:$m:$s';
  }
}
