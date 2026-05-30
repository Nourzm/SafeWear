import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/models/alert_model.dart';
import '../shared/models/user_model.dart';
import 'location_service.dart';
import 'audio_service.dart';
import 'sms_service.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _locationService = LocationService();
  final _audioService = AudioService();
  final _smsService = SmsService();

  String? _activeAlertId;
  Timer? _countdownTimer;
  final _countdownController = StreamController<int>.broadcast();

  Stream<int> get countdownStream => _countdownController.stream;
  String? get activeAlertId => _activeAlertId;

  // Step 1: Start the 20-second countdown
  Future<String> startCountdown(UserProfile user, EmergencyMode mode) async {
    final position = await _locationService.getCurrentPosition();

    final doc = await _firestore.collection('alerts').add({
      'userId': user.uid,
      'mode': mode.name,
      'status': AlertStatus.countdown.name,
      'startedAt': FieldValue.serverTimestamp(),
      'lat': position?.latitude,
      'lng': position?.longitude,
      'contactsNotified': [],
    });

    _activeAlertId = doc.id;
    _startCountdownTimer(user, mode, doc.id, position?.latitude, position?.longitude);
    return doc.id;
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
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownController.add(secondsLeft);
      secondsLeft--;
      if (secondsLeft < 0) {
        timer.cancel();
        _dispatchAlert(user, mode, alertId, lat, lng);
      }
    });
  }

  // Step 2a: User cancels — no alert sent
  Future<void> cancelAlert(String alertId) async {
    _countdownTimer?.cancel();
    await _firestore.collection('alerts').doc(alertId).update({
      'status': AlertStatus.cancelled.name,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
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
    await _firestore.collection('alerts').doc(alertId).update({
      'status': AlertStatus.active.name,
    });

    _locationService.startLiveTracking(alertId);
    _audioService.startRecording(alertId);

    final mapsLink = lat != null && lng != null
        ? _locationService.buildGoogleMapsLink(lat, lng)
        : null;

    // Notify ALL contacts simultaneously
    final contacts = user.trustedContacts;
    final notifyFutures = contacts.map((contact) async {
      await _smsService.sendAlert(
        toPhone: contact.phone,
        userName: user.name,
        mapsLink: mapsLink,
        mode: mode,
      );
    });

    // FCM push to trusted contacts (server-side Cloud Function handles this)
    final fcmFuture = _firestore.collection('alert_dispatches').add({
      'alertId': alertId,
      'userId': user.uid,
      'mode': mode.name,
      'contacts': contacts.map((c) => c.toMap()).toList(),
      'lat': lat,
      'lng': lng,
      'mapsLink': mapsLink,
      'medicalProfile': user.medicalProfile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await Future.wait([...notifyFutures, fcmFuture]);

    await _firestore.collection('alerts').doc(alertId).update({
      'contactsNotified': contacts.map((c) => c.phone).toList(),
    });
  }

  // Step 7: User marks as resolved
  Future<void> resolveAlert(String alertId) async {
    _countdownTimer?.cancel();
    _locationService.stopLiveTracking();
    final audioUrl = await _audioService.stopRecording();

    await _firestore.collection('alerts').doc(alertId).update({
      'status': AlertStatus.resolved.name,
      'resolvedAt': FieldValue.serverTimestamp(),
      'audioUrl': audioUrl,
    });
    _activeAlertId = null;
  }

  void dispose() {
    _countdownController.close();
    _countdownTimer?.cancel();
  }
}
