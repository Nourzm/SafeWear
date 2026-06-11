import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_state.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../shared/models/user_model.dart';
import 'zone_editor_screen.dart';

class SafeZonesScreen extends ConsumerStatefulWidget {
  const SafeZonesScreen({super.key});

  @override
  ConsumerState<SafeZonesScreen> createState() => _SafeZonesScreenState();
}

class _SafeZonesScreenState extends ConsumerState<SafeZonesScreen> {
  static const _zoneIcons = {
    'Home': Icons.home_rounded,
    'School': Icons.school_rounded,
    'Work': Icons.work_rounded,
    'Family': Icons.family_restroom_rounded,
    'Other': Icons.place_rounded,
  };

  IconData _iconFor(String name) {
    for (final entry in _zoneIcons.entries) {
      if (name.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return Icons.place_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appStateProvider);
    final zones = user?.safeZones ?? const <SafeZone>[];

    return Scaffold(
      backgroundColor: SW.background,
      appBar: AppBar(
        title: Text('Safe Zones',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // Map preview
          Container(
            height: 220,
            margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: SW.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomPaint(
              painter: _ZoneMapPainter(zones: zones),
              child: const SizedBox.expand(),
            ),
          ),
          // Info banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SW.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active_rounded,
                    color: SW.secondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Trusted contacts are alerted automatically when you leave a safe zone at night.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: SW.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: zones.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_searching_rounded,
                            size: 56, color: SW.outline),
                        const SizedBox(height: 12),
                        Text('No safe zones yet',
                            style: GoogleFonts.manrope(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Add home, school, or work below',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: SW.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: zones.length,
                    itemBuilder: (context, i) {
                      final z = zones[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: SW.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: SW.outlineVariant.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: SW.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_iconFor(z.name),
                                  color: SW.secondary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(z.name,
                                      style: GoogleFonts.manrope(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                    z.isDrawn
                                        ? t('drawnZone')
                                        : '${z.radiusMeters.round()} m',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: SW.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: SW.tertiary),
                              onPressed: () {
                                final updated = [...zones]..removeAt(i);
                                ref
                                    .read(appStateProvider.notifier)
                                    .updateSafeZones(updated);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ZoneEditorScreen()),
        ),
        backgroundColor: SW.primary,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: Text(t('newSafeZone'),
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

}

class _ZoneMapPainter extends CustomPainter {
  final List<SafeZone> zones;
  const _ZoneMapPainter({required this.zones});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFEAEFF7));

    final rng = math.Random(3);
    final blockPaint = Paint()..color = const Color(0xFFDDE4F0);
    for (int i = 0; i < 36; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rng.nextDouble() * size.width,
            rng.nextDouble() * size.height,
            16 + rng.nextDouble() * 34,
            12 + rng.nextDouble() * 26,
          ),
          const Radius.circular(3),
        ),
        blockPaint,
      );
    }

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.55),
        Offset(size.width, size.height * 0.45), roadPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0),
        Offset(size.width * 0.5, size.height), roadPaint);

    // Saved zones at their real editor positions (circles or drawn shapes)
    final green = SW.isDark ? const Color(0xFF34C08B) : const Color(0xFF0A6C44);
    for (final z in zones) {
      if (z.isDrawn && z.polygon.length > 2) {
        final path = Path()
          ..moveTo(z.polygon.first[0] * size.width,
              z.polygon.first[1] * size.height);
        for (final p in z.polygon.skip(1)) {
          path.lineTo(p[0] * size.width, p[1] * size.height);
        }
        path.close();
        canvas.drawPath(
            path, Paint()..color = green.withValues(alpha: 0.18));
        canvas.drawPath(
          path,
          Paint()
            ..color = green
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeJoin = StrokeJoin.round,
        );
      } else {
        final c = Offset(z.mapX * size.width, z.mapY * size.height);
        final px = z.radiusMeters / 1000 * size.width * 0.45;
        canvas.drawCircle(
            c, px, Paint()..color = green.withValues(alpha: 0.18));
        canvas.drawCircle(
          c,
          px,
          Paint()
            ..color = green
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        canvas.drawCircle(c, 7, Paint()..color = green);
      }
    }

    // User dot
    final me = Offset(size.width * 0.44, size.height * 0.52);
    canvas.drawCircle(
        me, 12, Paint()..color = SW.primary.withValues(alpha: 0.25));
    canvas.drawCircle(me, 6, Paint()..color = SW.primary);
  }

  @override
  bool shouldRepaint(covariant _ZoneMapPainter old) =>
      old.zones.length != zones.length;
}
