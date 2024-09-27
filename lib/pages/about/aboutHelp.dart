import 'package:flutter/material.dart';

class AboutHelp extends StatefulWidget {
  const AboutHelp({Key? key}) : super(key: key);

  @override
  _AboutHelpState createState() => _AboutHelpState();
}

class _AboutHelpState extends State<AboutHelp> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("Help",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 27)),
        SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            textAlign: TextAlign.center,
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ",
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade200,
                fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}
