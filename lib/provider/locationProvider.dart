import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String location = "";

  getLocation() => location;

  setLocation(String location2) {
    if (location != location2) {
      location = location2;
      notifyListeners();
    }
  }
}
