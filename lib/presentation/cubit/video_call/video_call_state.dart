import 'package:equatable/equatable.dart';
import '../../../domain/entities/call_state.dart';

/// State cho VideoCallCubit
class VideoCallState extends Equatable {
  final CallState callState;
  final List<CallUser> users;
  final List<String> logs;
  final bool isMuted;
  final bool isVideoEnabled;
  final String? errorMessage;

  const VideoCallState({
    this.callState = CallState.idle,
    this.users = const [],
    this.logs = const [],
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.errorMessage,
  });

  VideoCallState copyWith({
    CallState? callState,
    List<CallUser>? users,
    List<String>? logs,
    bool? isMuted,
    bool? isVideoEnabled,
    String? errorMessage,
  }) {
    return VideoCallState(
      callState: callState ?? this.callState,
      users: users ?? this.users,
      logs: logs ?? this.logs,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        callState,
        users,
        logs,
        isMuted,
        isVideoEnabled,
        errorMessage,
      ];
}
