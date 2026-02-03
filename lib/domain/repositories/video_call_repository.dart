import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../entities/call_state.dart';

/// Repository interface cho video calling
/// Tuân thủ Dependency Inversion Principle
abstract class VideoCallRepository {
  /// Get RtcEngine instance (nullable)
  RtcEngine? get engine;

  /// Khởi tạo engine
  Future<void> initialize(String appId);

  /// Tham gia channel
  Future<void> joinChannel({
    required String channelName,
    String? token,
    int? uid,
  });

  /// Rời channel
  Future<void> leaveChannel();

  /// Bật/tắt microphone
  Future<void> toggleMute(bool muted);

  /// Bật/tắt camera
  Future<void> toggleVideo(bool enabled);

  /// Chuyển camera (front/back)
  Future<void> switchCamera();

  /// Dispose resources
  Future<void> dispose();

  /// Stream trạng thái cuộc gọi
  Stream<CallState> get callStateStream;

  /// Stream danh sách người dùng
  Stream<List<CallUser>> get usersStream;

  /// Stream log messages
  Stream<String> get logStream;
}
