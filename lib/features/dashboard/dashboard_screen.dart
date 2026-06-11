import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_state.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../services/alert_service.dart';
import '../../shared/models/user_model.dart';
import '../../shared/widgets/mode_selector_sheet.dart';
import '../contacts/contacts_screen.dart';
import '../emergency/emergency_screen.dart';
import '../fake_call/fake_call_screen.dart';
import '../history/alert_history_screen.dart';
import '../medical/medical_profile_screen.dart';
import '../risk_map/risk_map_screen.dart';
import '../safe_zones/safe_zones_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

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
    final user = ref.read(appStateProvider);
    if (user == null || _isTriggeringAlert) return;
    setState(() => _isTriggeringAlert = true);

    final alertId = await AlertService().startCountdown(
      user,
      user.silentTriggerMode,
    );

    if (!mounted) return;
    setState(() => _isTriggeringAlert = false);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmergencyScreen(
          alertId: alertId,
          mode: user.silentTriggerMode,
          user: user,
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openContacts() {
    final user = ref.read(appStateProvider);
    if (user == null) return;
    _push(ContactsScreen(
      contacts: user.trustedContacts,
      onChanged: (c) =>
          ref.read(appStateProvider.notifier).updateContacts(c),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appStateProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: SW.primary)),
      );
    }

    return Scaffold(
      backgroundColor: SW.background,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeTab(
            user: user,
            pulseController: _pulseController,
            onSOS: _triggerSOS,
            isTriggeringAlert: _isTriggeringAlert,
            onOpenContacts: _openContacts,
            onOpenRiskMap: () => _push(const RiskMapScreen()),
            onOpenSafeZones: () => _push(const SafeZonesScreen()),
            onOpenMedical: () => _push(const MedicalProfileScreen()),
            onOpenHistory: () => _push(const AlertHistoryScreen()),
            onOpenFakeCall: () => _push(const FakeCallScreen()),
            onOpenModeSelector: () => showModeSelectorSheet(context, ref),
          ),
          _AlertsTab(
            user: user,
            onSOS: _triggerSOS,
            onManageContacts: _openContacts,
            onOpenHistory: () => _push(const AlertHistoryScreen()),
          ),
          // Not const: must rebuild when the app language changes.
          _DeviceTab(),
          _ProfileTab(
            user: user,
            onOpenContacts: _openContacts,
            onOpenSafeZones: () => _push(const SafeZonesScreen()),
            onOpenMedical: () => _push(const MedicalProfileScreen()),
            onOpenModeSelector: () => showModeSelectorSheet(context, ref),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: SW.surfaceContainerLowest,
        indicatorColor: SW.primaryContainer.withAlpha(40),
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: t('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications_rounded),
            label: t('alerts'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.watch_outlined),
            selectedIcon: const Icon(Icons.watch_rounded),
            label: t('device'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: t('profile'),
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
  final VoidCallback onOpenContacts;
  final VoidCallback onOpenRiskMap;
  final VoidCallback onOpenSafeZones;
  final VoidCallback onOpenMedical;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenFakeCall;
  final VoidCallback onOpenModeSelector;

  const _HomeTab({
    required this.user,
    required this.pulseController,
    required this.onSOS,
    required this.isTriggeringAlert,
    required this.onOpenContacts,
    required this.onOpenRiskMap,
    required this.onOpenSafeZones,
    required this.onOpenMedical,
    required this.onOpenHistory,
    required this.onOpenFakeCall,
    required this.onOpenModeSelector,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return t('goodMorning');
    if (hour < 17) return t('goodAfternoon');
    return t('goodEvening');
  }

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
              onPressed: onOpenHistory,
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
              _GreetingCard(user: user, greeting: _greeting),
              const SizedBox(height: 20),
              _SOSSection(
                pulseController: pulseController,
                onSOS: onSOS,
                isLoading: isTriggeringAlert,
                mode: user.silentTriggerMode,
                onModeTap: onOpenModeSelector,
              ),
              const SizedBox(height: 20),
              _QuickActionsRow(
                onContacts: onOpenContacts,
                onRiskMap: onOpenRiskMap,
                onSafeZones: onOpenSafeZones,
                onMedical: onOpenMedical,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _HeartRateCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _DeviceCard()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _ContactsStatusCard(
                          count: user.trustedContacts.length,
                          onTap: onOpenContacts)),
                  const SizedBox(width: 12),
                  Expanded(child: _SafetyScoreCard()),
                ],
              ),
              const SizedBox(height: 20),
              _FakeCallBanner(onTap: onOpenFakeCall),
              const SizedBox(height: 20),
              _LocationBanner(
                zoneName:
                    user.safeZones.isNotEmpty ? user.safeZones.first.name : null,
              ),
              const SizedBox(height: 20),
              _RecentActivity(onViewAll: onOpenHistory),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      t('protected'),
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
                  label: t('contacts'),
                  value: '${user.trustedContacts.length}',
                  icon: Icons.people_rounded,
                ),
                _VertDivider(),
                _GreetingStat(
                  label: t('safeDays'),
                  value: '12',
                  icon: Icons.verified_user_rounded,
                ),
                _VertDivider(),
                _GreetingStat(
                  label: t('safeZones'),
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
  final EmergencyMode mode;
  final VoidCallback onModeTap;

  const _SOSSection({
    required this.pulseController,
    required this.onSOS,
    required this.isLoading,
    required this.mode,
    required this.onModeTap,
  });

  String get _modeLabel {
    switch (mode) {
      case EmergencyMode.contacts:
        return t('modeContacts');
      case EmergencyMode.police:
        return t('modePolice');
      case EmergencyMode.saveMe:
        return t('modeMax');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            t('emergencySos'),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: SW.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t('sosHint'),
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
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, _) {
                      final v = pulseController.value;
                      return Container(
                        width: 220 + v * 30,
                        height: 220 + v * 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SW.tertiary.withAlpha((18 * (1 - v)).round()),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, _) {
                      final v = ((pulseController.value + 0.4) % 1.0);
                      return Container(
                        width: 200 + v * 30,
                        height: 200 + v * 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SW.tertiary.withAlpha((25 * (1 - v)).round()),
                        ),
                      );
                    },
                  ),
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
                  GestureDetector(
                    onTap: isLoading ? null : onSOS,
                    child: Container(
                      width: 164,
                      height: 164,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFFCC1F26),
                            SW.tertiary,
                            Color(0xFF7A0E12)
                          ],
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
          GestureDetector(
            onTap: onModeTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: SW.surfaceContainerLow,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: SW.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 16, color: SW.primary),
                  const SizedBox(width: 8),
                  Text(
                    _modeLabel,
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
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onContacts;
  final VoidCallback onRiskMap;
  final VoidCallback onSafeZones;
  final VoidCallback onMedical;

  const _QuickActionsRow({
    required this.onContacts,
    required this.onRiskMap,
    required this.onSafeZones,
    required this.onMedical,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('quickActions'),
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
              label: t('contacts'),
              color: SW.primary,
              bg: SW.surfaceContainerHigh,
              onTap: onContacts,
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.map_rounded,
              label: t('riskMap'),
              color: const Color(0xFF7C3AED),
              bg: const Color(0xFFF3EEFF),
              onTap: onRiskMap,
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.place_rounded,
              label: t('safeZones'),
              color: SW.secondary,
              bg: SW.secondaryContainer,
              onTap: onSafeZones,
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.local_hospital_rounded,
              label: t('medical'),
              color: SW.tertiary,
              bg: const Color(0xFFFFE4E6),
              onTap: onMedical,
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

class _FakeCallBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _FakeCallBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withAlpha(70),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.phone_in_talk_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('fakeCall'),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    t('fakeCallSub'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                t('ringNow'),
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7C3AED),
                ),
              ),
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
                child: const Icon(Icons.watch_rounded,
                    color: SW.primary, size: 20),
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
  final int count;
  final VoidCallback onTap;
  const _ContactsStatusCard({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              '$count',
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
  final String? zoneName;
  const _LocationBanner({this.zoneName});

  @override
  Widget build(BuildContext context) {
    final inZone = zoneName != null;
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
            child:
                const Icon(Icons.place_rounded, color: SW.secondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('currentLocation'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SW.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  inZone
                      ? 'Hydra, Algiers — $zoneName zone ✓'
                      : 'Hydra, Algiers — GPS active',
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
  final VoidCallback onViewAll;
  const _RecentActivity({required this.onViewAll});

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
              t('recentActivity'),
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: SW.onSurface,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                t('viewAll'),
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
class _AlertsTab extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onSOS;
  final VoidCallback onManageContacts;
  final VoidCallback onOpenHistory;
  const _AlertsTab({
    required this.user,
    required this.onSOS,
    required this.onManageContacts,
    required this.onOpenHistory,
  });

  @override
  State<_AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<_AlertsTab> {
  Map<String, bool> _toggles = {};
  List<LocalAlertRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final toggles = await AppStateNotifier.loadToggles();
    final history = await AppStateNotifier.loadHistory();
    if (!mounted) return;
    setState(() {
      _toggles = toggles;
      _history = history.take(3).toList();
    });
  }

  void _setToggle(String key, bool value) {
    setState(() => _toggles[key] = value);
    AppStateNotifier.saveToggle(key, value);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day} · $h:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Scaffold(
      backgroundColor: SW.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: SW.surface.withAlpha(220),
            title: Text(
              t('alerts'),
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7A0E12),
                        SW.tertiary,
                        Color(0xFFB91C1C)
                      ],
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
                              t('emergencyHub'),
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t('hubSub'),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _AlertStatChip(
                                    icon: Icons.people_rounded,
                                    label:
                                        '${user.trustedContacts.length} ${t('contacts')}'),
                                _AlertStatChip(
                                    icon: Icons.gps_fixed_rounded,
                                    label: t('gpsActive')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _PulsingSosButton(onTap: widget.onSOS),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t('smartAlerts'),
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
                  title: t('unusualActivity'),
                  subtitle: t('unusualActivitySub'),
                  value: _toggles['unusualActivity'] ?? true,
                  onChanged: (v) => _setToggle('unusualActivity', v),
                ),
                _AlertToggleTile(
                  icon: Icons.location_off_rounded,
                  iconColor: SW.primary,
                  iconBg: SW.surfaceContainerHigh,
                  title: t('geofenceExit'),
                  subtitle: t('geofenceExitSub'),
                  value: _toggles['geofenceExit'] ?? true,
                  onChanged: (v) => _setToggle('geofenceExit', v),
                ),
                _AlertToggleTile(
                  icon: Icons.watch_off_rounded,
                  iconColor: SW.onSurfaceVariant,
                  iconBg: SW.surfaceContainerHigh,
                  title: t('deviceDisconnected'),
                  subtitle: t('deviceDisconnectedSub'),
                  value: _toggles['deviceDisconnected'] ?? false,
                  onChanged: (v) => _setToggle('deviceDisconnected', v),
                ),
                _AlertToggleTile(
                  icon: Icons.mic_off_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  iconBg: const Color(0xFFF3EEFF),
                  title: t('voiceTrigger'),
                  subtitle: t('voiceTriggerSub'),
                  value: _toggles['voiceTrigger'] ?? true,
                  onChanged: (v) => _setToggle('voiceTrigger', v),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('alertHistory'),
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: SW.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onOpenHistory,
                      child: Text(
                        t('viewAll'),
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
                if (_history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SW.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'No alerts yet — trigger the SOS to see the flow.',
                        style:
                            GoogleFonts.inter(color: SW.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  ..._history.map((r) {
                    final resolved = r.status == 'resolved';
                    return _AlertHistoryTile(
                      status: resolved ? 'Resolved' : 'Cancelled',
                      description: resolved
                          ? 'Alert dispatched to contacts'
                          : 'Manual SOS — cancelled by user',
                      date: _formatDate(r.startedAt),
                      statusColor: resolved ? SW.tertiary : SW.secondary,
                    );
                  }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('trustedContacts'),
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: SW.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onManageContacts,
                      child: Text(
                        t('manage'),
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
                  _EmptyContactsCard(onAdd: widget.onManageContacts)
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
  final VoidCallback onAdd;
  const _EmptyContactsCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SW.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SW.outlineVariant.withAlpha(80)),
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
            onPressed: onAdd,
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
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
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
                  const Icon(Icons.sos_rounded, color: Colors.white, size: 22),
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

class _AlertToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _AlertToggleTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

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
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SW.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: SW.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
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
              t('myDevice'),
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF003D70),
                        SW.primary,
                        Color(0xFF1A6FAA)
                      ],
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
                                    color:
                                        const Color(0xFF4ADE80).withAlpha(80)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.circle,
                                      color: Color(0xFF4ADE80), size: 8),
                                  const SizedBox(width: 6),
                                  Text(
                                    t('connected'),
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
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _DeviceStatBadge(
                                    icon: Icons.battery_full_rounded,
                                    value: '94%'),
                                _DeviceStatBadge(
                                    icon: Icons.bluetooth_rounded,
                                    value: 'BLE'),
                                _DeviceStatBadge(
                                    icon: Icons.wifi_rounded, value: 'Synced'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
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
                Text(
                  t('liveSensorData'),
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
                        title: t('heartRate'),
                        value: '74',
                        unit: 'bpm',
                        subtitle: t('normalRange'),
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
                        title: t('stepsToday'),
                        value: '3,241',
                        unit: '',
                        subtitle: t('ofDailyGoal'),
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
                        title: t('skinTemp'),
                        value: '36.6',
                        unit: '°C',
                        subtitle: t('normal'),
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
                        subtitle: t('excellent'),
                        gradient: null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  t('deviceActions'),
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SW.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _DeviceActionTile(
                  icon: Icons.bluetooth_searching_rounded,
                  title: t('scanDevices'),
                  subtitle: t('scanDevicesSub'),
                  onTap: () => _showScanningSheet(context),
                ),
                _DeviceActionTile(
                  icon: Icons.system_update_rounded,
                  title: t('firmwareUpdate'),
                  subtitle: t('upToDate'),
                  onTap: () {},
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: SW.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      t('latest'),
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
                  title: t('testHaptics'),
                  subtitle: t('testHapticsSub'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: SW.primary,
                        behavior: SnackBarBehavior.floating,
                        content: Text('Haptic test pattern sent to watch',
                            style: GoogleFonts.inter(color: Colors.white)),
                      ),
                    );
                  },
                ),
                _DeviceActionTile(
                  icon: Icons.link_off_rounded,
                  title: t('unpairDevice'),
                  subtitle: t('unpairDeviceSub'),
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

  void _showScanningSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SW.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                  color: SW.primary, strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            Text('Scanning for devices…',
                style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Make sure your SafeWear watch is nearby and Bluetooth is on.',
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.inter(fontSize: 13, color: SW.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
              color: isGradient ? Colors.white.withAlpha(35) : iconBg,
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
        trailing:
            trailing ?? Icon(Icons.chevron_right_rounded, color: SW.outline),
        onTap: onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PROFILE TAB
// ─────────────────────────────────────────────────────────
class _ProfileTab extends ConsumerWidget {
  final UserProfile user;
  final VoidCallback onOpenContacts;
  final VoidCallback onOpenSafeZones;
  final VoidCallback onOpenMedical;
  final VoidCallback onOpenModeSelector;

  const _ProfileTab({
    required this.user,
    required this.onOpenContacts,
    required this.onOpenSafeZones,
    required this.onOpenMedical,
    required this.onOpenModeSelector,
  });

  void _showEditProfileSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SW.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile',
                style: GoogleFonts.manrope(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(appStateProvider.notifier).saveProfile(UserProfile(
                        uid: user.uid,
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        language: user.language,
                        trustedContacts: user.trustedContacts,
                        safeZones: user.safeZones,
                        medicalProfile: user.medicalProfile,
                        silentTriggerMode: user.silentTriggerMode,
                        tier: user.tier,
                      ));
                  Navigator.pop(ctx);
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SW.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('language'),
                style: GoogleFonts.manrope(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            for (final entry in const [
              ['ar', 'العربية'],
              ['fr', 'Français'],
              ['en', 'English'],
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  user.language == entry[0]
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color:
                      user.language == entry[0] ? SW.primary : SW.outline,
                ),
                title: Text(entry[1],
                    style: GoogleFonts.manrope(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                onTap: () {
                  ref.read(appStateProvider.notifier).saveProfile(UserProfile(
                        uid: user.uid,
                        name: user.name,
                        phone: user.phone,
                        language: entry[0],
                        trustedContacts: user.trustedContacts,
                        safeZones: user.safeZones,
                        medicalProfile: user.medicalProfile,
                        silentTriggerMode: user.silentTriggerMode,
                        tier: user.tier,
                      ));
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
            'Your profile and contacts will be removed from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SW.tertiary),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(appStateProvider.notifier).clear();
              if (context.mounted) context.go('/onboarding');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: SW.background,
      body: CustomScrollView(
        slivers: [
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
                          border: Border.all(color: Colors.white38, width: 2),
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
                              ? t('freePlan')
                              : t('proPlan'),
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (user.tier == SubscriptionTier.free) ...[
                          const SizedBox(width: 10),
                          Container(
                              width: 1, height: 14, color: Colors.white30),
                          const SizedBox(width: 10),
                          Text(
                            t('upgrade'),
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
                          label: t('contacts'),
                          icon: Icons.people_rounded,
                          color: SW.primary,
                        ),
                        _ProfileStatDivider(),
                        _ProfileStat(
                          value: '12',
                          label: t('safeDays'),
                          icon: Icons.verified_user_rounded,
                          color: SW.secondary,
                        ),
                        _ProfileStatDivider(),
                        _ProfileStat(
                          value: '${user.safeZones.length}',
                          label: t('safeZones'),
                          icon: Icons.place_rounded,
                          color: SW.tertiary,
                        ),
                      ],
                    ),
                  ),
                ),
                _SectionLabel(label: t('account')),
                _ProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  label: t('editProfile'),
                  onTap: () => _showEditProfileSheet(context, ref),
                ),
                _ProfileMenuItem(
                  icon: Icons.contacts_outlined,
                  label: t('trustedContacts'),
                  badge: '${user.trustedContacts.length}',
                  onTap: onOpenContacts,
                ),
                _ProfileMenuItem(
                  icon: Icons.language_rounded,
                  label: t('language'),
                  value: user.language.toUpperCase(),
                  onTap: () => _showLanguageSheet(context, ref),
                ),
                const SizedBox(height: 12),
                _SectionLabel(label: t('safety')),
                _ProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  label: t('safeZones'),
                  badge: '${user.safeZones.length}',
                  onTap: onOpenSafeZones,
                ),
                _ProfileMenuItem(
                  icon: Icons.local_hospital_rounded,
                  label: t('medicalProfile'),
                  onTap: onOpenMedical,
                ),
                _ProfileMenuItem(
                  icon: Icons.shield_outlined,
                  label: t('emergencyMode'),
                  onTap: onOpenModeSelector,
                ),
                const SizedBox(height: 12),
                _SectionLabel(label: t('app')),
                _ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  label: t('notifications'),
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.security_outlined,
                  label: t('privacySecurity'),
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  label: t('helpSupport'),
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _SectionLabel(label: t('subscription')),
                _ProfileMenuItem(
                  icon: Icons.star_outline_rounded,
                  label: t('upgradeToPro'),
                  iconColor: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFEF3C7),
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: t('signOut'),
                  color: SW.tertiary,
                  onTap: () => _confirmSignOut(context, ref),
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
  final VoidCallback onTap;
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        onTap: onTap,
      ),
    );
  }
}
