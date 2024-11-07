import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';

class RecentLogMoreInfo extends StatelessWidget {
  final int id;
  const RecentLogMoreInfo({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: CustomPopupMenu(
        position: PreferredPosition.top,
        horizontalMargin: 5,
        pressType: PressType.singleClick,
        menuBuilder: () => Container(
          decoration: BoxDecoration(
              color: HexColor("1D1E2B"),
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            children: [
              const Text("Delete?", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              TextButton(
                  onPressed: () {
                    SaveColumn().deleteColumn(SaveColumn().getColumns[id].id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ))
            ],
          ),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 28,
        ),
      ),
    );
  }
}
