import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({super.key});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text(
            "Email :",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 21),
          ),
          Text(
            "Tentamens@coflnet.com",
            style: TextStyle(
                color: Colors.grey[100],
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
        ]),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Remaining :",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 21),
            ),
            Text(
              "600",
              style: TextStyle(
                  color: Colors.grey[100],
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
        const SizedBox(height: 10),
        const Text(""),
        TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: HexColor("#8332AC"),
                  borderRadius: BorderRadius.circular(16)),
              child: const Text(
                "Log out",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ))
      ],
    );
  }
}
