import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../records/data/edge_functions_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';

final scheduledVisitsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(edgeFunctionsRepositoryProvider).fetchScheduledVisits();
});

class MyJourneyScreen extends ConsumerStatefulWidget {
  const MyJourneyScreen({super.key});

  @override
  ConsumerState<MyJourneyScreen> createState() => _MyJourneyScreenState();
}

class _MyJourneyScreenState extends ConsumerState<MyJourneyScreen> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = '';

  @override
  Widget build(BuildContext context) {
    final scheduledAsync = ref.watch(scheduledVisitsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Mi Jornada', style: TextStyle(color: AppColors.textPrimary)),
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
                    const Text('Filtros', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(hintText: 'Buscar por cédula, barrio o responsable'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _statusFilter.isEmpty ? null : _statusFilter,
                      items: const [
                        DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                        DropdownMenuItem(value: 'Completado', child: Text('Completado')),
                        DropdownMenuItem(value: 'No Disponible', child: Text('No Disponible')),
                      ],
                      onChanged: (v) => setState(() => _statusFilter = v ?? ''),
                      decoration: const InputDecoration(hintText: 'Estado'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            scheduledAsync.when(
              data: (data) {
                final list = (data['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
                final filtered = list.where((item) {
                  final q = _searchCtrl.text.trim().toLowerCase();
                  final matchesQuery = q.isEmpty ||
                      (item['idPaciente']?.toString().toLowerCase().contains(q) ?? false) ||
                      (item['barrio']?.toString().toLowerCase().contains(q) ?? false) ||
                      (item['jiResponsable']?.toString().toLowerCase().contains(q) ?? false);
                  final matchesStatus = _statusFilter.isEmpty || (item['estado']?.toString() == _statusFilter);
                  return matchesQuery && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return const Text('No hay visitas programadas', style: TextStyle(color: AppColors.textSecondary));
                }

                return Column(
                  children: filtered.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: 520,
                        child: AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Paciente: ${item['idPaciente'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('Barrio: ${item['barrio'] ?? ''}', style: const TextStyle(color: AppColors.textSecondary)),
                              Text('Estado: ${item['estado'] ?? ''}', style: const TextStyle(color: AppColors.textSecondary)),
                              Text('Responsable: ${item['jiResponsable'] ?? ''}', style: const TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('Iniciar visita'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }
}
