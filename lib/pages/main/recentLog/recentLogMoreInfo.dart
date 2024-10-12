import 'package:flutter/material.dart';

class RecentLogMoreInfo extends StatelessWidget {
  const RecentLogMoreInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Icon(
        Icons.info_outline,
        color: Colors.grey.shade500,
        size: 30,
      ),
    );
  }
}
