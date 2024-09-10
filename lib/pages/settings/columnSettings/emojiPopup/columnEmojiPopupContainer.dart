import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ColumnEmojiPopupContainer extends StatelessWidget {
  final Function(String) emojiChanged;
  ColumnEmojiPopupContainer({super.key, required this.emojiChanged});
  final List emojis = [
    "🐝",
    "🏗️",
    "🛹",
    "🎈",
    "🧑‍💻",
    "🎁",
    "🌷",
    "🏆",
    "🎲",
    "♾️",
    "💲",
    "🕳️"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
          color: HexColor("23263E"), borderRadius: BorderRadius.circular(8)),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, mainAxisSpacing: 0, crossAxisSpacing: 0),
          itemCount: emojis.length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return TextButton(
              onPressed: () {
                emojiChanged(emojis[index]);
              },
              child: Text(
                emojis[index],
                style: const TextStyle(fontSize: 23, color: Colors.white),
              ),
            );
          }),
    );
  }
}
