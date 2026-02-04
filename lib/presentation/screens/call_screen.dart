import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twilio_video_call_demo/presentation/cubit/video_call/video_call_state.dart';
import '../cubit/video_call/video_call_cubit.dart';
import '../widgets/video_view_grid.dart';
import '../widgets/call_toolbar.dart';
import '../widgets/call_logs_panel.dart';
import '../../../domain/entities/call_state.dart';

/// Màn hình cuộc gọi video. Token được lấy qua API khi [joinChannel].
class CallScreen extends StatelessWidget {
  final String channelName;

  /// UID Agora (gửi lên API token và dùng khi join). Null thì dùng 0.
  final int? uid;

  const CallScreen({
    super.key,
    required this.channelName,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCallCubit, VideoCallState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<VideoCallCubit, VideoCallState>(
        builder: (context, state) {
          final cubit = context.read<VideoCallCubit>();

          // Join channel khi màn hình được load và state là idle (Cubit sẽ gọi API lấy token rồi join)
          if (state.callState == CallState.idle) {
            cubit.joinChannel(
              channelName: channelName,
              uid: uid,
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  // Video grid
                  VideoViewGrid(users: state.users),

                  // Toolbar ở dưới
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CallToolbar(
                      isMuted: state.isMuted,
                      isVideoEnabled: state.isVideoEnabled,
                      onToggleMute: () => cubit.toggleMute(),
                      onToggleVideo: () => cubit.toggleVideo(),
                      onSwitchCamera: () => cubit.switchCamera(),
                      onLeave: () {
                        cubit.leaveChannel();
                        context.go('/dashboard');
                      },
                    ),
                  ),

                  // Logs panel (có thể toggle)
                  // if (state.logs.isNotEmpty)
                  //   Positioned(
                  //     top: 8,
                  //     left: 8,
                  //     right: 8,
                  //     child: CallLogsPanel(logs: state.logs),
                  //   ),

                  // Loading indicator
                  if (state.callState == CallState.connecting)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
