class TrustedContact {
  final String name;
  final String phone;
  final String role;

  const TrustedContact({required this.name, required this.phone, required this.role});

  Map<String, dynamic> toMap() => {'name': name, 'phone': phone, 'role': role};

  factory TrustedContact.fromMap(Map<String, dynamic> map) => TrustedContact(
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    role: map['role'] ?? '',
  );
}

class SafeZone {
  final String name;
  final double lat;
  final double lng;
  final double radiusMeters;

  /// Normalized (0–1) position of the zone center on the map canvas.
  final double mapX;
  final double mapY;

  /// Optional freehand outline as normalized (0–1) map points. When set, the
  /// zone is a hand-drawn shape instead of a circle.
  final List<List<double>> polygon;

  const SafeZone({
    required this.name,
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    this.mapX = 0.5,
    this.mapY = 0.5,
    this.polygon = const [],
  });

  bool get isDrawn => polygon.isNotEmpty;

  Map<String, dynamic> toMap() => {
    'name': name,
    'lat': lat,
    'lng': lng,
    'radiusMeters': radiusMeters,
    'mapX': mapX,
    'mapY': mapY,
    'polygon': polygon,
  };

  factory SafeZone.fromMap(Map<String, dynamic> map) => SafeZone(
    name: map['name'] ?? '',
    lat: (map['lat'] as num?)?.toDouble() ?? 0,
    lng: (map['lng'] as num?)?.toDouble() ?? 0,
    radiusMeters: (map['radiusMeters'] as num?)?.toDouble() ?? 200,
    mapX: (map['mapX'] as num?)?.toDouble() ?? 0.5,
    mapY: (map['mapY'] as num?)?.toDouble() ?? 0.5,
    polygon: (map['polygon'] as List<dynamic>? ?? [])
        .map((p) => (p as List<dynamic>)
            .map((v) => (v as num).toDouble())
            .toList())
        .toList(),
  );
}

class MedicalProfile {
  final List<String> conditions;
  final String bloodType;
  final String medications;
  final String allergies;

  const MedicalProfile({
    this.conditions = const [],
    this.bloodType = '',
    this.medications = '',
    this.allergies = '',
  });

  Map<String, dynamic> toMap() => {
    'conditions': conditions,
    'bloodType': bloodType,
    'medications': medications,
    'allergies': allergies,
  };

  factory MedicalProfile.fromMap(Map<String, dynamic> map) => MedicalProfile(
    conditions: List<String>.from(map['conditions'] ?? []),
    bloodType: map['bloodType'] ?? '',
    medications: map['medications'] ?? '',
    allergies: map['allergies'] ?? '',
  );
}

enum EmergencyMode { contacts, police, saveMe }

enum SubscriptionTier { free, appPaid, watchApp, family }

class UserProfile {
  final String uid;
  final String name;
  final String phone;
  final String language;
  final List<TrustedContact> trustedContacts;
  final List<SafeZone> safeZones;
  final MedicalProfile medicalProfile;
  final EmergencyMode silentTriggerMode;
  final SubscriptionTier tier;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    this.language = 'ar',
    this.trustedContacts = const [],
    this.safeZones = const [],
    required this.medicalProfile,
    this.silentTriggerMode = EmergencyMode.contacts,
    this.tier = SubscriptionTier.free,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      language: map['language'] ?? 'ar',
      trustedContacts: (map['trustedContacts'] as List<dynamic>? ?? [])
          .map((c) => TrustedContact.fromMap(Map<String, dynamic>.from(c)))
          .toList(),
      safeZones: (map['safeZones'] as List<dynamic>? ?? [])
          .map((z) => SafeZone.fromMap(Map<String, dynamic>.from(z)))
          .toList(),
      medicalProfile: map['medicalProfile'] != null
          ? MedicalProfile.fromMap(Map<String, dynamic>.from(map['medicalProfile']))
          : const MedicalProfile(),
      silentTriggerMode: EmergencyMode.values.firstWhere(
        (e) => e.name == (map['silentTriggerMode'] ?? 'contacts'),
        orElse: () => EmergencyMode.contacts,
      ),
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == (map['tier'] ?? 'free'),
        orElse: () => SubscriptionTier.free,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'language': language,
    'trustedContacts': trustedContacts.map((c) => c.toMap()).toList(),
    'safeZones': safeZones.map((z) => z.toMap()).toList(),
    'silentTriggerMode': silentTriggerMode.name,
    'tier': tier.name,
    'medicalProfile': medicalProfile.toMap(),
  };
}
