import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/call_screen.dart';
import '../../presentation/screens/home_dashboard_screen.dart';

/// Cấu hình routing cho ứng dụng
final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
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
