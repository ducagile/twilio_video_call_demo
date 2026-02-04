/// Response từ API POST /agora/token
class AgoraTokenResponse {
  const AgoraTokenResponse({required this.token});

  final String token;

  factory AgoraTokenResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    if (token == null || token.isEmpty) {
      throw FormatException('API token response thiếu hoặc rỗng field "token"');
    }
    return AgoraTokenResponse(token: token);
  }
}
