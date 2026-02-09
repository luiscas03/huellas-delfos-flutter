import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../../../../core/theme/app_colors.dart';
import '../recording_service.dart';

class AudioSegmentTile extends StatefulWidget {
  const AudioSegmentTile({super.key, required this.segment, required this.onDelete, required this.label});

  final RecordingSegment segment;
  final VoidCallback onDelete;
  final String label;

  @override
  State<AudioSegmentTile> createState() => _AudioSegmentTileState();
}

class _AudioSegmentTileState extends State<AudioSegmentTile> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.stopPlayer();
      setState(() => _playing = false);
      return;
    }
    await _player.startPlayer(
      fromURI: widget.segment.path,
      codec: Codec.aacMP4,
      whenFinished: () => setState(() => _playing = false),
    );
    setState(() => _playing = true);
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.segment.duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = widget.segment.duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final sizeKb = (widget.segment.sizeBytes / 1024).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _toggle,
            icon: Icon(_playing ? Icons.pause : Icons.play_arrow, size: 18, color: AppColors.textSecondary),
          ),
          Text(widget.label),
          const Spacer(),
          Text('00:$minutes:$seconds', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text('$sizeKb KB', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete_outline, size: 18)),
        ],
      ),
    );
  }
}
