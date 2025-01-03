import 'package:flutter/material.dart';

class ListeningModeHeader extends StatelessWidget {
  const ListeningModeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: const Row(
        children: <Widget>[
          SizedBox(width: 24),
          Text(
            "Recognized Words",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
          )
        ],
      ),
    );
  }
}
