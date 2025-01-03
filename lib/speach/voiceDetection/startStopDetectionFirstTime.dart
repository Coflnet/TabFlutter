import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class StartStopDetectionFirstTime extends StatelessWidget {
  const StartStopDetectionFirstTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      width: 280,
      decoration: BoxDecoration(
          color: HexColor("1D1E2B"), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: <Widget>[
          const Text(
            "📘 How it works",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
          ),
          const SizedBox(height: 15),
          Text(
            textAlign: TextAlign.center,
            "When you finish with all of your input press this button again and we will process the data for you!",
            style: TextStyle(
                color: Colors.grey.shade300,
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}
