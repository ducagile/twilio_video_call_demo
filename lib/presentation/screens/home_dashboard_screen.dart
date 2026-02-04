import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twilio_video_call_demo/presentation/bloc/session/session_state.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/agora_uid_utils.dart';
import '../bloc/session/session_bloc.dart';
import '../cubit/video_call/video_call_cubit.dart';
import '../widgets/appointment_card.dart';

/// Màn hình dashboard chính (demo telehealth).
/// UserId hiển thị lấy từ SessionBloc (màn sign-in).
/// Bấm JOIN → vào call luôn (channel mặc định, uid từ SessionBloc).
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isJoining = false;

  Future<void> _onJoin() async {
    if (_isJoining) return;

    setState(() => _isJoining = true);

    try {
      await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final sessionState = context.read<SessionBloc>().state;
      final channelName = AppConfig.defaultChannelName;
      final agoraUid = agoraUidFromUserId(sessionState.userId);

      final cubit = context.read<VideoCallCubit>();
      await cubit.initializeEngine(AppConfig.agoraAppId);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      context.push(
        '/call/$channelName',
        extra: <String, dynamic>{'uid': agoraUid},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DashboardHeader(),
                  const SizedBox(height: 16),
                  const _DashboardSearchBar(),
                  const SizedBox(height: 24),
                  _UpcomingSection(onJoinPressed: _onJoin),
                  const SizedBox(height: 24),
                  const _PastSection(),
                ],
              ),
            ),
            if (_isJoining)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu),
                color: colorScheme.onPrimaryContainer,
              ),
              const Spacer(),
              const _OnlineStatusToggle(),
              const SizedBox(width: 12),
              BlocBuilder<SessionBloc, SessionState>(
                buildWhen: (prev, curr) => prev.userId != curr.userId,
                builder: (context, state) {
                  final userId = state.userId?.trim() ?? 'User';
                  final initial =
                      userId.isNotEmpty ? userId[0].toUpperCase() : 'U';
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.onPrimaryContainer,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        initial,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<SessionBloc, SessionState>(
            buildWhen: (prev, curr) => prev.userId != curr.userId,
            builder: (context, state) {
              final userId = state.userId?.trim();
              return Text(
                userId != null && userId.isNotEmpty
                    ? 'Hi, $userId'
                    : 'Hi, User',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome Back',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineStatusToggle extends StatefulWidget {
  const _OnlineStatusToggle();

  @override
  State<_OnlineStatusToggle> createState() => _OnlineStatusToggleState();
}

class _OnlineStatusToggleState extends State<_OnlineStatusToggle> {
  bool _online = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onPrimaryContainer.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _online ? Icons.circle : Icons.circle_outlined,
            size: 14,
            color:
                _online ? Colors.greenAccent : colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            _online ? 'Online' : 'Offline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          Switch(
            value: _online,
            onChanged: (value) {
              setState(() => _online = value);
            },
            activeColor: Colors.greenAccent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _DashboardSearchBar extends StatelessWidget {
  const _DashboardSearchBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.6),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({this.onJoinPressed});

  final VoidCallback? onJoinPressed;

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final nowText = 'Today, ${now.format(context)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Upcoming Appointments'),
          const SizedBox(height: 12),
          AppointmentCard(
            name: 'Instant Consultation',
            email: 'Tap to join now',
            phone: '',
            dateTimeText: nowText,
            isUpcoming: true,
            actionLabel: 'JOIN',
            actionColor: Colors.green,
            onActionPressed: onJoinPressed,
          ),
          AppointmentCard(
            name: 'Kyle William',
            email: 'KyleWilliam911@gmail.com',
            phone: '+1 123 456 7890',
            dateTimeText: '7 July, 09:50 AM',
            isUpcoming: true,
          ),
          AppointmentCard(
            name: 'Michael Reece',
            email: 'MichaelReece22@gmail.com',
            phone: '+1 123 456 7890',
            dateTimeText: '7 July, 09:50 AM',
            isUpcoming: true,
          ),
        ],
      ),
    );
  }
}

class _PastSection extends StatelessWidget {
  const _PastSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Past Appointments'),
          const SizedBox(height: 12),
          AppointmentCard(
            name: 'John Doe',
            email: 'Johndoe911@gmail.com',
            phone: '+1 123 456 7890',
            dateTimeText: '7 July, 09:50 AM',
            isUpcoming: false,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('See all'),
        ),
      ],
    );
  }
}
