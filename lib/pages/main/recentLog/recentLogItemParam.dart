import 'dart:ui';

import 'package:flutter/material.dart';

class RecentLogItemParam extends StatelessWidget {
  final List values;
  const RecentLogItemParam({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            (values.isEmpty) ? "" : values[0],
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Visibility(
            visible: !(values.isEmpty || values[1].svalue == ""),
            child: Text(
              (values.isEmpty) ? "" : values[1].svalue,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
