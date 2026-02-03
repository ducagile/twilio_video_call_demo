import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../cubit/video_call/video_call_cubit.dart';
import '../../core/config/app_config.dart';

/// Form để nhập tên channel và tham gia cuộc gọi
class ChannelForm extends StatefulWidget {
  const ChannelForm({super.key});

  @override
  State<ChannelForm> createState() => _ChannelFormState();
}

class _ChannelFormState extends State<ChannelForm> {
  final _formKey = GlobalKey<FormState>();
  final _channelController = TextEditingController(
    text: AppConfig.defaultChannelName,
  );
  bool _isLoading = false;

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  Future<void> _onJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Yêu cầu quyền truy cập
      await _requestPermissions();

      final channelName = _channelController.text.trim();
      final cubit = context.read<VideoCallCubit>();

      // Khởi tạo engine nếu chưa được khởi tạo
      await cubit.initializeEngine(AppConfig.agoraAppId);

      // Đợi một chút để engine khởi tạo
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        context.push('/call/$channelName');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tham gia cuộc gọi video',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _channelController,
            decoration: const InputDecoration(
              labelText: 'Tên channel',
              hintText: 'Nhập tên channel',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.video_call),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên channel';
              }
              return null;
            },
            textCapitalization: TextCapitalization.none,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onJoin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Tham gia'),
            ),
          ),
        ],
      ),
    );
  }
}
