import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../shared/models/user_model.dart';

class MedicalProfileScreen extends ConsumerStatefulWidget {
  const MedicalProfileScreen({super.key});

  @override
  ConsumerState<MedicalProfileScreen> createState() =>
      _MedicalProfileScreenState();
}

class _MedicalProfileScreenState extends ConsumerState<MedicalProfileScreen> {
  static const _bloodTypes = ['A+', 'A−', 'B+', 'B−', 'AB+', 'AB−', 'O+', 'O−'];
  static const _conditionOptions = [
    'Epilepsy',
    'Diabetes',
    'Asthma',
    'Heart Condition',
    'Allergy (severe)',
    'Pregnancy',
  ];

  String _bloodType = '';
  late Set<String> _conditions;
  final _medsCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final m = ref.read(appStateProvider)?.medicalProfile ??
        const MedicalProfile();
    _bloodType = m.bloodType;
    _conditions = m.conditions.toSet();
    _medsCtrl.text = m.medications;
    _allergiesCtrl.text = m.allergies;
  }

  @override
  void dispose() {
    _medsCtrl.dispose();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(appStateProvider.notifier).updateMedicalProfile(MedicalProfile(
          bloodType: _bloodType,
          conditions: _conditions.toList(),
          medications: _medsCtrl.text.trim(),
          allergies: _allergiesCtrl.text.trim(),
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SW.secondary,
        behavior: SnackBarBehavior.floating,
        content: Text('Medical profile saved',
            style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SW.background,
      appBar: AppBar(
        title: Text('Medical Profile',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4D6D), Color(0xFFFF8FA3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_information_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Shared with medical responders during a "Save Me" alert — it can save critical minutes.',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.white, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Blood Type',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bloodTypes.map((t) {
                final selected = _bloodType == t;
                return GestureDetector(
                  onTap: () => setState(() => _bloodType = t),
                  child: Container(
                    width: 64,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          selected ? SW.tertiary : SW.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? SW.tertiary : SW.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        t,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: selected ? Colors.white : SW.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Text('Medical Conditions',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _conditionOptions.map((c) {
                final selected = _conditions.contains(c);
                return FilterChip(
                  label: Text(c),
                  selected: selected,
                  selectedColor: SW.primary,
                  checkmarkColor: Colors.white,
                  backgroundColor: SW.surfaceContainerLowest,
                  labelStyle: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : SW.onSurface,
                  ),
                  onSelected: (v) => setState(() {
                    v ? _conditions.add(c) : _conditions.remove(c);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Text('Medications',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _medsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. Insulin (morning), Ventolin inhaler',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
            ),
            const SizedBox(height: 20),

            Text('Allergies',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _allergiesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. Penicillin, peanuts',
                prefixIcon: Icon(Icons.warning_amber_rounded),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save Medical Profile'),
          ),
        ),
      ),
    );
  }
}
