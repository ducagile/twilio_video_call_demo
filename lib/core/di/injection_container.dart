import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import '../../data/datasources/agora_token_remote_datasource.dart';
import '../../data/repositories/agora_token_repository_impl.dart';
import '../../data/repositories/video_call_repository_impl.dart';
import '../../domain/repositories/agora_token_repository.dart';
import '../../domain/repositories/video_call_repository.dart';
import '../../presentation/cubit/video_call/video_call_cubit.dart';
import '../../presentation/bloc/session/session_bloc.dart';

/// Dependency Injection container
class InjectionContainer {
  /// Khởi tạo tất cả dependencies
  static List<SingleChildWidget> getBlocProviders() {
    return [
      // Repositories
      RepositoryProvider<VideoCallRepository>(
        create: (_) => VideoCallRepositoryImpl(),
      ),
      RepositoryProvider<AgoraTokenRepository>(
        create: (_) => AgoraTokenRepositoryImpl(
          remote: AgoraTokenRemoteDataSource(),
        ),
      ),

      // Cubit
      BlocProvider<VideoCallCubit>(
        create: (context) => VideoCallCubit(
          context.read<VideoCallRepository>(),
          context.read<AgoraTokenRepository>(),
        ),
      ),

      // Session Bloc
      BlocProvider<SessionBloc>(
        create: (_) => SessionBloc(),
      ),
    ];
  }
}
