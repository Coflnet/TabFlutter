import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class RecentLogItemParam extends StatelessWidget {
  final List values;
  final String type;
  const RecentLogItemParam(
      {super.key, required this.values, required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            visible: !(values.isEmpty ||
                values[1].svalue == "" ||
                (values.isEmpty || type == translate('date'))),
            child: Text(
              (values.isEmpty) ? "" : values[1].svalue,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
