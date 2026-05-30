import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../../services/alert_service.dart';
import '../../shared/models/user_model.dart';
import '../emergency/emergency_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final UserProfile user;
  const DashboardScreen({super.key, required this.user});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  bool _isTriggeringAlert = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    if (_isTriggeringAlert) return;
    setState(() => _isTriggeringAlert = true);

    final alertId = await AlertService().startCountdown(
      widget.user,
      widget.user.silentTriggerMode,
    );

    if (!mounted) return;
    setState(() => _isTriggeringAlert = false);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmergencyScreen(
          alertId: alertId,
          mode: widget.user.silentTriggerMode,
          user: widget.user,
        ),
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SW.background,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeTab(
            user: widget.user,
            pulseController: _pulseController,
            onSOS: _triggerSOS,
            isTriggeringAlert: _isTriggeringAlert,
            greeting: _greeting,
          ),
          _AlertsTab(user: widget.user),
          _DeviceTab(),
          _ProfileTab(user: widget.user),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: SW.surfaceContainerLowest,
        indicatorColor: SW.primaryContainer.withAlpha(40),
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.watch_outlined),
            selectedIcon: Icon(Icons.watch_rounded),
            label: 'Device',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final UserProfile user;
  final AnimationController pulseController;
  final VoidCallback onSOS;
  final bool isTriggeringAlert;
  final String greeting;

  const _HomeTab({
    required this.user,
    required this.pulseController,
    required this.onSOS,
    required this.isTriggeringAlert,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: SW.surface.withAlpha(220),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: SW.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'SafeWear',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: SW.primary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined, color: SW.onSurface),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: SW.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {},
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: SW.primaryContainer,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Greeting Hero Card ──
              _GreetingCard(user: user, greeting: greeting),
              const SizedBox(height: 20),
              // ── SOS Section ──
              _SOSSection(
                pulseController: pulseController,
                onSOS: onSOS,
                isLoading: isTriggeringAlert,
              ),
              const SizedBox(height: 20),
              // ── Quick Actions ──
              _QuickActionsRow(),
              const SizedBox(height: 20),
              // ── Bento Grid Row 1: HR + Device ──
              Row(
                children: [
                  Expanded(child: _HeartRateCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _DeviceCard()),
                ],
              ),
              const SizedBox(height: 12),
              // ── Bento Grid Row 2: Contacts + Safety Score ──
              Row(
                children: [
                  Expanded(child: _ContactsStatusCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _SafetyScoreCard()),
                ],
              ),
              const SizedBox(height: 20),
              // ── Location Status Banner ──
              _LocationBanner(),
              const SizedBox(height: 20),
              // ── Recent Activity ──
              _RecentActivity(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final UserProfile user;
  final String greeting;
  const _GreetingCard({required this.user, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D70), SW.primary, Color(0xFF1A6FAA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: SW.primary.withAlpha(80),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white60,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.name.isNotEmpty ? user.name : 'SafeWear User',
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4ADE80).withAlpha(150),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Protected',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: Row(
              children: [
                _GreetingStat(
                  label: 'Contacts',
                  value: '${user.trustedContacts.length}',
                  icon: Icons.people_rounded,
                ),
                _VertDivider(),
                _GreetingStat(
                  label: 'Safe Days',
                  value: '12',
                  icon: Icons.verified_user_rounded,
                ),
                _VertDivider(),
                _GreetingStat(
                  label: 'Safe Zones',
                  value: '${user.safeZones.length}',
                  icon: Icons.place_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withAlpha(40),
    );
  }
}

class _GreetingStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _GreetingStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _SOSSection extends StatelessWidget {
  final AnimationController pulseController;
  final VoidCallback onSOS;
  final bool isLoading;

  const _SOSSection({
    required this.pulseController,
    required this.onSOS,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Instructional label
          Text(
            'EMERGENCY SOS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: SW.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hold button for 2 seconds to activate',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: SW.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring 1
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, _) {
                      final v = pulseController.value;
                      return Container(
                        width: 220 + v * 30,
                        height: 220 + v * 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SW.tertiary
                              .withAlpha((18 * (1 - v)).round()),
                        ),
                      );
                    },
                  ),
                  // Outer pulse ring 2 (offset)
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, _) {
                      final v = ((pulseController.value + 0.4) % 1.0);
                      return Container(
                        width: 200 + v * 30,
                        height: 200 + v * 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SW.tertiary
                              .withAlpha((25 * (1 - v)).round()),
                        ),
                      );
                    },
                  ),
                  // Static halo
                  Container(
                    width: 196,
                    height: 196,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SW.tertiary.withAlpha(12),
                      border: Border.all(
                        color: SW.tertiary.withAlpha(30),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Main SOS button
                  GestureDetector(
                    onTap: isLoading ? null : onSOS,
                    child: Container(
                      width: 164,
                      height: 164,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFCC1F26), SW.tertiary, Color(0xFF7A0E12)],
                          stops: [0.0, 0.6, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SW.tertiary.withAlpha(100),
                            blurRadius: 40,
                            spreadRadius: 8,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: SW.tertiary.withAlpha(40),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sos_rounded,
                                    color: Colors.white, size: 56),
                                Text(
                                  'SOS',
                                  style: GoogleFonts.manrope(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Mode label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: SW.surfaceContainerLow,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: SW.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: SW.primary),
                const SizedBox(width: 8),
                Text(
                  'Mode: Notify Contacts',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SW.primary,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: SW.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: SW.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickAction(
              icon: Icons.people_alt_rounded,
              label: 'Contacts',
              color: SW.primary,
              bg: SW.surfaceContainerHigh,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.map_rounded,
              label: 'Risk Map',
              color: const Color(0xFF7C3AED),
              bg: const Color(0xFFF3EEFF),
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.place_rounded,
              label: 'Safe Zones',
              color: SW.secondary,
              bg: SW.secondaryContainer,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.local_hospital_rounded,
              label: 'Medical',
              color: SW.tertiary,
              bg: const Color(0xFFFFE4E6),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: SW.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartRateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simulated HR data points
    final points = [0.55, 0.4, 0.7, 0.5, 0.8, 0.6, 0.75, 0.5, 0.65];
    return Container(
      height: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4D6D), Color(0xFFFF8FA3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4D6D).withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 18),
              ),
              Text(
                'LIVE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '74',
                style: GoogleFonts.manrope(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  'bpm',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Mini sparkline
          SizedBox(
            height: 30,
            child: CustomPaint(
              size: const Size(double.infinity, 30),
              painter: _SparklinePainter(points: points),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  _SparklinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final step = size.width / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final x = i * step;
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * step;
        final prevY = size.height * (1 - points[i - 1]);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.points != points;
}

class _DeviceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SW.outlineVariant.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: SW.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.watch_rounded, color: SW.primary, size: 20),
              ),
              _BatteryBar(percent: 0.94),
            ],
          ),
          const Spacer(),
          Text(
            'Sentinel X',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SW.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'SafeWear Watch',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: SW.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Connected · 94%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SW.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatteryBar extends StatelessWidget {
  final double percent;
  const _BatteryBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${(percent * 100).round()}%',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: SW.onSurface,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          height: 14,
          child: CustomPaint(painter: _BatteryPainter(percent: percent)),
        ),
      ],
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final double percent;
  const _BatteryPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyW = size.width - 3;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 1, bodyW, size.height - 2),
      const Radius.circular(3),
    );
    final bodyPaint = Paint()
      ..color = SW.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(bodyRect, bodyPaint);

    final fillPaint = Paint()
      ..color = percent > 0.3 ? SW.secondary : SW.tertiary
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 3, (bodyW - 4) * percent, size.height - 6),
        const Radius.circular(2),
      ),
      fillPaint,
    );

    // nub
    final nubPaint = Paint()
      ..color = SW.outlineVariant
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyW, size.height * 0.3, 3, size.height * 0.4),
        const Radius.circular(1),
      ),
      nubPaint,
    );
  }

  @override
  bool shouldRepaint(_BatteryPainter old) => old.percent != percent;
}

class _ContactsStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [SW.secondary.withAlpha(220), SW.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SW.secondary.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.people_alt_rounded,
                    color: Colors.white, size: 18),
              ),
              Text(
                'ACTIVE',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '3',
            style: GoogleFonts.manrope(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          Text(
            'Contacts on alert',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const score = 94;
    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SW.outlineVariant.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SW.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified_user_rounded,
                    color: SW.primary, size: 18),
              ),
              Text(
                'SAFETY',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: SW.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: SW.primary,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  '/100',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: SW.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Safety Score',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: SW.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SW.outlineVariant.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: SW.primary.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SW.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.place_rounded, color: SW.secondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SW.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hydra, Algiers — Safe Zone ✓',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SW.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.gps_fixed_rounded, color: SW.secondary, size: 20),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      _ActivityItem(
        icon: Icons.location_on_rounded,
        iconColor: SW.secondary,
        iconBg: SW.secondaryContainer,
        title: 'Safe zone entered',
        subtitle: 'Home — Hydra, Algiers',
        time: '2h ago',
        isAlert: false,
      ),
      _ActivityItem(
        icon: Icons.favorite_rounded,
        iconColor: const Color(0xFFFF4D6D),
        iconBg: const Color(0xFFFFE4E8),
        title: 'Heart rate normal',
        subtitle: '74 bpm — resting',
        time: '3h ago',
        isAlert: false,
      ),
      _ActivityItem(
        icon: Icons.notifications_rounded,
        iconColor: SW.primary,
        iconBg: SW.surfaceContainerHigh,
        title: 'Check-in reminder sent',
        subtitle: 'Sent to 3 contacts',
        time: '5h ago',
        isAlert: false,
      ),
      _ActivityItem(
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFD97706),
        iconBg: const Color(0xFFFEF3C7),
        title: 'Unusual HR detected',
        subtitle: '112 bpm — auto-resolved',
        time: 'Yesterday',
        isAlert: true,
      ),
      _ActivityItem(
        icon: Icons.battery_charging_full_rounded,
        iconColor: SW.onSurfaceVariant,
        iconBg: SW.surfaceContainerHigh,
        title: 'Device fully charged',
        subtitle: 'Sentinel X',
        time: 'Yesterday',
        isAlert: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: SW.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: SW.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...activities.map((a) => _ActivityTile(item: a)),
      ],
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String time;
  final bool isAlert;
  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isAlert,
  });
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: item.isAlert
            ? Border.all(color: const Color(0xFFD97706).withAlpha(80))
            : Border.all(color: SW.outlineVariant.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SW.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: SW.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.time,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: SW.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ALERTS TAB
// ─────────────────────────────────────────────────────────
class _AlertsTab extends StatelessWidget {
  final UserProfile user;
  const _AlertsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SW.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: SW.surface.withAlpha(220),
            title: Text(
              'Alerts',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Emergency Hub hero
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7A0E12), SW.tertiary, Color(0xFFB91C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: SW.tertiary.withAlpha(80),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Hub',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'One tap alerts your entire network simultaneously.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _AlertStatChip(
                                    icon: Icons.people_rounded,
                                    label: '3 contacts'),
                                const SizedBox(width: 8),
                                _AlertStatChip(
                                    icon: Icons.gps_fixed_rounded,
                                    label: 'GPS active'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _PulsingSosButton(onTap: () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Smart alerts toggles
                Text(
                  'Smart Alerts',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SW.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _AlertToggleTile(
                  icon: Icons.warning_rounded,
                  iconColor: const Color(0xFFD97706),
                  iconBg: const Color(0xFFFEF3C7),
                  title: 'Unusual Activity',
                  subtitle: 'Alert when vitals spike unexpectedly',
                  value: true,
                ),
                _AlertToggleTile(
                  icon: Icons.location_off_rounded,
                  iconColor: SW.primary,
                  iconBg: SW.surfaceContainerHigh,
                  title: 'Geofence Exit',
                  subtitle: 'Alert when leaving safe zones',
                  value: true,
                ),
                _AlertToggleTile(
                  icon: Icons.watch_off_rounded,
                  iconColor: SW.onSurfaceVariant,
                  iconBg: SW.surfaceContainerHigh,
                  title: 'Device Disconnected',
                  subtitle: 'Alert when watch loses connection',
                  value: false,
                ),
                _AlertToggleTile(
                  icon: Icons.mic_off_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  iconBg: const Color(0xFFF3EEFF),
                  title: 'Voice Trigger',
                  subtitle: '"SafeWear contacts" activates silent alert',
                  value: true,
                ),
                const SizedBox(height: 24),

                // Alert history
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alert History',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: SW.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: SW.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '3 this month',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SW.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _AlertHistoryTile(
                  status: 'Cancelled',
                  description: 'Manual SOS — cancelled by user',
                  date: 'May 10, 2026 · 10:14 PM',
                  statusColor: SW.secondary,
                ),
                _AlertHistoryTile(
                  status: 'Resolved',
                  description: 'Unusual HR · 112 bpm detected',
                  date: 'May 8, 2026 · 2:33 AM',
                  statusColor: const Color(0xFFD97706),
                ),
                _AlertHistoryTile(
                  status: 'Resolved',
                  description: 'Geofence exit · School zone',
                  date: 'Apr 29, 2026 · 4:12 PM',
                  statusColor: SW.primary,
                ),
                const SizedBox(height: 24),

                // Trusted contacts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trusted Contacts',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: SW.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Manage',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: SW.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (user.trustedContacts.isEmpty)
                  _EmptyContactsCard()
                else
                  ...user.trustedContacts.map((c) => _ContactTile(contact: c)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AlertStatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertHistoryTile extends StatelessWidget {
  final String status;
  final String description;
  final String date;
  final Color statusColor;
  const _AlertHistoryTile({
    required this.status,
    required this.description,
    required this.date,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SW.outlineVariant.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications_rounded,
                color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SW.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: SW.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(18),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              status,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyContactsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: SW.outlineVariant.withAlpha(80), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.people_outline, size: 48, color: SW.outline),
          const SizedBox(height: 12),
          Text(
            'No trusted contacts yet',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              color: SW.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add people who will be alerted during emergencies',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: SW.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }
}

class _PulsingSosButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PulsingSosButton({required this.onTap});

  @override
  State<_PulsingSosButton> createState() => _PulsingSosButtonState();
}

class _PulsingSosButtonState extends State<_PulsingSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => Container(
                width: 70 + _ctrl.value * 10,
                height: 70 + _ctrl.value * 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SW.tertiary.withAlpha((50 * (1 - _ctrl.value)).round()),
                ),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFCC1F26), SW.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sos_rounded,
                      color: Colors.white, size: 22),
                  Text(
                    'SOS',
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertToggleTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  const _AlertToggleTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  State<_AlertToggleTile> createState() => _AlertToggleTileState();
}

class _AlertToggleTileState extends State<_AlertToggleTile> {
  late bool _val;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SW.outlineVariant.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SW.onSurface,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: SW.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(
            value: _val,
            onChanged: (v) => setState(() => _val = v),
            activeThumbColor: Colors.white,
            activeTrackColor: SW.secondary,
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final TrustedContact contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final colors = [
      SW.primary,
      SW.secondary,
      const Color(0xFF7C3AED),
      const Color(0xFFD97706),
      SW.tertiary,
    ];
    final color = colors[contact.name.codeUnitAt(0) % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SW.outlineVariant.withAlpha(50)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withAlpha(25),
            child: Text(
              contact.name[0].toUpperCase(),
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SW.onSurface,
                  ),
                ),
                Text(
                  '${contact.role} · ${contact.phone}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: SW.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: SW.secondary.withAlpha(18),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: SW.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Ready',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SW.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// DEVICE TAB
// ─────────────────────────────────────────────────────────
class _DeviceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SW.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: SW.surface.withAlpha(220),
            title: Text(
              'My Device',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Device Hero Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF003D70), SW.primary, Color(0xFF1A6FAA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: SW.primary.withAlpha(80),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ADE80).withAlpha(40),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: const Color(0xFF4ADE80).withAlpha(80)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.circle,
                                      color: Color(0xFF4ADE80), size: 8),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Connected',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF4ADE80),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Sentinel Watch X',
                              style: GoogleFonts.manrope(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'SafeWear Wearable · v2.1.0',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _DeviceStatBadge(
                                    icon: Icons.battery_full_rounded,
                                    value: '94%'),
                                const SizedBox(width: 10),
                                _DeviceStatBadge(
                                    icon: Icons.bluetooth_rounded,
                                    value: 'BLE'),
                                const SizedBox(width: 10),
                                _DeviceStatBadge(
                                    icon: Icons.wifi_rounded,
                                    value: 'Synced'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Watch illustration placeholder
                      Container(
                        width: 72,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.watch_rounded,
                                color: Colors.white, size: 36),
                            const SizedBox(height: 4),
                            Text(
                              '12:42',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Live sensor readings
                Text(
                  'Live Sensor Data',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SW.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SensorCard(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFFFF4D6D),
                        iconBg: const Color(0xFFFFE4E8),
                        title: 'Heart Rate',
                        value: '74',
                        unit: 'bpm',
                        subtitle: 'Normal range',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4D6D), Color(0xFFFF8FA3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SensorCard(
                        icon: Icons.directions_walk_rounded,
                        iconColor: const Color(0xFF7C3AED),
                        iconBg: const Color(0xFFF3EEFF),
                        title: 'Steps Today',
                        value: '3,241',
                        unit: 'steps',
                        subtitle: '32% of daily goal',
                        gradient: null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SensorCard(
                        icon: Icons.thermostat_rounded,
                        iconColor: const Color(0xFFD97706),
                        iconBg: const Color(0xFFFEF3C7),
                        title: 'Skin Temp',
                        value: '36.6',
                        unit: '°C',
                        subtitle: 'Normal',
                        gradient: null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SensorCard(
                        icon: Icons.air_rounded,
                        iconColor: SW.secondary,
                        iconBg: SW.secondaryContainer,
                        title: 'SpO₂',
                        value: '98',
                        unit: '%',
                        subtitle: 'Excellent',
                        gradient: null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Device actions
                Text(
                  'Device Actions',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SW.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _DeviceActionTile(
                  icon: Icons.bluetooth_searching_rounded,
                  title: 'Scan for Devices',
                  subtitle: 'Find SafeWear devices nearby',
                  onTap: () {},
                ),
                _DeviceActionTile(
                  icon: Icons.system_update_rounded,
                  title: 'Firmware Update',
                  subtitle: 'v2.1.0 — Up to date',
                  onTap: () {},
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: SW.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Latest',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: SW.secondary,
                      ),
                    ),
                  ),
                ),
                _DeviceActionTile(
                  icon: Icons.vibration_rounded,
                  title: 'Test Haptics',
                  subtitle: 'Verify alert vibration patterns',
                  onTap: () {},
                ),
                _DeviceActionTile(
                  icon: Icons.link_off_rounded,
                  title: 'Unpair Device',
                  subtitle: 'Remove this device from your account',
                  color: SW.tertiary,
                  onTap: () {},
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceStatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  const _DeviceStatBadge({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final LinearGradient? gradient;
  const _SensorCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isGradient = gradient != null;
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        color: isGradient ? null : SW.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: isGradient
            ? null
            : Border.all(color: SW.outlineVariant.withAlpha(80)),
        boxShadow: isGradient
            ? [
                BoxShadow(
                  color: iconColor.withAlpha(50),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isGradient
                  ? Colors.white.withAlpha(35)
                  : iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: isGradient ? Colors.white : iconColor, size: 18),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isGradient ? Colors.white : SW.onSurface,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 3),
                child: Text(
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isGradient ? Colors.white70 : SW.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isGradient ? Colors.white70 : SW.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;
  const _DeviceActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? SW.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SW.outlineVariant.withAlpha(50)),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: c.withAlpha(18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: c, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: c,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 12, color: SW.onSurfaceVariant),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: SW.outline),
        onTap: onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PROFILE TAB
// ─────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final UserProfile user;
  const _ProfileTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SW.background,
      body: CustomScrollView(
        slivers: [
          // Profile hero header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003D70), SW.primary, Color(0xFF1A6FAA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(25),
                          border:
                              Border.all(color: Colors.white38, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.manrope(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4)
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.name.isEmpty ? 'SafeWear User' : user.name,
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone.isEmpty ? '+213 — — — — — — —' : user.phone,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFD700), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          user.tier == SubscriptionTier.free
                              ? 'Free Plan'
                              : 'Pro Plan',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (user.tier == SubscriptionTier.free) ...[
                          const SizedBox(width: 10),
                          Container(
                            width: 1,
                            height: 14,
                            color: Colors.white30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Upgrade',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SW.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _ProfileStat(
                          value: '${user.trustedContacts.length}',
                          label: 'Contacts',
                          icon: Icons.people_rounded,
                          color: SW.primary,
                        ),
                        _ProfileStatDivider(),
                        _ProfileStat(
                          value: '12',
                          label: 'Safe Days',
                          icon: Icons.verified_user_rounded,
                          color: SW.secondary,
                        ),
                        _ProfileStatDivider(),
                        _ProfileStat(
                          value: '3',
                          label: 'Alerts',
                          icon: Icons.notifications_rounded,
                          color: SW.tertiary,
                        ),
                      ],
                    ),
                  ),
                ),

                // Settings sections
                _SectionLabel(label: 'Account'),
                _ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile'),
                _ProfileMenuItem(
                    icon: Icons.contacts_outlined,
                    label: 'Trusted Contacts',
                    badge: '${user.trustedContacts.length}'),
                _ProfileMenuItem(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    value: user.language.toUpperCase()),
                const SizedBox(height: 12),

                _SectionLabel(label: 'Safety'),
                _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Safe Zones',
                    badge: '${user.safeZones.length}'),
                _ProfileMenuItem(
                    icon: Icons.local_hospital_rounded,
                    label: 'Medical Profile'),
                _ProfileMenuItem(
                    icon: Icons.shield_outlined,
                    label: 'Emergency Mode'),
                const SizedBox(height: 12),

                _SectionLabel(label: 'App'),
                _ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications'),
                _ProfileMenuItem(
                    icon: Icons.security_outlined,
                    label: 'Privacy & Security'),
                _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support'),
                const SizedBox(height: 12),

                _SectionLabel(label: 'Subscription'),
                _ProfileMenuItem(
                  icon: Icons.star_outline_rounded,
                  label: 'Upgrade to Pro',
                  iconColor: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFEF3C7),
                ),
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  color: SW.tertiary,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: SW.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: SW.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: SW.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: SW.outlineVariant,
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? iconColor;
  final Color? bgColor;
  final String? badge;
  final String? value;
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.color,
    this.iconColor,
    this.bgColor,
    this.badge,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = color ?? SW.onSurface;
    final iconC = iconColor ?? color ?? SW.primary;
    final iconBackground = bgColor ?? SW.surfaceContainerHigh;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SW.outlineVariant.withAlpha(50)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: iconC, size: 20),
        ),
        title: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(
                value!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: SW.onSurfaceVariant,
                ),
              ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SW.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: SW.primary,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: SW.outline, size: 20),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
