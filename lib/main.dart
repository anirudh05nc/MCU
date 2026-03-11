import 'package:excel/providers/user_provider.dart';
import 'package:excel/screens/auth/login_screen.dart';
import 'package:excel/screens/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/waste_item.dart';
import 'firebase_options.dart';

import 'app_styles/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(WasteItemAdapter());

  runApp(
    ProviderScope(
      child: const MyApp()
    )
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final colorProvider = ref.watch(appColorsProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Excel Project',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colorProvider.primary),
      ),
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, stack) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
      routes: {
        // '/dashboard': (context) => const DashboardScreen(), 
      },
    );
  }
}

