import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/network/supabase_tables.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/current_user_provider.dart';
import '../../records/data/edge_functions_repository.dart';

class ManualUploadScreen extends ConsumerStatefulWidget {
  const ManualUploadScreen({super.key});

  @override
  ConsumerState<ManualUploadScreen> createState() => _ManualUploadScreenState();
}

class _ManualUploadScreenState extends ConsumerState<ManualUploadScreen> {
  final _sessionIdCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();

  File? _consentFile;
  File? _audioFile;
  final List<File> _photos = [];
  bool _loading = false;

  Future<String?> _uploadFile(String bucket, File file, String folder) async {
    final client = ref.read(supabaseProvider);
    final fileName = p.basename(file.path);
    final objectPath = '$folder/$fileName';
    await client.storage.from(bucket).upload(objectPath, file, fileOptions: const FileOptions(upsert: true));
    return client.storage.from(bucket).getPublicUrl(objectPath);
  }

  Future<void> _pickConsent() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (res?.files.single.path == null) return;
    setState(() => _consentFile = File(res!.files.single.path!));
  }

  Future<void> _pickAudio() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: false);
    if (res?.files.single.path == null) return;
    setState(() => _audioFile = File(res!.files.single.path!));
  }

  Future<void> _pickPhotos() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
    if (res?.files.isEmpty ?? true) return;
    setState(() => _photos.addAll(res!.files.where((f) => f.path != null).map((f) => File(f.path!))));
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final visitor = await ref.read(currentVisitorProvider.future);
      final visitorId = (visitor?['id'] ?? '').toString();
      final folder = _sessionIdCtrl.text.isNotEmpty ? _sessionIdCtrl.text.trim() : DateTime.now().millisecondsSinceEpoch.toString();

      String? consentUrl;
      String? consentPath;
      if (_consentFile != null) {
        consentUrl = await _uploadFile(SupabaseBuckets.signatures, _consentFile!, folder);
        consentPath = consentUrl;
      }
      String? audioUrl;
      if (_audioFile != null) {
        audioUrl = await _uploadFile(SupabaseBuckets.audio, _audioFile!, folder);
      }
      final photoUrls = <String>[];
      for (final photo in _photos) {
        final url = await _uploadFile(SupabaseBuckets.visitPhotos, photo, folder);
        if (url != null) photoUrls.add(url);
      }

      final payload = {
        'sessionId': _sessionIdCtrl.text.trim(),
        'patient': {
          'cedula': _cedulaCtrl.text.trim(),
          'nombre': _nombreCtrl.text.trim(),
          'apellido': _apellidoCtrl.text.trim(),
          'telefono': _telefonoCtrl.text.trim(),
          'direccion': _direccionCtrl.text.trim(),
          'ciudad': _ciudadCtrl.text.trim(),
          'dataSource': 'manual',
        },
        'visitorId': visitorId,
        'visit': {
          'date': DateTime.now().toIso8601String().split('T').first,
          'time': TimeOfDay.now().format(context),
          'geoAddress': _direccionCtrl.text.trim(),
          'isCompleted': true,
          'notAvailableReason': null,
        },
        'files': {
          'consentUrl': consentUrl,
          'consentPath': consentPath,
          'audioUrl': audioUrl,
          'photoUrls': photoUrls,
        }
      };

      final res = await ref.read(edgeFunctionsRepositoryProvider).saveManualVisit(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']?.toString() ?? 'Visita guardada')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Cargar Visita Manual', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
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
                    const Text('Datos del paciente', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(controller: _cedulaCtrl, decoration: const InputDecoration(hintText: 'Cédula')),
                    const SizedBox(height: 8),
                    TextField(controller: _nombreCtrl, decoration: const InputDecoration(hintText: 'Nombre')),
                    const SizedBox(height: 8),
                    TextField(controller: _apellidoCtrl, decoration: const InputDecoration(hintText: 'Apellido')),
                    const SizedBox(height: 8),
                    TextField(controller: _telefonoCtrl, decoration: const InputDecoration(hintText: 'Teléfono')),
                    const SizedBox(height: 8),
                    TextField(controller: _direccionCtrl, decoration: const InputDecoration(hintText: 'Dirección')),
                    const SizedBox(height: 8),
                    TextField(controller: _ciudadCtrl, decoration: const InputDecoration(hintText: 'Ciudad')),
                    const SizedBox(height: 8),
                    TextField(controller: _sessionIdCtrl, decoration: const InputDecoration(hintText: 'SessionId (opcional)')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 520,
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Archivos', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: _pickConsent, child: Text(_consentFile == null ? 'Subir consentimiento' : 'Consentimiento seleccionado')),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: _pickAudio, child: Text(_audioFile == null ? 'Subir audio' : 'Audio seleccionado')),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: _pickPhotos, child: Text(_photos.isEmpty ? 'Subir fotos' : '${_photos.length} foto(s) seleccionadas')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 520,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : const Text('Guardar visita'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
