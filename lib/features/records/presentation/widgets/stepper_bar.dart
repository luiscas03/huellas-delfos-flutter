import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StepperBar extends StatelessWidget {
  const StepperBar({super.key, required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    const labels = ['Paciente', 'Pre-Visita', 'Consentimiento', 'Grabación', 'Cierre'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (i) {
        final active = i <= current;
        return Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: active ? AppColors.primary : AppColors.primaryLight,
              child: Icon(
                i == 0
                    ? Icons.check
                    : i == 1
                        ? Icons.location_on_outlined
                        : i == 2
                            ? Icons.description_outlined
                            : i == 3
                                ? Icons.mic_none
                                : Icons.check_circle_outline,
                size: 14,
                color: active ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(labels[i], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        );
      }),
    );
  }
}
