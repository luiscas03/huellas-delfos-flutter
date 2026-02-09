import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_colors.dart';
import 'identify_patient_controller.dart';

class IdentifyPatientScreen extends ConsumerStatefulWidget {
  const IdentifyPatientScreen({super.key});

  @override
  ConsumerState<IdentifyPatientScreen> createState() => _IdentifyPatientScreenState();
}

class _IdentifyPatientScreenState extends ConsumerState<IdentifyPatientScreen> {
  final _docCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(identifyControllerProvider);
    final digits = _docCtrl.text.replaceAll(RegExp(r'\D'), '');
    final isValid = digits.length >= 4 && digits.length <= 15;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                                    controller: _docCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(15),
                                    ],
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: '1234567890',
                                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: IconButton(
                                    onPressed: isValid
                                        ? () async {
                                            ref.read(identifyControllerProvider.notifier).setCurrentDocument(digits);
                                            await ref.read(identifyControllerProvider.notifier).searchByDocument(digits);
                                            if (context.mounted) context.go(AppRoutes.identifyFilled);
                                          }
                                        : null,
                                    icon: const Icon(Icons.search, color: Colors.white),
                                  ),
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
              const SizedBox(height: 26),
              SizedBox(
                width: 520,
                child: ElevatedButton(
                  onPressed: isValid
                      ? () async {
                          ref.read(identifyControllerProvider.notifier).setCurrentDocument(digits);
                          await ref.read(identifyControllerProvider.notifier).searchByDocument(digits);
                          if (context.mounted) context.go(AppRoutes.identifyFilled);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                    disabledBackgroundColor: AppColors.primarySoft,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Continuar a la Visita'),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (state.error != null) ...[
                const SizedBox(height: 8),
                Text(state.error!, style: const TextStyle(color: AppColors.danger)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
