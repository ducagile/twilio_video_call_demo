import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../domain/entities/call_state.dart';
import '../../domain/repositories/video_call_repository.dart';

/// Widget hiển thị video của một người dùng
class VideoViewItem extends StatefulWidget {
  final CallUser user;

  const VideoViewItem({
    super.key,
    required this.user,
  });

  @override
  State<VideoViewItem> createState() => _VideoViewItemState();
}

class _VideoViewItemState extends State<VideoViewItem> {
  @override
  Widget build(BuildContext context) {
    final repository = context.read<VideoCallRepository>();
    final engine = repository.engine;
    final channelId = repository.currentChannelId ?? '';

    if (engine == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video view
          if (widget.user.isVideoEnabled)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.user.isLocalUser
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: engine,
                        canvas: const VideoCanvas(uid: 0),
                        useFlutterTexture: true,
                      ),
                    )
                  : AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: engine,
                        canvas: VideoCanvas(uid: widget.user.uid),
                        connection: RtcConnection(
                          channelId: channelId,
                        ),
                        useFlutterTexture: true,
                      ),
                    ),
            )
          else
            // Ảnh default khi video bị tắt
            Container(
              color: Colors.grey[800],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const Icon(
                  Icons.person,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),

          // Overlay thông tin người dùng
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                if (!widget.user.isAudioEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.mic_off,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                const Spacer(),
                Text(
                  widget.user.isLocalUser ? 'Bạn' : 'User ${widget.user.uid}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
