import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _activeAlertStream;

  Future<Position?> getCurrentPosition() async {
    final permission = await _ensurePermission();
    if (!permission) return null;
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<bool> _ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Called when an alert fires — streams live GPS to Firestore every 5 seconds
  void startLiveTracking(String alertId) {
    _activeAlertStream?.cancel();
    _activeAlertStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      FirebaseFirestore.instance.collection('alerts').doc(alertId).update({
        'lat': position.latitude,
        'lng': position.longitude,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  void stopLiveTracking() {
    _activeAlertStream?.cancel();
    _activeAlertStream = null;
  }

  String buildGoogleMapsLink(double lat, double lng) {
    return 'https://maps.google.com/?q=$lat,$lng';
  }
}
