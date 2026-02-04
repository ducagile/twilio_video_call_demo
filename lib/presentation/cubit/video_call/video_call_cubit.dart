import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/call_state.dart';
import '../../../domain/repositories/agora_token_repository.dart';
import '../../../domain/repositories/video_call_repository.dart';
import 'video_call_state.dart';

/// Cubit quản lý state của video call
/// Cubit đơn giản hơn Bloc vì không cần Events, chỉ cần methods
class VideoCallCubit extends Cubit<VideoCallState> {
  final VideoCallRepository _repository;
  final AgoraTokenRepository _tokenRepository;
  StreamSubscription<CallState>? _callStateSubscription;
  StreamSubscription<List<CallUser>>? _usersSubscription;
  StreamSubscription<String>? _logSubscription;
  Timer? _leaveAfterRemoteLeftTimer;

  VideoCallCubit(this._repository, this._tokenRepository)
      : super(const VideoCallState()) {
    _listenToRepositoryStreams();
  }

  /// Khởi tạo engine
  Future<void> initializeEngine(String appId) async {
    try {
      await _repository.initialize(appId);
      emit(state.copyWith(callState: CallState.idle));
    } catch (e) {
      emit(state.copyWith(
        callState: CallState.error,
        errorMessage: 'Lỗi khởi tạo: $e',
      ));
    }
  }

  /// Tham gia channel. Gọi API lấy token rồi mới join.
  /// [uid] dùng cho Agora và gửi lên API token (mặc định 0).
  Future<void> joinChannel({
    required String channelName,
    int? uid,
  }) async {
    try {
      final effectiveUid = uid ?? 0;
      // Gọi API lấy token trước khi join
      final token = await _tokenRepository.getToken(
        uid: effectiveUid.toString(),
        channelName: channelName,
      );
      await _repository.joinChannel(
        channelName: channelName,
        token: token,
        uid: effectiveUid,
      );
    } catch (e) {
      emit(state.copyWith(
        callState: CallState.error,
        errorMessage: 'Lỗi tham gia channel: $e',
      ));
    }
  }

  /// Rời channel
  Future<void> leaveChannel() async {
    _leaveAfterRemoteLeftTimer?.cancel();
    _leaveAfterRemoteLeftTimer = null;
    try {
      await _repository.leaveChannel();
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi rời channel: $e',
      ));
    }
  }

  /// Toggle mute (bật/tắt microphone)
  Future<void> toggleMute() async {
    try {
      final newMuted = !state.isMuted;
      await _repository.toggleMute(newMuted);
      emit(state.copyWith(isMuted: newMuted));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi toggle mute: $e',
      ));
    }
  }

  /// Toggle video (bật/tắt camera)
  Future<void> toggleVideo() async {
    try {
      final newEnabled = !state.isVideoEnabled;
      await _repository.toggleVideo(newEnabled);
      emit(state.copyWith(isVideoEnabled: newEnabled));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi toggle video: $e',
      ));
    }
  }

  /// Chuyển camera (front/back)
  Future<void> switchCamera() async {
    try {
      await _repository.switchCamera();
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi chuyển camera: $e',
      ));
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _leaveAfterRemoteLeftTimer?.cancel();
    _leaveAfterRemoteLeftTimer = null;
    await _callStateSubscription?.cancel();
    await _usersSubscription?.cancel();
    await _logSubscription?.cancel();
    await _repository.dispose();
  }

  /// Listen to repository streams và cập nhật state
  void _listenToRepositoryStreams() {
    _callStateSubscription = _repository.callStateStream.listen((callState) {
      emit(state.copyWith(
        callState: callState,
        localUid: _repository.localUid,
      ));
    });

    _usersSubscription = _repository.usersStream.listen((users) {
      final previousCount = state.users.length;
      final hadExactlyTwo = previousCount == 2;
      emit(state.copyWith(
        users: users,
        localUid: _repository.localUid,
      ));
      if (users.length >= 2) {
        _leaveAfterRemoteLeftTimer?.cancel();
        _leaveAfterRemoteLeftTimer = null;
        return;
      }
      if (users.length == 1 && users.first.isLocalUser &&
          state.callState == CallState.connected &&
          hadExactlyTwo) {
        _leaveAfterRemoteLeftTimer?.cancel();
        _leaveAfterRemoteLeftTimer = Timer(const Duration(seconds: 5), () {
          _leaveAfterRemoteLeftTimer = null;
          leaveChannel();
        });
      }
    });

    _logSubscription = _repository.logStream.listen((log) {
      final logs = [...state.logs, log];
      // Giới hạn 50 logs
      if (logs.length > 50) {
        logs.removeAt(0);
      }
      emit(state.copyWith(logs: logs));
    });
  }

  @override
  Future<void> close() {
    _leaveAfterRemoteLeftTimer?.cancel();
    _leaveAfterRemoteLeftTimer = null;
    _callStateSubscription?.cancel();
    _usersSubscription?.cancel();
    _logSubscription?.cancel();
    return super.close();
  }
}
