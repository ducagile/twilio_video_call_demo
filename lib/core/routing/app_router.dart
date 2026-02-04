import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../local/user_preferences.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/call_screen.dart';
import '../../presentation/screens/home_dashboard_screen.dart';
import '../../presentation/screens/onboarding_profile_screen.dart';
import '../../presentation/screens/sign_in_screen.dart';

/// Cấu hình routing cho ứng dụng
final appRouter = GoRouter(
  redirect: (BuildContext context, GoRouterState state) async {
    final hasConfig = await UserPreferences.hasConfigured();
    final location = state.matchedLocation;
    if (!hasConfig && location != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  initialLocation: '/sign-in',
  routes: [
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final isEdit = extra?['edit'] == true;
        return OnboardingProfileScreen(isEditMode: isEdit);
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: '/call/:channelName',
      builder: (context, state) {
        final channelName = state.pathParameters['channelName']!;
        final extra = state.extra as Map<String, dynamic>?;
        final uid = extra?['uid'] as int?;
        return CallScreen(
          channelName: channelName,
          uid: uid,
        );
      },
    ),
  ],
);
