import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kOnboardingShown = 'onboarding_shown';

/// Checks whether the onboarding has already been shown.
Future<bool> shouldShowOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_kOnboardingShown) ?? false);
}

/// Marks the onboarding as shown so it won't appear again.
Future<void> markOnboardingShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingShown, true);
}

/// Shows the onboarding dialog if it hasn't been shown before.
/// Call this from the main page's `initState` or after navigation.
Future<void> showOnboardingIfNeeded(BuildContext context) async {
  if (await shouldShowOnboarding()) {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const OnboardingDialog(),
    );
  }
}

class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({super.key});

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  int _currentPage = 0;

  static const _totalPages = 3;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HexColor("1D1E2B"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: _buildPage(_currentPage)),
              const SizedBox(height: 20),
              _buildDots(),
              const SizedBox(height: 20),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _WelcomePage();
      case 1:
        return _HowItWorksPage();
      case 2:
        return _TablesPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (i) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage
                ? HexColor("#8332AC")
                : Colors.white.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }

  Widget _buildButtons() {
    final isLast = _currentPage == _totalPages - 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0)
          TextButton(
            onPressed: () => setState(() => _currentPage--),
            child: Text(translate('back'),
                style: const TextStyle(color: Colors.white54, fontSize: 16)),
          )
        else
          const SizedBox(width: 80),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: HexColor("#8332AC"),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            if (isLast) {
              await markOnboardingShown();
              if (mounted) Navigator.of(context).pop();
            } else {
              setState(() => _currentPage++);
            }
          },
          child: Text(
            isLast ? translate('getStarted') : translate('next'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🐝', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 20),
        Text(
          translate('onboardingWelcome'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          translate('onboardingDesc'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HowItWorksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mic, size: 56, color: Color(0xFF8332AC)),
        const SizedBox(height: 20),
        Text(
          translate('onboardingHowItWorksTitle'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _step('1', translate('onboardingStep1')),
        _step('2', translate('onboardingStep2')),
        _step('3', translate('onboardingStep3')),
        _step('4', translate('onboardingStep4')),
      ],
    );
  }

  static Widget _step(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF8332AC).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(num,
                style: const TextStyle(
                    color: Color(0xFF8332AC),
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _TablesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.table_chart_outlined,
            size: 56, color: Color(0xFF8332AC)),
        const SizedBox(height: 20),
        Text(
          translate('onboardingTablesTitle'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          translate('onboardingTablesDesc'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _tableChip('🐝 Address', 'Street, Name, Phone, Email'),
        _tableChip('🐝 Fahrtenbuch', 'Date, From, To, KM, Purpose'),
        _tableChip('🐝 Todo/Reminder', 'Task, Due Date, Priority'),
      ],
    );
  }

  static Widget _tableChip(String name, String columns) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          Text(columns,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
