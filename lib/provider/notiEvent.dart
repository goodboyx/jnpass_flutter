import 'package:flutter/material.dart';

class NotiEvent with ChangeNotifier {
  static final NotiEvent _singleton = NotiEvent._internal();

  factory NotiEvent() { return _singleton; }

  NotiEvent._internal();

  String msg = 'A';

  void notify (String newValue) {
    msg = newValue;
    notifyListeners();
  }

}