import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisitDraftState {
  final List<File> images;
  final String? signaturePath;

  const VisitDraftState({required this.images, this.signaturePath});

  VisitDraftState copyWith({List<File>? images, String? signaturePath}) {
    return VisitDraftState(
      images: images ?? this.images,
      signaturePath: signaturePath ?? this.signaturePath,
    );
  }
}

class VisitDraftController extends StateNotifier<VisitDraftState> {
  VisitDraftController() : super(const VisitDraftState(images: []));

  void addImage(File file) {
    state = state.copyWith(images: [...state.images, file]);
  }

  void removeImage(File file) {
    final list = [...state.images]..remove(file);
    state = state.copyWith(images: list);
  }

  void clearImages() {
    state = state.copyWith(images: []);
  }

  void setSignaturePath(String path) {
    state = state.copyWith(signaturePath: path);
  }
}

final visitDraftProvider = StateNotifierProvider<VisitDraftController, VisitDraftState>((ref) {
  return VisitDraftController();
});
