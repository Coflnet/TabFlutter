import 'dart:ui';

import 'package:flutter/material.dart';

class RecentLogItemParam extends StatelessWidget {
  const RecentLogItemParam({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Honey",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        Text(
          "10kg",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        )
      ],
    );
  }
}
