import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/globals/contribution_consent.dart';

/// Withdrawal must be as easy as giving consent (Art. 7(3) GDPR); shown only
/// when this device has given a training consent.
class TrainingConsentButton extends StatefulWidget {
  const TrainingConsentButton({super.key});

  @override
  State<TrainingConsentButton> createState() => _TrainingConsentButtonState();
}

class _TrainingConsentButtonState extends State<TrainingConsentButton> {
  late Future<bool> hasConsent = ContributionConsent.hasReceipt();

  Future<void> _withdraw() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ContributionConsent.withdraw();
      messenger.showSnackBar(
          SnackBar(content: Text(translate('trainingConsentWithdrawn'))));
      if (mounted) setState(() => hasConsent = Future.value(false));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text('${translate("error")}: $e'),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: hasConsent,
        builder: (context, snapshot) => snapshot.data == true
            ? TextButton(
                onPressed: _withdraw,
                child: Text(translate('trainingConsentWithdraw'),
                    style: const TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white70)),
              )
            : const SizedBox.shrink(),
      );
}
