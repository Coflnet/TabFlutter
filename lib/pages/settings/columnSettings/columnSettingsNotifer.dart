import 'package:flutter/material.dart';

class popupNotifyer extends ChangeNotifier {
  void sendUpdate() {
    print("sending update");
    notifyListeners();
  }
}
