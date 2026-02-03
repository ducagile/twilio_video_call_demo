import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import '../../data/repositories/video_call_repository_impl.dart';
import '../../domain/repositories/video_call_repository.dart';
import '../../presentation/cubit/video_call/video_call_cubit.dart';

/// Dependency Injection container
class InjectionContainer {
  /// Khởi tạo tất cả dependencies
  static List<SingleChildWidget> getBlocProviders() {
    return [
      // Repository
      RepositoryProvider<VideoCallRepository>(
        create: (_) => VideoCallRepositoryImpl(),
      ),

      // Cubit
      BlocProvider<VideoCallCubit>(
        create: (context) => VideoCallCubit(
          context.read<VideoCallRepository>(),
        ),
      ),
    ];
  }
}
