import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CurrentStateHeader extends StatelessWidget {
  const CurrentStateHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          "Status",
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4)
      ],
    );
  }
}
