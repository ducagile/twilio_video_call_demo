/// Repository lấy token Agora từ backend.
abstract class AgoraTokenRepository {
  /// Gọi API lấy token với [uid] và [channelName].
  /// Trả về token string để dùng cho [joinChannel].
  Future<String> getToken({
    required String uid,
    required String channelName,
  });
}
