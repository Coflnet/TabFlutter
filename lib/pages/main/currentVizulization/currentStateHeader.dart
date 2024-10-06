import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:table_entry/pages/settings/settingsMain.dart';

class CurrentStateHeader extends StatelessWidget {
  const CurrentStateHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translate("selectedTable"),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600),
              ),
              TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    Haptics.vibrate(HapticsType.medium);
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SettingsMain(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return child;
                          },
                          transitionDuration: const Duration(milliseconds: 0),
                        ));
                  },
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
