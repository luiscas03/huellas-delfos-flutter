import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import '../../../core/network/supabase_client.dart';
import '../data/interviewee_repository.dart';

class IdentifyState {
  final Map<String, dynamic>? interviewee;
  final String? currentDocument;
  final bool loading;
  final String? error;

  const IdentifyState({
    this.interviewee,
    this.currentDocument,
    this.loading = false,
    this.error,
  });

  IdentifyState copyWith({
    Map<String, dynamic>? interviewee,
    String? currentDocument,
    bool? loading,
    String? error,
  }) {
    return IdentifyState(
      interviewee: interviewee ?? this.interviewee,
      currentDocument: currentDocument ?? this.currentDocument,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class IdentifyController extends StateNotifier<IdentifyState> {
  IdentifyController(this._repo) : super(const IdentifyState());

  final IntervieweeRepository _repo;
  final Map<String, Map<String, dynamic>> _preloaded = {};
  bool _preloadedLoaded = false;

  Future<void> _loadPreloaded() async {
    if (_preloadedLoaded) return;
    final raw = await rootBundle.loadString('assets/data/precargado.csv');
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      fieldDelimiter: ';',
      textDelimiter: '"',
      eol: '\n',
    ).convert(raw);
    if (rows.isEmpty) return;
    final headers = rows.first.map((e) => e.toString().trim()).toList();
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      final map = <String, dynamic>{};
      for (var j = 0; j < headers.length && j < row.length; j++) {
        map[headers[j]] = row[j]?.toString().trim();
      }
      final id = _normalizeId((map['identificacion'] ?? '').toString());
      if (id.isNotEmpty) {
        _preloaded[id] = map;
      }
    }
    _preloadedLoaded = true;
  }

  Future<void> searchByDocument(String documentId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _loadPreloaded();
      final normalized = _normalizeId(documentId);
      Map<String, dynamic>? data;
      try {
        data = await _repo.getByDocument(normalized).timeout(const Duration(seconds: 2));
      } on TimeoutException {
        data = null;
      } catch (_) {
        data = null;
      }
      final fallback = data ?? _mapPreloaded(normalized);
      state = state.copyWith(interviewee: fallback, currentDocument: documentId, loading: false, error: null);
    } catch (e) {
      // Si falla todo, al menos permite continuar sin bloquear
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void setCurrentDocument(String documentId) {
    state = state.copyWith(currentDocument: documentId);
  }

  Map<String, dynamic>? _mapPreloaded(String documentId) {
    final raw = _preloaded[documentId];
    if (raw == null) return null;
    final nombres = (raw['nombres'] ?? '').toString().trim();
    final apellidos = (raw['apellidos'] ?? '').toString().trim();
    final telefono = (raw['telefono'] ?? '').toString().trim();
    final direccion = (raw['direccion'] ?? '').toString().trim();
    final ciudad = (raw['municipio'] ?? raw['ciudad'] ?? '').toString().trim();
    final lat = (raw['_Geolocalizaci_n_del_usuario_latitude'] ?? raw['latitude'] ?? '').toString().trim();
    final lng = (raw['_Geolocalizaci_n_del_usuario_longitude'] ?? raw['longitude'] ?? '').toString().trim();
    return {
      'document_id': documentId,
      'full_name': '$nombres $apellidos'.trim(),
      'phone': telefono,
      'address': direccion,
      'city': ciudad,
      'latitude': lat,
      'longitude': lng,
    };
  }

  String _normalizeId(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    return digitsOnly;
  }

  Future<Map<String, dynamic>> createInterviewee(Map<String, dynamic> data) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final created = await _repo.create(data);
      state = state.copyWith(interviewee: created, loading: false);
      return created;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }
}

final intervieweeRepositoryProvider = Provider<IntervieweeRepository>((ref) {
  return IntervieweeRepository(ref.read(supabaseProvider));
});

final identifyControllerProvider = StateNotifierProvider<IdentifyController, IdentifyState>((ref) {
  return IdentifyController(ref.read(intervieweeRepositoryProvider));
});
