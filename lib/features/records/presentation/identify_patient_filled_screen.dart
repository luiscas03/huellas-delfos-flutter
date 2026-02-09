import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_colors.dart';
import 'identify_patient_controller.dart';

class IdentifyPatientFilledScreen extends ConsumerStatefulWidget {
  const IdentifyPatientFilledScreen({super.key});

  @override
  ConsumerState<IdentifyPatientFilledScreen> createState() => _IdentifyPatientFilledScreenState();
}

class _IdentifyPatientFilledScreenState extends ConsumerState<IdentifyPatientFilledScreen> {
  final _nameCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _lastLoadedId;

  String _firstOrEmpty(String input) {
    final parts = input.trim().split(' ');
    return parts.isEmpty ? '' : parts.first;
  }

  void _applyData(Map<String, dynamic> data, String? currentDocument) {
    final currentId = (data['id']?.toString().isNotEmpty ?? false)
        ? data['id'].toString()
        : (currentDocument ?? data['document_id']?.toString() ?? '');
    if (currentId.isEmpty || currentId == _lastLoadedId) return;
    final fullName = (data['full_name'] ?? '').toString();
    _nameCtrl.text = _firstOrEmpty(fullName);
    _lastCtrl.text = fullName.split(' ').skip(1).join(' ');
    _phoneCtrl.text = (data['phone'] ?? '').toString();
    _lastLoadedId = currentId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(identifyControllerProvider);
    final data = state.interviewee ?? {};
    ref.listen<IdentifyState>(identifyControllerProvider, (prev, next) {
      final data = next.interviewee;
      if (data == null) return;
      _applyData(Map<String, dynamic>.from(data), next.currentDocument);
    });
    if (data.isNotEmpty) {
      _applyData(Map<String, dynamic>.from(data), state.currentDocument);
    }
    // Debug temporal
    final documentId = state.currentDocument ?? (data['document_id'] ?? '').toString();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              SizedBox(
                width: 520,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.of(context).maybePop(),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Color(0x338EC2DF),
                                    child: Icon(Icons.arrow_back, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0x338EC2DF),
                                  child: Text('1', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 6),
                                const Text('de 3', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text('Identificar Paciente', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text('Ingresa la cédula para buscar datos', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Número de Cédula'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: documentId.isEmpty ? '1102317287' : documentId,
                                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                                      filled: true,
                                      fillColor: const Color(0xFFE6F0FF),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.search, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Ingresa la cédula y presiona buscar para obtener datos del paciente',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 520,
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Datos del paciente', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Nombre',
                                hintText: (data['full_name'] ?? 'JUAN').toString().split(' ').first,
                                prefixIcon: const Icon(Icons.person_outline, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _lastCtrl,
                              decoration: InputDecoration(
                                labelText: 'Apellido',
                                hintText: (data['full_name'] ?? 'PÉREZ').toString().split(' ').skip(1).join(' '),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          hintText: (data['phone'] ?? '3001234567').toString(),
                          prefixIcon: const Icon(Icons.phone, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: documentId.isEmpty
                            ? null
                            : () async {
                                if (state.interviewee == null) {
                                  await ref.read(identifyControllerProvider.notifier).createInterviewee({
                                    'document_id': documentId,
                                    'full_name': '${_nameCtrl.text.trim()} ${_lastCtrl.text.trim()}'.trim(),
                                    'phone': _phoneCtrl.text.trim(),
                                  });
                                }
                                if (context.mounted) context.go(AppRoutes.preVisitStepper);
                              },
                        child: Text(state.interviewee == null ? 'Crear y continuar' : 'Continuar'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}
