import 'package:flutter/material.dart';

class RecentLogPopupOption extends StatefulWidget {
  final int type;
  final String value;
  const RecentLogPopupOption(
      {super.key, required this.type, required this.value});

  @override
  _RecentLogPopupOptionState createState() => _RecentLogPopupOptionState();
}

class _RecentLogPopupOptionState extends State<RecentLogPopupOption> {
  @override
  Widget build(BuildContext context) {
    if (widget.type == 0) {
      return Container();
    } else if (widget.type == 1) {
      return Container();
    } else if (widget.type == 2) {
      return Container();
    }

    return Container();
  }
}
