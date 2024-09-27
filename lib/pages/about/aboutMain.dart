import 'package:flutter/material.dart';
import 'package:table_entry/pages/about/aboutCoflnet.dart';
import 'package:table_entry/pages/about/aboutHelp.dart';
import 'package:table_entry/pages/about/aboutLegalButtons.dart';
import 'package:table_entry/pages/reusedWidgets/background.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footer.dart';

class AboutMain extends StatefulWidget {
  const AboutMain({Key? key}) : super(key: key);

  @override
  _AboutMainState createState() => _AboutMainState();
}

class _AboutMainState extends State<AboutMain> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "WorkSans"),
      home: Scaffold(
        body: Stack(
          children: [
            const Background(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 55),
                  Text(
                    "About",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 30),
                  ),
                  SizedBox(height: 30),
                  SizedBox(height: 45),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AboutCoflnet(),
                    ],
                  )),
                  SizedBox(height: 16),
                  AboutLegalButtons()
                ],
              ),
            ),
            const Footer()
          ],
        ),
      ),
    );
  }
}
