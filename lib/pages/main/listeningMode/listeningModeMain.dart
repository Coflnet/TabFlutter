import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spables/globals/columns/saveColumn.dart';
import 'package:spables/globals/recordingService/recordingServer.dart';
import 'package:spables/pages/main/listeningMode/listeningModeHeader.dart';

class Listeningmodemain extends StatefulWidget {
  const Listeningmodemain({super.key});

  @override
  State<Listeningmodemain> createState() => _ListeningmodemainState();
}

class _ListeningmodemainState extends State<Listeningmodemain> {
  String recognizedWords = "Testing";
  String words = "";

  @override
  void initState() {
    super.initState();
  }

  void reactToNotifier() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 120),
        const ListeningModeHeader(),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: HexColor("23263E"),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                words,
                style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 21,
                    fontWeight: FontWeight.w300),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          color: HexColor("1D1E2B"),
          width: double.infinity,
          height: 190,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              Text(
                textWidthBasis: TextWidthBasis.longestLine,
                textAlign: TextAlign.center,
                "Say 'new entry' before each entry and each \ncolumn say the name 'value' than the value",
                style: TextStyle(
                    color: Colors.grey.shade200.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                    fontSize: 13),
              )
            ],
          ),
        )
      ],
    );
  }
}
