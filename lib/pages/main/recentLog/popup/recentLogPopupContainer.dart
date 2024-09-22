import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopup.dart';

class RecentLogPopupContainer extends StatefulWidget {
  final VoidCallback closePopup;
  const RecentLogPopupContainer({super.key, required this.closePopup});

  @override
  _RecentLogPopupContainerState createState() =>
      _RecentLogPopupContainerState();
}

class _RecentLogPopupContainerState extends State<RecentLogPopupContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black38,
          child: Center(child: RecentLogPopup(closePopup: widget.closePopup)),
        ),
      ),
    );
  }
}
