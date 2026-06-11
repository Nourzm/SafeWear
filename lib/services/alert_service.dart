import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../app/app_state.dart';
import '../shared/models/alert_model.dart';
import '../shared/models/user_model.dart';
import 'location_service.dart';
import 'audio_service.dart';
import 'sms_service.dart';

/// Core alert engine. The 20-second countdown and local history always work,
/// even with no internet or Firebase project — cloud sync is best-effort.
class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final _locationService = LocationService();
  final _audioService = AudioService();
  final _smsService = SmsService();

  String? _activeAlertId;
  DateTime? _activeAlertStartedAt;
  EmergencyMode _activeMode = EmergencyMode.contacts;
  Timer? _countdownTimer;
  final _countdownController = StreamController<int>.broadcast();

  Stream<int> get countdownStream => _countdownController.stream;
  String? get activeAlertId => _activeAlertId;

  bool get _firebaseAvailable => Firebase.apps.isNotEmpty;

  Future<void> _cloudWrite(Future<void> Function(FirebaseFirestore fs) op) async {
    if (!_firebaseAvailable) return;
    try {
      await op(FirebaseFirestore.instance)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Offline / Firestore not enabled — local flow continues regardless.
    }
  }

  // Step 1: Start the 20-second countdown
  Future<String> startCountdown(UserProfile user, EmergencyMode mode) async {
    final alertId = 'alert_${DateTime.now().millisecondsSinceEpoch}';
    _activeAlertId = alertId;
    _activeAlertStartedAt = DateTime.now();
    _activeMode = mode;

    double? lat;
    double? lng;
    try {
      final position = await _locationService
          .getCurrentPosition()
          .timeout(const Duration(seconds: 3));
      lat = position?.latitude;
      lng = position?.longitude;
    } catch (_) {}

    _cloudWrite((fs) => fs.collection('alerts').doc(alertId).set({
          'userId': user.uid,
          'mode': mode.name,
          'status': AlertStatus.countdown.name,
          'startedAt': FieldValue.serverTimestamp(),
          'lat': lat,
          'lng': lng,
          'contactsNotified': [],
        }));

    _startCountdownTimer(user, mode, alertId, lat, lng);
    return alertId;
  }

  void _startCountdownTimer(
    UserProfile user,
    EmergencyMode mode,
    String alertId,
    double? lat,
    double? lng,
  ) {
    int secondsLeft = 20;
    _countdownTimer?.cancel();
    _countdownController.add(secondsLeft);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsLeft--;
      _countdownController.add(secondsLeft);
      if (secondsLeft <= 0) {
        timer.cancel();
        _dispatchAlert(user, mode, alertId, lat, lng);
      }
    });
  }

  // Step 2a: User cancels — no alert sent
  Future<void> cancelAlert(String alertId) async {
    _countdownTimer?.cancel();
    await AppStateNotifier.recordAlert(LocalAlertRecord(
      id: alertId,
      mode: _activeMode.name,
      status: 'cancelled',
      startedAt: _activeAlertStartedAt ?? DateTime.now(),
      resolvedAt: DateTime.now(),
    ));
    _cloudWrite((fs) => fs.collection('alerts').doc(alertId).update({
          'status': AlertStatus.cancelled.name,
          'resolvedAt': FieldValue.serverTimestamp(),
        }));
    _activeAlertId = null;
  }

  // Step 2b: Countdown ends — dispatch everything simultaneously
  Future<void> _dispatchAlert(
    UserProfile user,
    EmergencyMode mode,
    String alertId,
    double? lat,
    double? lng,
  ) async {
    _cloudWrite((fs) => fs.collection('alerts').doc(alertId).update({
          'status': AlertStatus.active.name,
        }));

    try {
      _locationService.startLiveTracking(alertId);
    } catch (_) {}
    try {
      _audioService.startRecording(alertId);
    } catch (_) {}

    final mapsLink = lat != null && lng != null
        ? _locationService.buildGoogleMapsLink(lat, lng)
        : null;

    // Notify ALL contacts simultaneously — each failure is independent.
    for (final contact in user.trustedContacts) {
      _smsService
          .sendAlert(
            toPhone: contact.phone,
            userName: user.name,
            mapsLink: mapsLink,
            mode: mode,
          )
          .catchError((_) {});
    }

    _cloudWrite((fs) => fs.collection('alert_dispatches').add({
          'alertId': alertId,
          'userId': user.uid,
          'mode': mode.name,
          'contacts': user.trustedContacts.map((c) => c.toMap()).toList(),
          'lat': lat,
          'lng': lng,
          'mapsLink': mapsLink,
          'medicalProfile': user.medicalProfile.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        }));
  }

  // Step 7: User marks as resolved
  Future<void> resolveAlert(String alertId) async {
    _countdownTimer?.cancel();
    try {
      _locationService.stopLiveTracking();
    } catch (_) {}
    String? audioUrl;
    try {
      audioUrl = await _audioService
          .stopRecording()
          .timeout(const Duration(seconds: 5));
    } catch (_) {}

    await AppStateNotifier.recordAlert(LocalAlertRecord(
      id: alertId,
      mode: _activeMode.name,
      status: 'resolved',
      startedAt: _activeAlertStartedAt ?? DateTime.now(),
      resolvedAt: DateTime.now(),
    ));

    _cloudWrite((fs) => fs.collection('alerts').doc(alertId).update({
          'status': AlertStatus.resolved.name,
          'resolvedAt': FieldValue.serverTimestamp(),
          'audioUrl': audioUrl,
        }));
    _activeAlertId = null;
  }

  void dispose() {
    _countdownController.close();
    _countdownTimer?.cancel();
  }
}
