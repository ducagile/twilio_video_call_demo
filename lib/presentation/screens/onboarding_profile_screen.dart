import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/local/user_preferences.dart';

/// Màn cấu hình tên user: hiển thị lần đầu khi chưa có tên, hoặc mở từ dashboard để sửa.
class OnboardingProfileScreen extends StatefulWidget {
  /// Mở từ dashboard để chỉnh sửa (sau khi lưu sẽ pop thay vì go dashboard).
  final bool isEditMode;

  const OnboardingProfileScreen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _agoraJoinNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final display = await UserPreferences.getDisplayName();
    final agora = await UserPreferences.getAgoraJoinName();
    if (mounted) {
      _displayNameController.text = display?.trim() ?? '';
      _agoraJoinNameController.text = agora?.trim() ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _agoraJoinNameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await UserPreferences.save(
        displayName: _displayNameController.text.trim(),
        agoraJoinName: _agoraJoinNameController.text.trim(),
      );
      if (!mounted) return;
      if (widget.isEditMode) {
        Navigator.of(context).pop();
      } else {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.isEditMode;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Icon(
                  Icons.person_add_alt_1,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  isEdit ? 'Cập nhật thông tin' : 'Chào bạn!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isEdit
                      ? 'Chỉnh sửa tên hiển thị và tên dùng khi tham gia cuộc gọi.'
                      : 'Vui lòng nhập tên để bắt đầu sử dụng ứng dụng.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên hiển thị (Dashboard)',
                    hintText: 'VD: Dr. Nguyễn Văn A',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập tên hiển thị';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _agoraJoinNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên khi tham gia cuộc gọi (Agora)',
                    hintText: 'Tên hiển thị trong phòng gọi',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.video_call_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập tên tham gia cuộc gọi';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSave,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Cập nhật' : 'Lưu và tiếp tục'),
                  ),
                ),
                if (isEdit) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
