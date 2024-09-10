import 'dart:ui';

import 'package:flutter/material.dart';

class RecentLogItemParam extends StatelessWidget {
  final List values;
  const RecentLogItemParam({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          (values.isEmpty) ? "" : values[0],
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        Text(
          (values.isEmpty) ? "" : "Yes",
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        )
      ],
    );
  }
}
