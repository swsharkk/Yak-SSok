import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/behavior_observer.dart';
import 'core/theme.dart';
import 'models/adaptive_ui_settings.dart';
import 'providers/adaptive_ui_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/guardian/guardian_main_screen.dart';
import 'screens/main_screen.dart';
import 'services/backend_auth_service.dart';
import 'services/behavior_log_service.dart';

class YakssokApp extends ConsumerStatefulWidget {
  const YakssokApp({super.key});

  @override
  ConsumerState<YakssokApp> createState() => _YakssokAppState();
}

class _YakssokAppState extends ConsumerState<YakssokApp> {
  late final BehaviorNavigatorObserver _behaviorObserver;

  @override
  void initState() {
    super.initState();
    _behaviorObserver = BehaviorNavigatorObserver(
      onEvent: (event) =>
          ref.read(behaviorLogServiceProvider.notifier).logEvent(event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(adaptiveUIControllerProvider).valueOrNull ??
        const AdaptiveUISettings();

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: settings.highContrast ? AppTheme.highContrast : AppTheme.light,
      navigatorObservers: [_behaviorObserver],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(settings.textScale),
        ),
        child: child!,
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  static Future<String?> _resolveRoute() async {
    final hasSession = await BackendAuthService.hasSession();
    if (!hasSession) return null;
    return BackendAuthService.currentRole();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _resolveRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final role = snapshot.data;
        if (role == 'guardian') return const GuardianMainScreen();
        if (role == 'elder') return const MainScreen();
        return const LoginScreen();
      },
    );
  }
}
