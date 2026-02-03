import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/call_state.dart';
import '../../domain/repositories/video_call_repository.dart';

/// Implementation của VideoCallRepository sử dụng Agora SDK
class VideoCallRepositoryImpl implements VideoCallRepository {
  RtcEngine? _engine;
  final Logger _logger = Logger();

  final _callStateController = StreamController<CallState>.broadcast();
  final _usersController = StreamController<List<CallUser>>.broadcast();
  final _logController = StreamController<String>.broadcast();

  CallState _currentState = CallState.idle;
  final Map<int, CallUser> _users = {};
  int? _localUid;
  bool _isMuted = false;
  bool _isVideoEnabled = true;

  @override
  RtcEngine? get engine => _engine;

  @override
  Future<void> initialize(String appId) async {
    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Enable video
      await _engine!.enableVideo();
      await _engine!.startPreview();

      // Enable interoperability với web
      await _engine!.enableWebSdkInteroperability(true);

      // Đăng ký event handlers
      _registerEventHandlers();

      _updateState(CallState.idle);
      _addLog('Engine đã được khởi tạo thành công');
    } catch (e) {
      _logger.e('Lỗi khởi tạo engine: $e');
      _updateState(CallState.error);
      rethrow;
    }
  }

  @override
  Future<void> joinChannel({
    required String channelName,
    String? token,
    int? uid,
  }) async {
    try {
      if (_engine == null) {
        throw Exception('Engine chưa được khởi tạo');
      }

      _updateState(CallState.connecting);
      _addLog('Đang tham gia channel: $channelName');

      await _engine!.joinChannel(
        token: token ?? '',
        channelId: channelName,
        uid: uid ?? 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
    } catch (e) {
      _logger.e('Lỗi tham gia channel: $e');
      _updateState(CallState.error);
      rethrow;
    }
  }

  @override
  Future<void> leaveChannel() async {
    try {
      await _engine?.leaveChannel();
      _users.clear();
      _localUid = null;
      _updateUsers();
      _updateState(CallState.disconnected);
      _addLog('Đã rời channel');
    } catch (e) {
      _logger.e('Lỗi rời channel: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleMute(bool muted) async {
    try {
      await _engine?.muteLocalAudioStream(muted);
      _isMuted = muted;

      if (_localUid != null) {
        _users[_localUid!] = _users[_localUid!]!.copyWith(
          isAudioEnabled: !muted,
        );
        _updateUsers();
      }

      _addLog(muted ? 'Đã tắt microphone' : 'Đã bật microphone');
    } catch (e) {
      _logger.e('Lỗi toggle mute: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleVideo(bool enabled) async {
    try {
      await _engine?.muteLocalVideoStream(!enabled);
      _isVideoEnabled = enabled;

      if (_localUid != null) {
        _users[_localUid!] = _users[_localUid!]!.copyWith(
          isVideoEnabled: enabled,
        );
        _updateUsers();
      }

      _addLog(enabled ? 'Đã bật camera' : 'Đã tắt camera');
    } catch (e) {
      _logger.e('Lỗi toggle video: $e');
      rethrow;
    }
  }

  @override
  Future<void> switchCamera() async {
    try {
      await _engine?.switchCamera();
      _addLog('Đã chuyển camera');
    } catch (e) {
      _logger.e('Lỗi chuyển camera: $e');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    await leaveChannel();
    await _engine?.release();
    await _callStateController.close();
    await _usersController.close();
    await _logController.close();
    _engine = null;
  }

  @override
  Stream<CallState> get callStateStream => _callStateController.stream;

  @override
  Stream<List<CallUser>> get usersStream => _usersController.stream;

  @override
  Stream<String> get logStream => _logController.stream;

  void _registerEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _localUid = connection.localUid;
          _users[_localUid!] = CallUser(
            uid: _localUid!,
            isLocalUser: true,
            isVideoEnabled: _isVideoEnabled,
            isAudioEnabled: !_isMuted,
          );
          _updateUsers();
          _updateState(CallState.connected);
          _addLog('Đã tham gia channel thành công. UID: $_localUid');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _users[remoteUid] = CallUser(
            uid: remoteUid,
            isLocalUser: false,
          );
          _updateUsers();
          _addLog('Người dùng đã tham gia. UID: $remoteUid');
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          _users.remove(remoteUid);
          _updateUsers();
          _addLog('Người dùng đã rời. UID: $remoteUid');
        },
        onError: (ErrorCodeType err, String msg) {
          _logger.e('Lỗi Agora: $err - $msg');
          _updateState(CallState.error);
          _addLog('Lỗi: $msg');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          _addLog('Đã rời channel');
        },
      ),
    );
  }

  void _updateState(CallState state) {
    _currentState = state;
    _callStateController.add(state);
  }

  void _updateUsers() {
    _usersController.add(_users.values.toList());
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _logController.add('[$timestamp] $message');
  }
}
