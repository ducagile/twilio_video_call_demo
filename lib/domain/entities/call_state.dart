import 'package:equatable/equatable.dart';

/// Entity đại diện cho trạng thái cuộc gọi
enum CallState {
  /// Chưa kết nối
  idle,

  /// Đang kết nối
  connecting,

  /// Đã kết nối
  connected,

  /// Đã ngắt kết nối
  disconnected,

  /// Lỗi
  error,
}

/// Entity đại diện cho người dùng trong cuộc gọi
class CallUser extends Equatable {
  final int uid;
  final bool isLocalUser;
  final bool isVideoEnabled;
  final bool isAudioEnabled;

  const CallUser({
    required this.uid,
    required this.isLocalUser,
    this.isVideoEnabled = true,
    this.isAudioEnabled = true,
  });

  CallUser copyWith({
    int? uid,
    bool? isLocalUser,
    bool? isVideoEnabled,
    bool? isAudioEnabled,
  }) {
    return CallUser(
      uid: uid ?? this.uid,
      isLocalUser: isLocalUser ?? this.isLocalUser,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
    );
  }

  @override
  List<Object?> get props => [uid, isLocalUser, isVideoEnabled, isAudioEnabled];
}
