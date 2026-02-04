import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/call_screen.dart';
import '../../presentation/screens/home_dashboard_screen.dart';
import '../../presentation/screens/sign_in_screen.dart';

/// Cấu hình routing cho ứng dụng
final appRouter = GoRouter(
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
      path: '/dashboard',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: '/call/:channelName',
      builder: (context, state) {
        final channelName = state.pathParameters['channelName']!;
        return CallScreen(channelName: channelName);
      },
    ),
  ],
);
