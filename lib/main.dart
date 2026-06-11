import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/theme.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cloud sync is optional — the app is fully functional offline.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
  } catch (_) {}
  runApp(const ProviderScope(child: SafeWearApp()));
}

class SafeWearApp extends StatelessWidget {
  const SafeWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SafeWear',
      theme: buildSafeWearTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
