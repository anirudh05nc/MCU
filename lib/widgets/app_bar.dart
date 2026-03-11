import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_styles/app_colors.dart';
import '../app_styles/app_text_styles.dart';
import '../providers/theme_provider.dart';

class AppAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String name;

  const AppAppBar({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkTheme = ref.watch(themeProvider);
    final appColors = ref.watch(appColorsProvider);


    final appTextStyles = ref.watch(appTextStylesProvider);

    return AppBar(
      title: Text(
        name,
        style: appTextStyles.mainHeading,
      ),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: appColors.gold,
      ),
      actions: [
        IconButton(
          icon: Icon(
            darkTheme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: appColors.gold,
          ),
          onPressed: () {
            ref.read(themeProvider.notifier).changeTheme();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
