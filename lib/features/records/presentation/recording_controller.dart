import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'recording_service.dart';

class RecordingState {
  final List<RecordingSegment> segments;

  const RecordingState({required this.segments});

  RecordingState copyWith({List<RecordingSegment>? segments}) {
    return RecordingState(segments: segments ?? this.segments);
  }
}

class RecordingController extends StateNotifier<RecordingState> {
  RecordingController() : super(const RecordingState(segments: []));

  void addSegment(RecordingSegment segment) {
    state = state.copyWith(segments: [...state.segments, segment]);
  }

  void removeAt(int index) {
    final list = [...state.segments]..removeAt(index);
    state = state.copyWith(segments: list);
  }
}

final recordingControllerProvider = StateNotifierProvider<RecordingController, RecordingState>((ref) {
  return RecordingController();
});
