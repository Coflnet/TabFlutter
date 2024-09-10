import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/pages/settings/columnSettings/emojiPopup/columnEmojiPopupContainer.dart';

class ColumnEmojiPopup extends StatefulWidget {
  const ColumnEmojiPopup({Key? key}) : super(key: key);

  @override
  _ColumnEmojiPopupState createState() => _ColumnEmojiPopupState();
}

class _ColumnEmojiPopupState extends State<ColumnEmojiPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String selectedEmoji = "";
  double opacity = 0.0;
  late CustomPopupMenuController popupController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    popupController = CustomPopupMenuController();
  }

  @override
  void dispose() {
    super.dispose();
    popupController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
        verticalMargin: -5,
        menuOnChange: handleMenuChange,
        controller: popupController,
        menuBuilder: () => AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 900),
              child: ClipRRect(
                child: IntrinsicWidth(
                    child: ColumnEmojiPopupContainer(
                        emojiChanged: updateSelectedEmoji)),
              ),
            ),
        pressType: PressType.singleClick,
        child: (selectedEmoji == "")
            ? const Icon(Icons.check_box_outline_blank_rounded,
                color: Colors.grey, size: 38)
            : Text(selectedEmoji, style: const TextStyle(fontSize: 25)));
  }

  void updateSelectedEmoji(String newEmoji) {
    EditingColumns().updateEmoji(newEmoji);
    setState(() {
      selectedEmoji = newEmoji;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      popupController.hideMenu();
    });
  }

  void handleMenuChange(bool changeState) {
    if (changeState) {
      setState(() {
        opacity = 1.0;
        _controller.forward();
      });
      return;
    }
    setState(() {
      opacity = 0.0;
      _controller.reverse();
    });
  }
}
