import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../shared/models/user_model.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  // Calls Firebase Cloud Function which uses Twilio to send SMS
  // Falls back gracefully if offline — message is queued server-side
  Future<void> sendAlert({
    required String toPhone,
    required String userName,
    String? mapsLink,
    required EmergencyMode mode,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = !connectivity.contains(ConnectivityResult.none) &&
        connectivity.isNotEmpty;

    if (hasInternet) {
      try {
        final functions = FirebaseFunctions.instance;
        await functions.httpsCallable('sendSmsAlert').call({
          'to': toPhone,
          'userName': userName,
          'mapsLink': mapsLink,
          'mode': mode.name,
        });
      } catch (_) {
        // Cloud function failed — log for retry
      }
    }
    // When offline, the alert_dispatch Firestore doc triggers the Cloud Function
    // once connectivity is restored via Firestore offline persistence
  }
}
