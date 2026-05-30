import 'package:go_router/go_router.dart';
import '../features/auth/onboarding_flow.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../shared/models/user_model.dart';

final router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingFlow(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final user = state.extra as UserProfile;
        return DashboardScreen(user: user);
      },
    ),
  ],
);
