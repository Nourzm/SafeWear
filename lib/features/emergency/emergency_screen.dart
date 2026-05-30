import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../services/alert_service.dart';
import '../../shared/models/user_model.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  final String alertId;
  final EmergencyMode mode;
  final UserProfile user;

  const EmergencyScreen({
    super.key,
    required this.alertId,
    required this.mode,
    required this.user,
  });

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription<int>? _countdownSub;
  int _secondsLeft = 20;
  bool _alertFired = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.vibrate();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: SW.tertiary),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _countdownSub = AlertService().countdownStream.listen((secs) {
      if (!mounted) return;
      setState(() => _secondsLeft = secs);
      if (secs <= 0 && !_alertFired) {
        setState(() => _alertFired = true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownSub?.cancel();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  Future<void> _cancel() async {
    await AlertService().cancelAlert(widget.alertId);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _resolve() async {
    await AlertService().resolveAlert(widget.alertId);
    if (mounted) Navigator.of(context).pop();
  }

  String get _modeLabel {
    switch (widget.mode) {
      case EmergencyMode.contacts:
        return 'Notifying your contacts';
      case EmergencyMode.police:
        return 'Notifying contacts + police';
      case EmergencyMode.saveMe:
        return 'Maximum response — all services';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _alertFired ? SW.tertiary : Colors.black87,
        body: SafeArea(
          child: _alertFired ? _buildActiveAlert() : _buildCountdown(),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          'ALERT IN',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 18,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 16),
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SW.tertiary,
              boxShadow: [
                BoxShadow(
                  color: SW.tertiary.withValues(alpha: 0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_secondsLeft',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          _modeLabel,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _cancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: SW.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "I'M SAFE — CANCEL",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveAlert() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Icon(Icons.warning_rounded, color: Colors.white, size: 80),
        const SizedBox(height: 24),
        const Text(
          'ALERT SENT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _modeLabel,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Live location & audio streaming active',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _resolve,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: SW.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "I'M SAFE NOW",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
