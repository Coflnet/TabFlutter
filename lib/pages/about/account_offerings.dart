import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AccountOfferings extends StatefulWidget {
  const AccountOfferings({super.key});

  @override
  State<AccountOfferings> createState() => _AccountOfferingsState();
}

class _AccountOfferingsState extends State<AccountOfferings> {
  final List<String> items = ["50", "100", "500"];
  String selected = "50";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        const Text(
          "Offerings",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        SizedBox(height: 12),
        Container(
            decoration: BoxDecoration(
                color: HexColor("1D1E2B"),
                borderRadius: BorderRadius.circular(16)),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amount",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                    decoration: BoxDecoration(
                        color: HexColor("2A2D54"),
                        borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                            dropdownStyleData: DropdownStyleData(
                                maxHeight: 160,
                                decoration: BoxDecoration(
                                    color: HexColor("2A2D54"),
                                    borderRadius: BorderRadius.circular(8)),
                                offset: const Offset(0, -10)),
                            isDense: true,
                            hint: Text(
                              'Select Item',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                            items: items
                                .map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ))
                                .toList(),
                            value: selected,
                            onChanged: (i) {
                              setState(() {
                                selected = i ?? selected;
                              });
                            })),
                  ),
                  SizedBox(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Price",
                      style: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                  SizedBox(),
                  Text(
                    '10\$',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(),
                ],
              ),
              SizedBox(height: 12),
              TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {},
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: HexColor("#8332AC"),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Purchase",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ))
            ])),
      ],
    );
  }
}
