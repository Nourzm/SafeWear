import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

/// Crowd-sourced risk heatmap of Algiers. Rendered with CustomPaint so the
/// demo never depends on a Maps API key or network tiles.
class RiskMapScreen extends StatefulWidget {
  const RiskMapScreen({super.key});

  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends State<RiskMapScreen> {
  int _selectedFilter = 0;
  final _filters = const ['All', 'Harassment', 'Theft', 'Low Light', 'Isolated'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SW.background,
      appBar: AppBar(
        title: Text('Risk Map — Algiers',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? SW.primary : SW.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: selected ? SW.primary : SW.outlineVariant,
                      ),
                    ),
                    child: Text(
                      _filters[i],
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : SW.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: SW.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _AlgiersMapPainter()),
                  ),
                  // Legend
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendRow(const Color(0xFFC62828), 'High risk'),
                          const SizedBox(height: 6),
                          _legendRow(const Color(0xFFEF6C00), 'Moderate'),
                          const SizedBox(height: 6),
                          _legendRow(const Color(0xFF2E7D32), 'Safe zone'),
                        ],
                      ),
                    ),
                  ),
                  // Pin count badge
                  Positioned(
                    right: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.place_rounded,
                              size: 16, color: SW.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            '147 reports this month',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SW.onSurface,
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
          // Report button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showReportSheet(context),
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Report a Risk Area'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.inter(fontSize: 12, color: SW.onSurface)),
      ],
    );
  }

  void _showReportSheet(BuildContext context) {
    String category = 'Harassment';
    showModalBottomSheet(
      context: context,
      backgroundColor: SW.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report a Risk Area',
                  style: GoogleFonts.manrope(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'Your report is anonymous and helps protect other women in your area.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: SW.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Harassment', 'Theft', 'Low Light', 'Isolated Area']
                    .map((c) => ChoiceChip(
                          label: Text(c),
                          selected: category == c,
                          selectedColor: SW.primary,
                          labelStyle: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            color:
                                category == c ? Colors.white : SW.onSurface,
                          ),
                          onSelected: (_) =>
                              setSheetState(() => category = c),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: SW.secondary,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Report submitted anonymously — thank you.',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  child: const Text('Submit at My Location'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlgiersMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEAEFF7),
    );

    final rng = math.Random(7);

    // City blocks
    final blockPaint = Paint()..color = const Color(0xFFDDE4F0);
    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final w = 18 + rng.nextDouble() * 38;
      final h = 14 + rng.nextDouble() * 30;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), const Radius.circular(3)),
        blockPaint,
      );
    }

    // The bay (Mediterranean) along the top
    final sea = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.16)
      ..quadraticBezierTo(size.width * 0.62, size.height * 0.30, size.width * 0.3,
          size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.12, size.height * 0.12, 0, size.height * 0.20)
      ..close();
    canvas.drawPath(sea, Paint()..color = const Color(0xFFB3D4F5));

    // Main roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final road1 = Path()
      ..moveTo(0, size.height * 0.42)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.32, size.width,
          size.height * 0.46);
    canvas.drawPath(road1, roadPaint);
    final road2 = Path()
      ..moveTo(size.width * 0.32, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.40, size.height * 0.62,
          size.width * 0.28, size.height);
    canvas.drawPath(road2, roadPaint..strokeWidth = 4);
    final road3 = Path()
      ..moveTo(size.width * 0.72, size.height * 0.22)
      ..quadraticBezierTo(size.width * 0.66, size.height * 0.6,
          size.width * 0.82, size.height);
    canvas.drawPath(road3, roadPaint..strokeWidth = 3.5);

    // Heat blobs: (x%, y%, radius, color)
    final blobs = <List<dynamic>>[
      [0.30, 0.52, 70.0, const Color(0xFFC62828)],
      [0.62, 0.38, 52.0, const Color(0xFFC62828)],
      [0.78, 0.66, 60.0, const Color(0xFFEF6C00)],
      [0.18, 0.76, 48.0, const Color(0xFFEF6C00)],
      [0.48, 0.82, 44.0, const Color(0xFFEF6C00)],
      [0.86, 0.30, 40.0, const Color(0xFF2E7D32)],
      [0.10, 0.36, 44.0, const Color(0xFF2E7D32)],
      [0.55, 0.60, 38.0, const Color(0xFF2E7D32)],
    ];
    for (final b in blobs) {
      final center =
          Offset(size.width * (b[0] as double), size.height * (b[1] as double));
      final radius = b[2] as double;
      final color = b[3] as Color;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.45),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    // User location dot
    final me = Offset(size.width * 0.44, size.height * 0.56);
    canvas.drawCircle(
        me, 14, Paint()..color = SW.primary.withValues(alpha: 0.25));
    canvas.drawCircle(me, 7, Paint()..color = SW.primary);
    canvas.drawCircle(
      me,
      7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // District labels
    final districts = <List<dynamic>>[
      [0.30, 0.46, 'Bab El Oued'],
      [0.62, 0.32, 'Casbah'],
      [0.78, 0.60, 'El Harrach'],
      [0.12, 0.30, 'Hydra'],
      [0.50, 0.66, 'Alger Centre'],
    ];
    for (final d in districts) {
      final tp = TextPainter(
        text: TextSpan(
          text: d[2] as String,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5A6372),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(size.width * (d[0] as double) - tp.width / 2,
            size.height * (d[1] as double)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
