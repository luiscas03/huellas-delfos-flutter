import 'dart:convert';

enum RecordStatus { pending, synced, error }

enum MediaType { image, audio, signature }

class RecordMedia {
  final int? id;
  final int recordId;
  final MediaType type;
  final String path;
  final int? durationMs;

  const RecordMedia({
    this.id,
    required this.recordId,
    required this.type,
    required this.path,
    this.durationMs,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'record_id': recordId,
        'type': type.name,
        'path': path,
        'duration_ms': durationMs,
      };

  factory RecordMedia.fromMap(Map<String, dynamic> map) {
    return RecordMedia(
      id: map['id'] as int?,
      recordId: map['record_id'] as int,
      type: MediaType.values.firstWhere((e) => e.name == map['type']),
      path: map['path'] as String,
      durationMs: map['duration_ms'] as int?,
    );
  }
}

class RecordEntity {
  final int? id;
  final String? remoteId;
  final RecordStatus status;
  final DateTime createdAt;
  final String? patientId;
  final String? patientName;
  final Map<String, dynamic> payload;

  const RecordEntity({
    this.id,
    this.remoteId,
    required this.status,
    required this.createdAt,
    this.patientId,
    this.patientName,
    required this.payload,
  });

  RecordEntity copyWith({
    int? id,
    String? remoteId,
    RecordStatus? status,
    DateTime? createdAt,
    String? patientId,
    String? patientName,
    Map<String, dynamic>? payload,
  }) {
    return RecordEntity(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'remote_id': remoteId,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'patient_id': patientId,
        'patient_name': patientName,
        'payload': jsonEncode(payload),
      };

  factory RecordEntity.fromMap(Map<String, dynamic> map) {
    return RecordEntity(
      id: map['id'] as int?,
      remoteId: map['remote_id'] as String?,
      status: RecordStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['created_at'] as String),
      patientId: map['patient_id'] as String?,
      patientName: map['patient_name'] as String?,
      payload: jsonDecode(map['payload'] as String) as Map<String, dynamic>,
    );
  }
}
