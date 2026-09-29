import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:table_entry/globals/contribution_consent.dart';

/// Explicit, unticked consent for the Coflnet training purpose, showing the
/// backend's versioned notice. Returns true only when the box was ticked.
class TrainingConsentDialog extends StatefulWidget {
  final Map<String, dynamic> notice;
  const TrainingConsentDialog({super.key, required this.notice});

  @override
  State<TrainingConsentDialog> createState() => _TrainingConsentDialogState();
}

class _TrainingConsentDialogState extends State<TrainingConsentDialog> {
  bool agreed = false;

  @override
  Widget build(BuildContext context) {
    final purpose = (widget.notice['purposes'] as List)
        .cast<Map>()
        .firstWhere((p) => p['value'] == ContributionConsent.trainingPurpose);
    const small = TextStyle(color: Colors.white60, fontSize: 12, height: 1.4);
    return AlertDialog(
      backgroundColor: HexColor("1D1E2B"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(translate('sendForTrainingTitle'),
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translate('sendForTrainingBody'),
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.5)),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: agreed,
                onChanged: (value) => setState(() => agreed = value == true),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFFF59E0B),
                title: Text(purpose['title'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text(purpose['description'] as String, style: small),
              ),
              Text(translate('trainingConsentShort'), style: small),
              // Layered notice: the full versioned text and terms stay one tap away.
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  iconColor: Colors.white54,
                  collapsedIconColor: Colors.white54,
                  title: Text(translate('trainingConsentDetails'),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                  children: [
                    Text(widget.notice['information'] as String, style: small),
                    const SizedBox(height: 8),
                    Text(widget.notice['terms'] as String, style: small),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () =>
                    launchUrl(Uri.parse(widget.notice['privacyUrl'] as String)),
                child: Text(translate('privacyPolicyLink'),
                    style: const TextStyle(
                        color: Color(0xFF9333EA),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF9333EA))),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(translate('cancel'),
              style: const TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: agreed ? () => Navigator.of(context).pop(true) : null,
          child: Text(translate('trainingConsentAccept')),
        ),
      ],
    );
  }
}
