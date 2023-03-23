import 'package:flutter/foundation.dart';

class DataHealth with ChangeNotifier {
  static final DataHealth _singleton = DataHealth._internal();
  factory DataHealth() { return _singleton; }

  DataHealth._internal();

  int _step = 0;

  getStep() => _step;

  setStep(int step) {
    _step = step;
    notifyListeners();
  }

}
