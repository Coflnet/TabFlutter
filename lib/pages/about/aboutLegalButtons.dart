import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutLegalButtons extends StatelessWidget {
  const AboutLegalButtons({super.key});
  void launchUrlL() async {
    final Uri url = Uri.parse("https://coflnet.com/privacy");

    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: launchUrlL,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24, width: 2.3)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translate("privacyButton"),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
        const SizedBox(
          height: 120,
        )
      ],
    );
  }
}
