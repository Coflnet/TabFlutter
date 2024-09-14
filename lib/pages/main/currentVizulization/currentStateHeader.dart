import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';

class CurrentStateHeader extends StatelessWidget {
  const CurrentStateHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Selected Column",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600),
              ),
              TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {},
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: HexColor("1E202E"),
                      borderRadius: BorderRadius.circular(120),
                    ),
                    child: Icon(
                      size: 30,
                      Icons.more_vert,
                      color: Colors.grey.shade200,
                    ),
                  ))
            ],
          ),
          SizedBox(height: 4)
        ],
      ),
    );
  }
}
