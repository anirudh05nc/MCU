import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

final appColorsProvider = Provider<AppColors>((ref) {
  final darkTheme = ref.watch(themeProvider);
  return AppColors(darkTheme: darkTheme);
});

class AppColors {

  final bool darkTheme;

  AppColors({required this.darkTheme});

  Color get primary => darkTheme ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F5); // Charcoal Black
  Color get secondary => darkTheme ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F2); // Dark Gray

  Color get gold => const Color(0xFFC9A227); //0xFFFCA107 -> Orange Shade   0xFFC9A227 -> Muted Gold


  Color get background => darkTheme ? const Color(0xFF121212) : const Color(0xFFFAFAFA);  // True Dark
  Color get background2 => darkTheme ? Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);  // Card Surface

  Color get textPrimary => darkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1E);
  Color get textSecondary => darkTheme ? Color(0xFFB0B0B0) : const Color(0xFF616161);
  Color get divider => darkTheme ? Color(0xFF2A2A2A) : Color(0xFFE0E0E0);
  Color get iconColor => darkTheme ? Colors.white : Colors.black;
  Color get shadow => darkTheme ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2);

}
