import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

/// Simulates an incoming phone call so the user has a discreet excuse to
/// leave an uncomfortable situation. A flagship SafeWear feature.
class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen>
    with SingleTickerProviderStateMixin {
  bool _answered = false;
  int _callSeconds = 0;
  Timer? _timer;
  Timer? _vibrateTimer;
  late AnimationController _ring;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    // Vibrate like a real incoming call until answered
    HapticFeedback.vibrate();
    _vibrateTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!_answered) HapticFeedback.vibrate();
    });
  }

  void _answer() {
    setState(() => _answered = true);
    _vibrateTimer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callSeconds++);
    });
  }

  void _end() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vibrateTimer?.cancel();
    _ring.dispose();
    super.dispose();
  }

  String get _duration {
    final m = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_callSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              _answered ? _duration : 'Incoming call…',
              style: GoogleFonts.inter(
                  fontSize: 15, color: Colors.white.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 28),
            // Caller avatar with ring animation
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_answered)
                    AnimatedBuilder(
                      animation: _ring,
                      builder: (context, _) => Container(
                        width: 130 + _ring.value * 50,
                        height: 130 + _ring.value * 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.3 * (1 - _ring.value)),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF2B6CB0), SW.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'M',
                        style: GoogleFonts.manrope(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mom',
              style: GoogleFonts.manrope(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'mobile  +213 555 01 02 03',
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.white.withValues(alpha: 0.5)),
            ),
            const Spacer(),
            if (!_answered)
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 0, 48, 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CallButton(
                      color: const Color(0xFFE53935),
                      icon: Icons.call_end_rounded,
                      label: 'Decline',
                      onTap: _end,
                    ),
                    _CallButton(
                      color: const Color(0xFF43A047),
                      icon: Icons.call_rounded,
                      label: 'Accept',
                      onTap: _answer,
                    ),
                  ],
                ),
              )
            else ...[
              // In-call control grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Wrap(
                  spacing: 28,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: const [
                    _InCallIcon(icon: Icons.mic_off_rounded, label: 'mute'),
                    _InCallIcon(icon: Icons.dialpad_rounded, label: 'keypad'),
                    _InCallIcon(
                        icon: Icons.volume_up_rounded, label: 'speaker'),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: _CallButton(
                  color: const Color(0xFFE53935),
                  icon: Icons.call_end_rounded,
                  label: 'End',
                  onTap: _end,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CallButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

class _InCallIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InCallIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}
