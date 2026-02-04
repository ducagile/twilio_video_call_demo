import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../cubit/video_call/video_call_cubit.dart';
import '../../core/config/app_config.dart';
import '../../core/local/user_preferences.dart';

/// Form để nhập tên channel và tham gia cuộc gọi
class ChannelForm extends StatefulWidget {
  const ChannelForm({super.key});

  @override
  State<ChannelForm> createState() => _ChannelFormState();
}

class _ChannelFormState extends State<ChannelForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _channelController = TextEditingController(
    text: AppConfig.defaultChannelName,
  );
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    UserPreferences.getAgoraJoinName().then((name) {
      if (mounted && name != null && name.trim().isNotEmpty) {
        _nameController.text = name.trim();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _channelController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  /// Tạo Agora UID từ tên (cùng tên → cùng UID trong phiên), thêm entropy theo thời gian để tránh trùng.
  static int _agoraUidFromName(String name) {
    final base = name.isEmpty ? 0 : name.hashCode.abs();
    final entropy = DateTime.now().millisecondsSinceEpoch % 10000;
    return base + entropy;
  }

  Future<void> _onJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _requestPermissions();

      final channelName = _channelController.text.trim();
      // Agora UID: gửi lên API token và dùng khi join (Cubit sẽ gọi API lấy token trong joinChannel).
      final agoraUid = (_agoraUidFromName(_nameController.text.trim()) %
              10000000)
          .clamp(1, 9999999);

      final cubit = context.read<VideoCallCubit>();
      await cubit.initializeEngine(AppConfig.agoraAppId);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        context.push(
          '/call/$channelName',
          extra: <String, dynamic>{'uid': agoraUid},
        );
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
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên của bạn',
              hintText: 'Nhập tên hiển thị',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên của bạn';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
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
