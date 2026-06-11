import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../shared/models/user_model.dart';

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
              painter: _ZoneMapPainter(zoneCount: zones.length),
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
                const Icon(Icons.notifications_active_rounded,
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
                        const Icon(Icons.location_searching_rounded,
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
                                    '${z.radiusMeters.round()} m radius · monitoring active',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: SW.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
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
        onPressed: () => _showAddSheet(context, zones),
        backgroundColor: SW.primary,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Add Zone', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddSheet(BuildContext context, List<SafeZone> zones) {
    final nameCtrl = TextEditingController();
    double radius = 200;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SW.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Safe Zone',
                  style: GoogleFonts.manrope(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Zone name (e.g. Home, School)',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 20),
              Text('Radius: ${radius.round()} m',
                  style: GoogleFonts.manrope(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              Slider(
                value: radius,
                min: 100,
                max: 1000,
                divisions: 18,
                activeColor: SW.primary,
                onChanged: (v) => setSheetState(() => radius = v),
              ),
              Row(
                children: [
                  const Icon(Icons.my_location_rounded,
                      size: 16, color: SW.primary),
                  const SizedBox(width: 8),
                  Text('Centered on your current location',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: SW.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final rng = math.Random();
                    ref.read(appStateProvider.notifier).updateSafeZones([
                      ...zones,
                      SafeZone(
                        name: nameCtrl.text.trim(),
                        // Demo coordinates around Algiers
                        lat: 36.75 + rng.nextDouble() * 0.04,
                        lng: 3.04 + rng.nextDouble() * 0.04,
                        radiusMeters: radius,
                      ),
                    ]);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Zone'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneMapPainter extends CustomPainter {
  final int zoneCount;
  const _ZoneMapPainter({required this.zoneCount});

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

    // Zone circles
    final positions = [
      Offset(size.width * 0.30, size.height * 0.40),
      Offset(size.width * 0.70, size.height * 0.62),
      Offset(size.width * 0.52, size.height * 0.28),
    ];
    for (int i = 0; i < math.min(zoneCount, positions.length); i++) {
      final c = positions[i];
      canvas.drawCircle(
          c, 44, Paint()..color = SW.secondary.withValues(alpha: 0.18));
      canvas.drawCircle(
        c,
        44,
        Paint()
          ..color = SW.secondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(c, 8, Paint()..color = SW.secondary);
    }

    // User dot
    final me = Offset(size.width * 0.44, size.height * 0.52);
    canvas.drawCircle(
        me, 12, Paint()..color = SW.primary.withValues(alpha: 0.25));
    canvas.drawCircle(me, 6, Paint()..color = SW.primary);
  }

  @override
  bool shouldRepaint(covariant _ZoneMapPainter old) =>
      old.zoneCount != zoneCount;
}
