import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import 'widgets/image_picker_grid.dart';
import 'visit_draft_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'identify_patient_controller.dart';

class PreVisitDetailBScreen extends ConsumerStatefulWidget {
  const PreVisitDetailBScreen({super.key});

  @override
  ConsumerState<PreVisitDetailBScreen> createState() => _PreVisitDetailBScreenState();
}

class _PreVisitDetailBScreenState extends ConsumerState<PreVisitDetailBScreen> {
  final _addressCtrl = TextEditingController();
  String _coords = '';
  StreamSubscription<Position>? _posSub;
  bool _hasPreloaded = false;

  @override
  void initState() {
    super.initState();
    final interviewee = ref.read(identifyControllerProvider).interviewee;
    if (interviewee != null) {
      final lat = interviewee['latitude']?.toString();
      final lng = interviewee['longitude']?.toString();
      final address = interviewee['address']?.toString() ?? '';
      if ((lat != null && lat.isNotEmpty) && (lng != null && lng.isNotEmpty)) {
        _coords = 'Lat: ${lat}, Lng: ${lng}';
        _addressCtrl.text = address.isNotEmpty ? address : _coords;
        _hasPreloaded = true;
      }
    }
    if (!_hasPreloaded) {
      _getLocation();
    }
  }

  Future<void> _getLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) return;
    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((pos) {
      setState(() {
        _coords = 'Lat: ${pos.latitude.toStringAsFixed(6)}, Lng: ${pos.longitude.toStringAsFixed(6)}';
        _addressCtrl.text = _coords;
      });
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.preVisitDetailA),
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _patientCard(),
            const SizedBox(height: 14),
            _geoCard(),
            const SizedBox(height: 14),
            _facadeCard(),
            const SizedBox(height: 14),
            _availabilityCard(),
            const SizedBox(height: 16),
            SizedBox(
              width: 520,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.consent),
                child: const Text('Continuar a consentimiento'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientCard() {
    final identify = ref.watch(identifyControllerProvider);
    final data = identify.interviewee ?? {};
    final fullName = (data['full_name'] ?? '').toString().trim();
    final documentId = (identify.currentDocument ?? data['document_id'] ?? '').toString();
    final phone = (data['phone'] ?? '').toString().trim();
    final nameText = fullName.isEmpty ? '—' : fullName;
    final docText = documentId.isEmpty ? '—' : documentId;
    final phoneText = phone.isEmpty ? '—' : phone;
    return SizedBox(
      width: 520,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person_outline, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nameText, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('CC: $docText', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const Spacer(),
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
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(phoneText, style: const TextStyle(color: AppColors.textSecondary)),
                const Spacer(),
                const _ArriveButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _geoCard() {
    return SizedBox(
      width: 520,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.place_outlined, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text('Geolocalización'),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                onPressed: _getLocation,
                icon: const Icon(Icons.navigation, size: 18),
                label: const Text('Obtener mi ubicación'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Dirección exacta'),
            const SizedBox(height: 6),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(hintText: 'Escribe la dirección completa...'),
            ),
            if (_coords.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(_coords, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _facadeCard() {
    return SizedBox(
      width: 520,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text('Foto de fachada *'),
              ],
            ),
            const SizedBox(height: 10),
            ImagePickerGrid(
              title: 'Tomar Foto',
              onAdd: (file) => ref.read(visitDraftProvider.notifier).addImage(file),
              onRemove: (file) => ref.read(visitDraftProvider.notifier).removeImage(file),
            ),
            const SizedBox(height: 8),
            const Text('Obligatorio: Toma una foto de la fachada de la vivienda', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  static Widget _availabilityCard() {
    return SizedBox(
      width: 520,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('¿La persona está disponible?', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB7E5DA), foregroundColor: const Color(0xFF2E7D6F)),
                icon: const Icon(Icons.person_outline),
                label: const Text('Sí, iniciar entrevista'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFC7B46B)),
                icon: const Icon(Icons.person_off_outlined),
                label: const Text('Persona no disponible'),
              ),
            ),
            const SizedBox(height: 6),
            const Text('Toma una foto de fachada para continuar', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ArriveButton extends StatelessWidget {
  const _ArriveButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3CBF73),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_on, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text('Avisar llegada', style: TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}
