import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import 'app_colors.dart';


final appButtonsProvider = Provider<AppButtons>((ref) {
  final darkTheme = ref.watch(themeProvider);
  final appColors = ref.watch(appColorsProvider);
  return AppButtons(darkTheme: darkTheme, appColors: appColors);
});

class AppButtons{
  final bool darkTheme;
  final dynamic appColors;



  AppButtons({required this.darkTheme, required this.appColors});

  ButtonStyle get themeButton => ElevatedButton.styleFrom(
    backgroundColor: appColors.gold,
    elevation: 5,
  );

  ButtonStyle get themeOutlinedButton => OutlinedButton.styleFrom(
    backgroundColor: appColors.secondary,
    elevation: 5,
    shadowColor: Colors.black,
    side: BorderSide(
      color: appColors.gold,
      width: 2,
    ),
  );

}