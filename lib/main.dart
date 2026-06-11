import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app_state.dart';
import 'app/i18n.dart';
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

class SafeWearApp extends ConsumerWidget {
  const SafeWearApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appStateProvider);
    if (user != null) currentLang = user.language;
    final dark = ref.watch(darkModeProvider);
    SW.isDark = dark;

    return MaterialApp.router(
      // Changing the key tears down and rebuilds the whole tree, so every
      // widget re-reads the SW color tokens. GoRouter keeps the location.
      key: ValueKey('app-$dark-$currentLang'),
      title: 'SafeWear',
      theme: buildSafeWearTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Directionality(
        textDirection:
            isRtl(currentLang) ? TextDirection.rtl : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
