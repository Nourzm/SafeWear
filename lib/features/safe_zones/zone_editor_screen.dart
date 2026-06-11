import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_state.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../shared/models/user_model.dart';

enum _EditMode { circle, draw }

/// Full-screen safe-zone editor. Circle mode: drag to position, slider for
/// radius — the zone updates live on the map. Draw mode: trace the outline
/// with a finger and it becomes the zone shape.
class ZoneEditorScreen extends ConsumerStatefulWidget {
  const ZoneEditorScreen({super.key});

  @override
  ConsumerState<ZoneEditorScreen> createState() => _ZoneEditorScreenState();
}

class _ZoneEditorScreenState extends ConsumerState<ZoneEditorScreen> {
  final _nameCtrl = TextEditingController();
  _EditMode _mode = _EditMode.circle;

  // Circle state (normalized 0–1 map coordinates)
  Offset _center = const Offset(0.5, 0.5);
  double _radiusMeters = 200;

  // Freehand state
  List<Offset> _stroke = [];
  bool _drawing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SW.tertiary,
          behavior: SnackBarBehavior.floating,
          content: Text(t('zoneNameRequired'),
              style: GoogleFonts.inter(color: Colors.white)),
        ),
      );
      return;
    }
    if (_mode == _EditMode.draw && _stroke.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SW.tertiary,
          behavior: SnackBarBehavior.floating,
          content: Text(t('drawZoneFirst'),
              style: GoogleFonts.inter(color: Colors.white)),
        ),
      );
      return;
    }

    final user = ref.read(appStateProvider);
    if (user == null) return;

    final rng = math.Random();
    final zone = SafeZone(
      name: name,
      // Demo coordinates around Algiers
      lat: 36.75 + rng.nextDouble() * 0.04,
      lng: 3.04 + rng.nextDouble() * 0.04,
      radiusMeters: _radiusMeters,
      mapX: _mode == _EditMode.circle ? _center.dx : 0.5,
      mapY: _mode == _EditMode.circle ? _center.dy : 0.5,
      polygon: _mode == _EditMode.draw
          ? _stroke.map((p) => [p.dx, p.dy]).toList()
          : const [],
    );
    ref
        .read(appStateProvider.notifier)
        .updateSafeZones([...user.safeZones, zone]);
    Navigator.of(context).pop();
  }

  Offset _normalize(Offset local, Size size) => Offset(
        (local.dx / size.width).clamp(0.0, 1.0),
        (local.dy / size.height).clamp(0.0, 1.0),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SW.background,
      appBar: AppBar(
        title: Text(t('newSafeZone'),
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // Name field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: t('zoneName'),
                prefixIcon: const Icon(Icons.place_outlined),
              ),
            ),
          ),
          // Mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _ModeButton(
                  icon: Icons.radio_button_unchecked_rounded,
                  label: t('circleMode'),
                  selected: _mode == _EditMode.circle,
                  onTap: () => setState(() => _mode = _EditMode.circle),
                ),
                const SizedBox(width: 10),
                _ModeButton(
                  icon: Icons.gesture_rounded,
                  label: t('drawMode'),
                  selected: _mode == _EditMode.draw,
                  onTap: () => setState(() {
                    _mode = _EditMode.draw;
                    _stroke = [];
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.touch_app_rounded,
                    size: 16, color: SW.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _mode == _EditMode.circle
                        ? t('circleHint')
                        : t('drawHint'),
                    style: GoogleFonts.inter(
                        fontSize: 12, color: SW.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Interactive map
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: SW.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) {
                      if (_mode == _EditMode.draw) {
                        setState(() {
                          _drawing = true;
                          _stroke = [_normalize(d.localPosition, size)];
                        });
                      } else {
                        setState(() =>
                            _center = _normalize(d.localPosition, size));
                      }
                    },
                    onPanUpdate: (d) {
                      if (_mode == _EditMode.draw && _drawing) {
                        setState(() =>
                            _stroke.add(_normalize(d.localPosition, size)));
                      } else if (_mode == _EditMode.circle) {
                        setState(() =>
                            _center = _normalize(d.localPosition, size));
                      }
                    },
                    onPanEnd: (_) => setState(() => _drawing = false),
                    onTapDown: (d) {
                      if (_mode == _EditMode.circle) {
                        setState(() =>
                            _center = _normalize(d.localPosition, size));
                      }
                    },
                    child: CustomPaint(
                      painter: _EditorMapPainter(
                        mode: _mode,
                        center: _center,
                        radiusMeters: _radiusMeters,
                        stroke: _stroke,
                        drawing: _drawing,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
          ),
          // Radius slider (circle mode only)
          if (_mode == _EditMode.circle)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Icon(Icons.radar_rounded, size: 18, color: SW.primary),
                  Expanded(
                    child: Slider(
                      value: _radiusMeters,
                      min: 100,
                      max: 1000,
                      divisions: 18,
                      activeColor: SW.primary,
                      onChanged: (v) => setState(() => _radiusMeters = v),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${_radiusMeters.round()} m',
                      style: GoogleFonts.manrope(
                          fontSize: 14, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _stroke = []),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(t('clearDrawing')),
                ),
              ),
            ),
          // Save
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(t('saveZone')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? SW.primary : SW.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? SW.primary : SW.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: selected ? Colors.white : SW.onSurface),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : SW.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorMapPainter extends CustomPainter {
  final _EditMode mode;
  final Offset center;
  final double radiusMeters;
  final List<Offset> stroke;
  final bool drawing;

  _EditorMapPainter({
    required this.mode,
    required this.center,
    required this.radiusMeters,
    required this.stroke,
    required this.drawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base map
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFEAEFF7));

    final rng = math.Random(5);
    final blockPaint = Paint()..color = const Color(0xFFDDE4F0);
    for (int i = 0; i < 50; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rng.nextDouble() * size.width,
            rng.nextDouble() * size.height,
            18 + rng.nextDouble() * 36,
            14 + rng.nextDouble() * 28,
          ),
          const Radius.circular(3),
        ),
        blockPaint,
      );
    }
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.45),
        Offset(size.width, size.height * 0.55), roadPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0),
        Offset(size.width * 0.45, size.height), roadPaint..strokeWidth = 4);

    final green = SW.isDark ? const Color(0xFF34C08B) : const Color(0xFF0A6C44);

    if (mode == _EditMode.circle) {
      final c = Offset(center.dx * size.width, center.dy * size.height);
      // Scale: full slider range (1000 m) ≈ 45% of map width
      final px = radiusMeters / 1000 * size.width * 0.45;
      canvas.drawCircle(
          c, px, Paint()..color = green.withValues(alpha: 0.18));
      canvas.drawCircle(
        c,
        px,
        Paint()
          ..color = green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      canvas.drawCircle(c, 9, Paint()..color = green);
      canvas.drawCircle(
        c,
        9,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    } else if (stroke.length > 1) {
      final path = Path()
        ..moveTo(stroke.first.dx * size.width, stroke.first.dy * size.height);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      if (!drawing) path.close();
      canvas.drawPath(
          path,
          Paint()
            ..color = green.withValues(alpha: drawing ? 0.10 : 0.20)
            ..style = PaintingStyle.fill);
      canvas.drawPath(
        path,
        Paint()
          ..color = green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // User location dot
    final me = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(
        me, 6, Paint()..color = const Color(0xFF005394));
    canvas.drawCircle(
      me,
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _EditorMapPainter old) =>
      old.center != center ||
      old.radiusMeters != radiusMeters ||
      old.stroke.length != stroke.length ||
      old.mode != mode ||
      old.drawing != drawing;
}
