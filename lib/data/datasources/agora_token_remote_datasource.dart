import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../models/agora_token_response.dart';

/// Data source gọi API backend lấy Agora token.
class AgoraTokenRemoteDataSource {
  AgoraTokenRemoteDataSource({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConfig.agoraTokenBaseUrl));

  final Dio _dio;

  /// POST /agora/token với body { "uid": "...", "channelName": "..." }.
  Future<AgoraTokenResponse> fetchToken({
    required String uid,
    required String channelName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/agora/token',
      data: <String, String>{
        'uid': uid,
        'channelName': channelName,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('API trả về body rỗng');
    }
    return AgoraTokenResponse.fromJson(data);
  }
}
