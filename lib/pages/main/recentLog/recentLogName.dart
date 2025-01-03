import 'package:flutter/material.dart';

class RecentLogName extends StatelessWidget {
  final String name;
  const RecentLogName({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Transform.flip(
          flipX: true,
          child: const Text(
            "🐝",
            style: TextStyle(fontSize: 27),
          ),
        ),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        )
      ],
    );
  }
}
