import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../models/user_model.dart';

void showModeSelectorSheet(BuildContext context, WidgetRef ref) {
  final current =
      ref.read(appStateProvider)?.silentTriggerMode ?? EmergencyMode.contacts;
  showModalBottomSheet(
    context: context,
    backgroundColor: SW.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      EmergencyMode selected = current;
      return StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Emergency Response Mode',
                  style: GoogleFonts.manrope(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'What happens when your SOS fires — by button, voice, or AI detection.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: SW.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              _ModeTile(
                mode: EmergencyMode.contacts,
                icon: Icons.people_alt_rounded,
                title: 'Notify Contacts',
                subtitle: 'Alert trusted contacts only',
                selected: selected == EmergencyMode.contacts,
                onTap: () =>
                    setSheetState(() => selected = EmergencyMode.contacts),
              ),
              _ModeTile(
                mode: EmergencyMode.police,
                icon: Icons.local_police_rounded,
                title: 'Contacts + Police',
                subtitle: 'Also notifies Alshorta (17)',
                selected: selected == EmergencyMode.police,
                onTap: () =>
                    setSheetState(() => selected = EmergencyMode.police),
              ),
              _ModeTile(
                mode: EmergencyMode.saveMe,
                icon: Icons.emergency_rounded,
                title: 'Save Me — Maximum',
                subtitle: 'Contacts + police + medical services',
                selected: selected == EmergencyMode.saveMe,
                onTap: () =>
                    setSheetState(() => selected = EmergencyMode.saveMe),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(appStateProvider.notifier).updateMode(selected);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply Mode'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ModeTile extends StatelessWidget {
  final EmergencyMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _ModeTile({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? SW.primary.withValues(alpha: 0.06)
              : SW.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? SW.primary : SW.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? SW.primary : SW.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : SW.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected ? SW.primary : SW.onSurface,
                      )),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: SW.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? SW.primary : SW.outline,
            ),
          ],
        ),
      ),
    );
  }
}
