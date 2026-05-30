import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

enum AlertStatus { countdown, active, resolved, cancelled }

class AlertEvent {
  final String id;
  final String userId;
  final EmergencyMode mode;
  final AlertStatus status;
  final DateTime startedAt;
  final DateTime? resolvedAt;
  final double? lat;
  final double? lng;
  final String? audioUrl;
  final String? resolvedBy;
  final List<String> contactsNotified;

  const AlertEvent({
    required this.id,
    required this.userId,
    required this.mode,
    required this.status,
    required this.startedAt,
    this.resolvedAt,
    this.lat,
    this.lng,
    this.audioUrl,
    this.resolvedBy,
    this.contactsNotified = const [],
  });

  factory AlertEvent.fromMap(String id, Map<String, dynamic> map) {
    return AlertEvent(
      id: id,
      userId: map['userId'] ?? '',
      mode: EmergencyMode.values.firstWhere(
        (e) => e.name == (map['mode'] ?? 'contacts'),
        orElse: () => EmergencyMode.contacts,
      ),
      status: AlertStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'active'),
        orElse: () => AlertStatus.active,
      ),
      startedAt: (map['startedAt'] as Timestamp).toDate(),
      resolvedAt:
          map['resolvedAt'] != null
              ? (map['resolvedAt'] as Timestamp).toDate()
              : null,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      audioUrl: map['audioUrl'],
      resolvedBy: map['resolvedBy'],
      contactsNotified: List<String>.from(map['contactsNotified'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'mode': mode.name,
    'status': status.name,
    'startedAt': Timestamp.fromDate(startedAt),
    'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    'lat': lat,
    'lng': lng,
    'audioUrl': audioUrl,
    'resolvedBy': resolvedBy,
    'contactsNotified': contactsNotified,
  };
}
