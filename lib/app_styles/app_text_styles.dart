import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';

final appTextStylesProvider = Provider<AppTextStyles>((ref) {
  final colorProvider = ref.watch(appColorsProvider);
  return AppTextStyles(colorProvider: colorProvider);
});


class AppTextStyles{
  final colorProvider;

  AppTextStyles({required this.colorProvider});

  TextStyle get mainHeading => TextStyle(
    color: colorProvider.textPrimary,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
}