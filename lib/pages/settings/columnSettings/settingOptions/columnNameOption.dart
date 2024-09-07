import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ColumnNameOption extends StatefulWidget {
  const ColumnNameOption({Key? key}) : super(key: key);

  @override
  _ColumnNameOptionState createState() => _ColumnNameOptionState();
}

class _ColumnNameOptionState extends State<ColumnNameOption> {
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Name",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.fromLTRB(6, 3, 3, 6),
                decoration: BoxDecoration(
                    color: HexColor("23263E"),
                    borderRadius: BorderRadius.circular(8)),
                child: const TextField(
                  decoration: InputDecoration.collapsed(
                    hintStyle: const TextStyle(color: Colors.white30),
                    hintText: "Column Name",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              )
            ],
          ),
        ),
        Icon(
          isCompleted
              ? Icons.check_box_rounded
              : Icons.check_box_outline_blank_rounded,
          size: 36,
          color: isCompleted ? Colors.green.shade300 : Colors.grey,
        ),
        const SizedBox(width: 3.5)
      ],
    );
  }
}
