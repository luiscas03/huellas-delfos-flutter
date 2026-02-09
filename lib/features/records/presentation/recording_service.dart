import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class RecordingSegment {
  final String path;
  final Duration duration;
  final int sizeBytes;

  RecordingSegment({required this.path, required this.duration, required this.sizeBytes});
}

class RecordingService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _initialized = false;
  DateTime? _startTime;
  String? _currentPath;

  Future<void> init() async {
    if (_initialized) return;
    await _recorder.openRecorder();
    _initialized = true;
  }

  Future<String> start() async {
    await init();
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'records', 'temp', 'audios'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final filePath = p.join(folder.path, 'segment_${DateTime.now().millisecondsSinceEpoch}.m4a');
    _currentPath = filePath;
    _startTime = DateTime.now();
    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.aacMP4,
      sampleRate: 48000,
      numChannels: 1,
      bitRate: 32000,
    );
    return filePath;
  }

  Future<RecordingSegment?> stop() async {
    if (!_recorder.isRecording) return null;
    await _recorder.stopRecorder();
    final endTime = DateTime.now();
    final duration = _startTime == null ? Duration.zero : endTime.difference(_startTime!);
    final path = _currentPath;
    if (path == null) return null;
    final file = File(path);
    final sizeBytes = await file.length();
    return RecordingSegment(path: path, duration: duration, sizeBytes: sizeBytes);
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }
}
