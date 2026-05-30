import 'dart:io';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  String? _currentPath;

  Future<void> startRecording(String alertId) async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    _currentPath = '${dir.path}/alert_$alertId.m4a';

    await _recorder.start(
      RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
      path: _currentPath!,
    );
  }

  // Returns Firebase Storage URL of the uploaded audio, or null on failure
  Future<String?> stopRecording() async {
    if (!await _recorder.isRecording()) return null;
    final path = await _recorder.stop();
    if (path == null) return null;

    try {
      final file = File(path);
      final fileName = path.split('/').last;
      final ref = FirebaseStorage.instance.ref('alert_audio/$fileName');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      await file.delete();
      return url;
    } catch (_) {
      return null;
    }
  }
}
