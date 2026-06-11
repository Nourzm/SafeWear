import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';

class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  List<LocalAlertRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await AppStateNotifier.loadHistory();
    if (!mounted) return;
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'police':
        return 'Contacts + Police';
      case 'saveMe':
        return 'Maximum Response';
      default:
        return 'Contacts Only';
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $h:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SW.background,
      appBar: AppBar(
        title: Text('Alert History',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SW.primary))
          : _records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: SW.secondaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.verified_user_rounded,
                            color: SW.secondary, size: 44),
                      ),
                      const SizedBox(height: 18),
                      Text('No alerts — and that\'s good news',
                          style: GoogleFonts.manrope(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        'Every SOS you trigger or cancel appears here.',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: SW.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _records.length,
                  itemBuilder: (context, i) {
                    final r = _records[i];
                    final resolved = r.status == 'resolved';
                    final color = resolved ? SW.tertiary : SW.secondary;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SW.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: SW.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              resolved
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_off_rounded,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resolved
                                      ? 'Alert dispatched — ${_modeLabel(r.mode)}'
                                      : 'SOS cancelled during countdown',
                                  style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _formatDate(r.startedAt),
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: SW.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              resolved ? 'Resolved' : 'Cancelled',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
