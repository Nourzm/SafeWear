import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/user_model.dart';

/// A locally-recorded alert event for the history screen.
class LocalAlertRecord {
  final String id;
  final String mode;
  final String status; // cancelled | resolved
  final DateTime startedAt;
  final DateTime? resolvedAt;

  const LocalAlertRecord({
    required this.id,
    required this.mode,
    required this.status,
    required this.startedAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'mode': mode,
        'status': status,
        'startedAt': startedAt.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
      };

  factory LocalAlertRecord.fromMap(Map<String, dynamic> map) =>
      LocalAlertRecord(
        id: map['id'] ?? '',
        mode: map['mode'] ?? 'contacts',
        status: map['status'] ?? 'cancelled',
        startedAt:
            DateTime.tryParse(map['startedAt'] ?? '') ?? DateTime.now(),
        resolvedAt: map['resolvedAt'] != null
            ? DateTime.tryParse(map['resolvedAt'])
            : null,
      );
}

class AppStateNotifier extends Notifier<UserProfile?> {
  static const _profileKey = 'safewear_profile';
  static const _historyKey = 'safewear_alert_history';
  static const _togglesKey = 'safewear_toggles';

  @override
  UserProfile? build() => null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        state = UserProfile.fromMap(map['uid'] ?? 'local_user', map);
      } catch (_) {
        state = null;
      }
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    state = profile;
    final prefs = await SharedPreferences.getInstance();
    final map = profile.toMap();
    map['uid'] = profile.uid;
    await prefs.setString(_profileKey, jsonEncode(map));
  }

  Future<void> updateContacts(List<TrustedContact> contacts) async {
    final u = state;
    if (u == null) return;
    await saveProfile(UserProfile(
      uid: u.uid,
      name: u.name,
      phone: u.phone,
      language: u.language,
      trustedContacts: contacts,
      safeZones: u.safeZones,
      medicalProfile: u.medicalProfile,
      silentTriggerMode: u.silentTriggerMode,
      tier: u.tier,
    ));
  }

  Future<void> updateSafeZones(List<SafeZone> zones) async {
    final u = state;
    if (u == null) return;
    await saveProfile(UserProfile(
      uid: u.uid,
      name: u.name,
      phone: u.phone,
      language: u.language,
      trustedContacts: u.trustedContacts,
      safeZones: zones,
      medicalProfile: u.medicalProfile,
      silentTriggerMode: u.silentTriggerMode,
      tier: u.tier,
    ));
  }

  Future<void> updateMedicalProfile(MedicalProfile medical) async {
    final u = state;
    if (u == null) return;
    await saveProfile(UserProfile(
      uid: u.uid,
      name: u.name,
      phone: u.phone,
      language: u.language,
      trustedContacts: u.trustedContacts,
      safeZones: u.safeZones,
      medicalProfile: medical,
      silentTriggerMode: u.silentTriggerMode,
      tier: u.tier,
    ));
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  Future<void> updateMode(EmergencyMode mode) async {
    final u = state;
    if (u == null) return;
    await saveProfile(UserProfile(
      uid: u.uid,
      name: u.name,
      phone: u.phone,
      language: u.language,
      trustedContacts: u.trustedContacts,
      safeZones: u.safeZones,
      medicalProfile: u.medicalProfile,
      silentTriggerMode: mode,
      tier: u.tier,
    ));
  }

  // ── Alert history (local) ──
  static Future<List<LocalAlertRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => LocalAlertRecord.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> recordAlert(LocalAlertRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    history.removeWhere((r) => r.id == record.id);
    history.insert(0, record);
    await prefs.setString(
        _historyKey, jsonEncode(history.map((r) => r.toMap()).toList()));
  }

  // ── Smart-alert toggles (persisted) ──
  static Future<Map<String, bool>> loadToggles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_togglesKey);
    if (raw == null) {
      return {
        'unusualActivity': true,
        'geofenceExit': true,
        'deviceDisconnected': false,
        'voiceTrigger': true,
      };
    }
    try {
      return Map<String, bool>.from(jsonDecode(raw));
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final toggles = await loadToggles();
    toggles[key] = value;
    await prefs.setString(_togglesKey, jsonEncode(toggles));
  }
}

final appStateProvider =
    NotifierProvider<AppStateNotifier, UserProfile?>(AppStateNotifier.new);
