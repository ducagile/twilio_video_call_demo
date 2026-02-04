import '../../domain/repositories/agora_token_repository.dart';
import '../datasources/agora_token_remote_datasource.dart';

/// Implementation lấy token qua API backend.
class AgoraTokenRepositoryImpl implements AgoraTokenRepository {
  AgoraTokenRepositoryImpl({AgoraTokenRemoteDataSource? remote})
      : _remote = remote ?? AgoraTokenRemoteDataSource();

  final AgoraTokenRemoteDataSource _remote;

  @override
  Future<String> getToken({
    required String uid,
    required String channelName,
  }) async {
    final response = await _remote.fetchToken(
      uid: uid,
      channelName: channelName,
    );
    return response.token;
  }
}
