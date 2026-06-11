import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_state.dart';
import '../../app/i18n.dart';
import '../../services/alert_service.dart';
import '../emergency/emergency_screen.dart';

enum _WatchState { home, fallDetected, alertSent }

/// Simulates the SafeWear watch (Sentinel X) so the full watch -> phone
/// emergency flow can be demonstrated without hardware: live heart rate,
/// fall detection with an on-watch countdown, and automatic escalation to
/// the phone's real SOS dispatch.
class WatchDemoScreen extends ConsumerStatefulWidget {
  const WatchDemoScreen({super.key});

  @override
  ConsumerState<WatchDemoScreen> createState() => _WatchDemoScreenState();
}

class _WatchDemoScreenState extends ConsumerState<WatchDemoScreen>
    with TickerProviderStateMixin {
  _WatchState _state = _WatchState.home;

  // Simulated vitals
  int _hr = 74;
  bool _hrSpiking = false;
  Timer? _hrTimer;
  final _rng = math.Random();

  // Fall countdown
  int _fallSecondsLeft = 10;
  Timer? _fallTimer;

  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _hrTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!mounted) return;
      setState(() {
        final target = _hrSpiking ? 122 : 74;
        _hr += ((target - _hr) * 0.3).round() + _rng.nextInt(3) - 1;
        _hr = _hr.clamp(58, 135);
      });
    });
  }

  @override
  void dispose() {
    _hrTimer?.cancel();
    _fallTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _simulateFall() {
    if (_state != _WatchState.home) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _state = _WatchState.fallDetected;
      _hrSpiking = true;
      _fallSecondsLeft = 10;
    });
    _fallTimer?.cancel();
    _fallTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(() => _fallSecondsLeft--);
      if (_fallSecondsLeft <= 0) {
        timer.cancel();
        _escalateToPhone();
      }
    });
  }

  void _imOk() {
    _fallTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() {
      _state = _WatchState.home;
      _hrSpiking = false;
    });
  }

  Future<void> _escalateToPhone() async {
    setState(() => _state = _WatchState.alertSent);
    final user = ref.read(appStateProvider);
    if (user == null) return;
    final alertId = await AlertService().startCountdown(
      user,
      user.silentTriggerMode,
    );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmergencyScreen(
          alertId: alertId,
          mode: user.silentTriggerMode,
          user: user,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _state = _WatchState.home;
      _hrSpiking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(t('watchDemo'),
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800, color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // ── The watch ──
            _WatchBezel(
              child: switch (_state) {
                _WatchState.home => _buildHomeFace(),
                _WatchState.fallDetected => _buildFallFace(),
                _WatchState.alertSent => _buildSentFace(),
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Sentinel Watch X',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white54,
              ),
            ),
            const Spacer(),
            // ── Demo controls ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                children: [
                  Text(
                    t('watchDemoHint'),
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.inter(fontSize: 13, color: Colors.white38),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _DemoButton(
                          icon: Icons.personal_injury_rounded,
                          label: t('simulateFall'),
                          color: const Color(0xFFD97706),
                          onTap: _simulateFall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DemoButton(
                          icon: _hrSpiking
                              ? Icons.monitor_heart_rounded
                              : Icons.favorite_rounded,
                          label: _hrSpiking ? t('calmHr') : t('spikeHr'),
                          color: const Color(0xFFFF4D6D),
                          onTap: () =>
                              setState(() => _hrSpiking = !_hrSpiking),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Watch faces ──

  Widget _buildHomeFace() {
    final now = TimeOfDay.now();
    final hh = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final mm = now.minute.toString().padLeft(2, '0');
    final hrColor =
        _hr > 100 ? const Color(0xFFFFB74D) : const Color(0xFFFF4D6D);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$hh:$mm',
          style: GoogleFonts.manrope(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        // Heart rate
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.85, end: 1.1).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Icon(Icons.favorite_rounded, color: hrColor, size: 22),
            ),
            const SizedBox(width: 6),
            Text(
              '$_hr',
              style: GoogleFonts.manrope(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: hrColor,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'bpm',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Status pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                t('protected'),
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4ADE80),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Watch SOS button
        GestureDetector(
          onTap: _simulateFall,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCC1F26), Color(0xFFA3151C)],
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'SOS',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallFace() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0xFF7A0E12), Color(0xFF3D0608)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.personal_injury_rounded,
              color: Colors.white, size: 30),
          const SizedBox(height: 6),
          Text(
            t('fallDetected'),
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Countdown ring
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: _fallSecondsLeft / 10,
                    strokeWidth: 5,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text(
                  '$_fallSecondsLeft',
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _imOk,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                t('imOk'),
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7A0E12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded,
            color: Color(0xFF4ADE80), size: 40),
        const SizedBox(height: 10),
        Text(
          t('alertSent'),
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t('phoneTakingOver'),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
        ),
      ],
    );
  }
}

class _WatchBezel extends StatelessWidget {
  final Widget child;
  const _WatchBezel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Strap top
        Container(
          width: 90,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF1C212B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
        ),
        // Watch body
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A4150), Color(0xFF14181F)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: const Color(0xFF5B9BD8).withValues(alpha: 0.08),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF05070A),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
        // Strap bottom
        Container(
          width: 90,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF1C212B),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
          ),
        ),
      ],
    );
  }
}

class _DemoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DemoButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
