import 'package:flutter/material.dart';

import 'columnSettingsPopup.dart';

class Collumnsettingcontainer extends StatelessWidget {
  final bool isShowing;
  final VoidCallback closePopup;
  const Collumnsettingcontainer(
      {super.key, required this.isShowing, required this.closePopup});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ColumnSettingsPopup(
          isShowing: isShowing,
          closePopup: closePopup,
        ),
        IconButton(
            onPressed: () {
              closePopup();
            },
            icon: Icon(
              Icons.close_rounded,
              size: 37,
              color: Colors.grey.shade400,
            ))
      ],
    );
  }
}
