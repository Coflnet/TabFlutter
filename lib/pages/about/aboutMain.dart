import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:spables/pages/about/aboutCoflnet.dart';
import 'package:spables/pages/about/aboutHelp.dart';
import 'package:spables/pages/about/aboutLegalButtons.dart';
import 'package:spables/pages/about/account_info.dart';
import 'package:spables/pages/about/account_offerings.dart';
import 'package:spables/pages/reusedWidgets/background.dart';
import 'package:spables/pages/reusedWidgets/footer/footer.dart';

class AboutMain extends StatefulWidget {
  const AboutMain({Key? key}) : super(key: key);

  @override
  _AboutMainState createState() => _AboutMainState();
}

class _AboutMainState extends State<AboutMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        const Background(),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 55),
              Text(
                translate("aboutHeader"),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 30),
              ),
              const SizedBox(height: 14),
              const AccountInfo(),
              const AccountOfferings(),
              const SizedBox(height: 30),
              const SizedBox(height: 45),
              const Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AboutCoflnet(),
                ],
              )),
              const SizedBox(height: 16),
              const AboutLegalButtons()
            ],
          ),
        ),
        const Footer()
      ],
    ));
  }
}
