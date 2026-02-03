import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/call_screen.dart';

/// Cấu hình routing cho ứng dụng
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
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
