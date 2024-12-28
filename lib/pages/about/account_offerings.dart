import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AccountOfferings extends StatefulWidget {
  const AccountOfferings({super.key});

  @override
  State<AccountOfferings> createState() => _AccountOfferingsState();
}

class _AccountOfferingsState extends State<AccountOfferings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Offerings",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        Container(
            decoration: BoxDecoration(color: HexColor("1D1E2B")),
            child: const Row(
              children: [
                Column(children: [
                  Text("Purchase"),
                  Text("Count"),
                ]),
                Column(children: [])
              ],
            ))
      ],
    );
  }
}
