import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme buildTextTheme(TextTheme base) {
  final poppins = GoogleFonts.poppinsTextTheme(base);
  return poppins.copyWith(
    titleLarge: poppins.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    titleMedium: poppins.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: poppins.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: poppins.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
    bodyMedium: poppins.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
    bodySmall: poppins.bodySmall?.copyWith(fontWeight: FontWeight.w400),
    labelLarge: poppins.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    labelMedium: poppins.labelMedium?.copyWith(fontWeight: FontWeight.w500),
    labelSmall: poppins.labelSmall?.copyWith(fontWeight: FontWeight.w500),
  );
}
