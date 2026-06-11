import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_state.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../shared/models/user_model.dart';

// Multi-step onboarding: language → phone OTP → profile → contacts → emergency mode → safe zones
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Collected data across steps
  String _language = 'ar';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<TrustedContact> _contacts = [];
  EmergencyMode _emergencyMode = EmergencyMode.contacts;
  final MedicalProfile _medicalProfile = MedicalProfile();

  void _next() {
    if (_currentPage < 4) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final user = UserProfile(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim().isEmpty
          ? 'SafeWear User'
          : _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      language: _language,
      trustedContacts: _contacts,
      medicalProfile: _medicalProfile,
      silentTriggerMode: _emergencyMode,
      tier: SubscriptionTier.free,
    );
    await ref.read(appStateProvider.notifier).saveProfile(user);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    // Apply the chosen language (and RTL for Arabic) immediately, so the
    // very first selection visibly switches the whole flow.
    currentLang = _language;
    return Directionality(
      textDirection: isRtl(_language) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: SW.surface,
      body: Column(
        children: [
          _ProgressBar(currentPage: _currentPage, totalPages: 5),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _LanguageStep(
                  selected: _language,
                  onSelect: (lang) => setState(() => _language = lang),
                  onNext: _next,
                ),
                _ProfileStep(
                  nameController: _nameController,
                  phoneController: _phoneController,
                  onNext: _next,
                ),
                _ContactsStep(
                  contacts: _contacts,
                  onChanged: (c) => setState(() {}),
                  onNext: _next,
                ),
                _EmergencyModeStep(
                  selected: _emergencyMode,
                  onSelect: (m) => setState(() => _emergencyMode = m),
                  onNext: _next,
                ),
                _SafeZonesStep(onNext: _next),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  const _ProgressBar({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Row(
          children: List.generate(totalPages, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < totalPages - 1 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i <= currentPage ? SW.primary : SW.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Step 1: Language selection
class _LanguageStep extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  const _LanguageStep({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      title: t('welcome'),
      subtitle: 'اختر لغتك  ·  Choisissez votre langue  ·  Choose your language',
      child: Column(
        children: [
          _LangOption(
            code: 'ar',
            label: 'العربية',
            selected: selected == 'ar',
            onTap: () => onSelect('ar'),
          ),
          const SizedBox(height: 12),
          _LangOption(
            code: 'fr',
            label: 'Français',
            selected: selected == 'fr',
            onTap: () => onSelect('fr'),
          ),
          const SizedBox(height: 12),
          _LangOption(
            code: 'en',
            label: 'English',
            selected: selected == 'en',
            onTap: () => onSelect('en'),
          ),
          const Spacer(),
          _NextButton(onTap: onNext, label: t('continue_')),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangOption({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? SW.primary : SW.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? SW.primary : SW.outlineVariant,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : SW.onSurface,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// Step 2: Profile + phone number
class _ProfileStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final VoidCallback onNext;
  const _ProfileStep({
    required this.nameController,
    required this.phoneController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      title: t('yourProfile'),
      subtitle: t('profileSub'),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: t('fullName'),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: t('phoneNumber'),
              hintText: '+213 xxx xxx xxx',
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          const Spacer(),
          _NextButton(onTap: onNext, label: t('continue_')),
        ],
      ),
    );
  }
}

// Step 3: Add trusted contacts
class _ContactsStep extends StatefulWidget {
  final List<TrustedContact> contacts;
  final ValueChanged<List<TrustedContact>> onChanged;
  final VoidCallback onNext;
  const _ContactsStep({
    required this.contacts,
    required this.onChanged,
    required this.onNext,
  });

  @override
  State<_ContactsStep> createState() => _ContactsStepState();
}

class _ContactsStepState extends State<_ContactsStep> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();

  void _add() {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) return;
    widget.contacts.add(TrustedContact(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _roleCtrl.text.trim().isEmpty ? 'Contact' : _roleCtrl.text.trim(),
    ));
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _roleCtrl.clear();
    setState(() {});
    widget.onChanged(widget.contacts);
  }

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      title: t('trustedContacts'),
      subtitle: t('contactsSub'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.contacts.map(
            (c) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: SW.surfaceContainerHigh,
                child: Text(
                  c.name[0].toUpperCase(),
                  style: const TextStyle(color: SW.primary),
                ),
              ),
              title: Text(c.name),
              subtitle: Text('${c.role} · ${c.phone}'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () {
                  setState(() => widget.contacts.remove(c));
                },
              ),
            ),
          ),
          if (widget.contacts.length < 5) ...[
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Contact Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _roleCtrl,
              decoration: const InputDecoration(
                labelText: 'Role (e.g. Mother, Friend)',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: Text(t('addContact')),
            ),
          ],
          const Spacer(),
          _NextButton(
            onTap: widget.onNext,
            label: widget.contacts.isEmpty ? t('skipForNow') : t('continue_'),
          ),
        ],
      ),
    );
  }
}

// Step 4: Emergency mode configuration
class _EmergencyModeStep extends StatelessWidget {
  final EmergencyMode selected;
  final ValueChanged<EmergencyMode> onSelect;
  final VoidCallback onNext;
  const _EmergencyModeStep({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      title: t('silentAlertMode'),
      subtitle: t('silentModeSub'),
      child: Column(
        children: [
          _ModeOption(
            mode: EmergencyMode.contacts,
            title: '"SafeWear contacts"',
            description: 'Notify your trusted contacts only. Best for most situations.',
            selected: selected == EmergencyMode.contacts,
            onTap: () => onSelect(EmergencyMode.contacts),
          ),
          const SizedBox(height: 12),
          _ModeOption(
            mode: EmergencyMode.police,
            title: '"SafeWear police"',
            description: 'Contacts + Alshorta (Algerian police). For serious threats.',
            selected: selected == EmergencyMode.police,
            onTap: () => onSelect(EmergencyMode.police),
          ),
          const SizedBox(height: 12),
          _ModeOption(
            mode: EmergencyMode.saveMe,
            title: '"SafeWear save me"',
            description:
                'Maximum response: contacts + police + medical services simultaneously.',
            selected: selected == EmergencyMode.saveMe,
            onTap: () => onSelect(EmergencyMode.saveMe),
          ),
          const Spacer(),
          _NextButton(onTap: onNext, label: t('confirmContinue')),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final EmergencyMode mode;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  const _ModeOption({
    required this.mode,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? SW.primary.withAlpha(15) : SW.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? SW.primary : SW.outlineVariant,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? SW.primary : SW.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: selected ? SW.primary : SW.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                        color: SW.onSurfaceVariant, fontSize: 13),
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

// Step 5: Safe zones (optional)
class _SafeZonesStep extends StatelessWidget {
  final VoidCallback onNext;
  const _SafeZonesStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      title: t('safeZones'),
      subtitle: t('safeZonesSub'),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SW.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: const CustomPaint(
              painter: _OnboardingMapPainter(),
              child: SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your current neighborhood is shown above. Add zones like home, '
            'school, or work anytime from Profile → Safe Zones.',
            style: GoogleFonts.inter(
                color: SW.onSurfaceVariant, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _NextButton(onTap: onNext, label: t('getStarted')),
        ],
      ),
    );
  }
}

class _OnboardingMapPainter extends CustomPainter {
  const _OnboardingMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFEAEFF7));

    final rng = math.Random(11);
    final blockPaint = Paint()..color = const Color(0xFFDDE4F0);
    for (int i = 0; i < 30; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rng.nextDouble() * size.width,
            rng.nextDouble() * size.height,
            16 + rng.nextDouble() * 32,
            12 + rng.nextDouble() * 24,
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
        Offset(size.width, size.height * 0.40), roadPaint);
    canvas.drawLine(Offset(size.width * 0.45, 0),
        Offset(size.width * 0.55, size.height), roadPaint);

    // Proposed home zone
    final zone = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(
        zone, 52, Paint()..color = SW.secondary.withValues(alpha: 0.15));
    canvas.drawCircle(
      zone,
      52,
      Paint()
        ..color = SW.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(zone, 8, Paint()..color = SW.secondary);

    // User dot
    canvas.drawCircle(
        zone, 16, Paint()..color = SW.primary.withValues(alpha: 0.2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Shared wrapper for each step
class _StepWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _StepWrapper({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: SW.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: SW.onSurfaceVariant,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const _NextButton({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
