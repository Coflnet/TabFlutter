import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class StartStopDetectionNoAudio extends StatelessWidget {
  const StartStopDetectionNoAudio({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(19),
      width: 280,
      decoration: BoxDecoration(
          color: HexColor("1D1E2B"), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: <Widget>[
          const Text(
            "🤔 Somethings wrong",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 15),
          Text(
            textAlign: TextAlign.center,
            'We are not getting audio from your mic if this continues contact support',
            style: TextStyle(
                color: Colors.grey.shade300,
                fontWeight: FontWeight.w500,
                fontSize: 16),
          )
        ],
      ),
    );
  }
}
