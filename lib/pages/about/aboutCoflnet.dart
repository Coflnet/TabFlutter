import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutCoflnet extends StatelessWidget {
  const AboutCoflnet({super.key});

  void launchUrlL() async {
    final Uri url = Uri.parse("https://coflnet.com/");

    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "Interested in a app like this?",
          style: TextStyle(color: Colors.grey.shade300, fontSize: 19),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    launchUrlL();
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                    image: AssetImage(
                                      "assets/images/coflnet.png",
                                    ),
                                    fit: BoxFit.contain)),
                          ),
                        ),
                      ],
                    ),
                  )),
            )
          ],
        )
      ],
    );
  }
}
