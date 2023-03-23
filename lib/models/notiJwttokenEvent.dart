import 'package:flutter/material.dart';

class NotiJwttokenEvent with ChangeNotifier {
  static final NotiJwttokenEvent _singleton = NotiJwttokenEvent._internal();

  factory NotiJwttokenEvent() { return _singleton; }

  NotiJwttokenEvent._internal();

  String msg = 'A';

  void notify (String newValue) {
    msg = newValue;
    notifyListeners();
  }

}