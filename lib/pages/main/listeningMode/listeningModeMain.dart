import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/pages/main/listeningMode/listeningModeHeader.dart';

class ListeningModeMain extends StatelessWidget {
  final String recognizedWords;
  const ListeningModeMain({super.key, required this.recognizedWords});

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
              child: Flexible(
                child: Text(
                  recognizedWords,
                  style: TextStyle(
                      color: Colors.grey.shade200,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          color: HexColor("1D1E2B"),
          height: 170,
          child: Column(
            children: <Widget>[
              Text(
                  "Say 'new entry' before each entry and each column say the name 'value' than the value ")
            ],
          ),
        )
      ],
    );
  }
}
