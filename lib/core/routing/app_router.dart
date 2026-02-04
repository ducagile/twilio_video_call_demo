import 'package:go_router/go_router.dart';

import '../../presentation/screens/call_screen.dart';
import '../../presentation/screens/home_dashboard_screen.dart';
import '../../presentation/screens/sign_in_screen.dart';

/// Cấu hình routing cho ứng dụng.
final appRouter = GoRouter(
  initialLocation: '/sign-in',
  routes: [
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
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
