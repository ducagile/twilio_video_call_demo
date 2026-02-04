import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twilio_video_call_demo/domain/entities/call_state.dart';
import 'video_view_item.dart';

/// Góc cố định cho video nhỏ (local).
enum _Corner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Layout kiểu Messenger: remote full màn hình, local nhỏ ở 1 trong 4 góc, kéo để đổi góc.
class VideoViewGrid extends StatefulWidget {
  final List<CallUser> users;

  const VideoViewGrid({
    super.key,
    required this.users,
  });

  @override
  State<VideoViewGrid> createState() => _VideoViewGridState();
}

class _VideoViewGridState extends State<VideoViewGrid> {
  static const double _overlayWidth = 120;
  static const double _overlayHeight = 160;
  static const double _edgePadding = 16;

  _Corner _corner = _Corner.topRight;
  Offset? _dragOffset;

  CallUser? get _localUser {
    for (final u in widget.users) {
      if (u.isLocalUser) return u;
    }
    return null;
  }

  CallUser? get _remoteUser {
    for (final u in widget.users) {
      if (!u.isLocalUser) return u;
    }
    return null;
  }

  void _onPanStart(DragStartDetails details, Size screenSize) {
    final pos = _offsetForCorner(_corner, screenSize);
    setState(() => _dragOffset = pos);
  }

  void _onPanUpdate(DragUpdateDetails details, Size screenSize) {
    if (_dragOffset == null) return;
    final maxX = screenSize.width - _overlayWidth;
    final maxY = screenSize.height - _overlayHeight;
    setState(() {
      _dragOffset = Offset(
        (_dragOffset!.dx + details.delta.dx).clamp(0.0, maxX),
        (_dragOffset!.dy + details.delta.dy).clamp(0.0, maxY),
      );
    });
  }

  void _onPanEnd(DragEndDetails details, Size screenSize) {
    if (_dragOffset == null) return;
    final center = Offset(
      _dragOffset!.dx + _overlayWidth / 2,
      _dragOffset!.dy + _overlayHeight / 2,
    );
    final w = screenSize.width;
    final h = screenSize.height;
    _Corner next;
    if (center.dx < w / 2 && center.dy < h / 2) {
      next = _Corner.topLeft;
    } else if (center.dx >= w / 2 && center.dy < h / 2) {
      next = _Corner.topRight;
    } else if (center.dx < w / 2 && center.dy >= h / 2) {
      next = _Corner.bottomLeft;
    } else {
      next = _Corner.bottomRight;
    }
    setState(() {
      _corner = next;
      _dragOffset = null;
    });
  }

  Offset _offsetForCorner(_Corner c, Size screenSize) {
    switch (c) {
      case _Corner.topLeft:
        return Offset(_edgePadding, _edgePadding);
      case _Corner.topRight:
        return Offset(
          math.max(0, screenSize.width - _overlayWidth - _edgePadding),
          _edgePadding,
        );
      case _Corner.bottomLeft:
        return Offset(
          _edgePadding,
          math.max(0, screenSize.height - _overlayHeight - _edgePadding),
        );
      case _Corner.bottomRight:
        return Offset(
          math.max(0, screenSize.width - _overlayWidth - _edgePadding),
          math.max(0, screenSize.height - _overlayHeight - _edgePadding),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final local = _localUser;
    final remote = _remoteUser;

    if (widget.users.isEmpty) {
      return const Center(
        child: Text(
          'Đang chờ người dùng tham gia...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final overlayTopLeft = _dragOffset ?? _offsetForCorner(_corner, screenSize);
    // Clamp overlay khi đang kéo
    final clampedOverlayLeft = overlayTopLeft.dx
        .clamp(0.0, screenSize.width - _overlayWidth)
        .clamp(0.0, double.infinity);
    final clampedOverlayTop = overlayTopLeft.dy
        .clamp(0.0, screenSize.height - _overlayHeight)
        .clamp(0.0, double.infinity);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full màn: video remote (hoặc placeholder khi chưa có ai)
        Positioned.fill(
          child: remote != null
              ? VideoViewItem(user: remote)
              : Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      'Đang chờ người dùng tham gia...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
        ),
        // Video nhỏ của bản thân ở góc (có thể kéo đổi góc)
        if (local != null)
          Positioned(
            left: clampedOverlayLeft,
            top: clampedOverlayTop,
            width: _overlayWidth,
            height: _overlayHeight,
            child: GestureDetector(
              onPanStart: (d) => _onPanStart(d, screenSize),
              onPanUpdate: (d) => _onPanUpdate(d, screenSize),
              onPanEnd: (d) => _onPanEnd(d, screenSize),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoViewItem(user: local),
                      // Gợi ý có thể kéo
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Icon(
                          Icons.open_with,
                          size: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
