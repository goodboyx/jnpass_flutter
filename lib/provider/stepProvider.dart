import 'package:flutter/material.dart';

class StepProvider extends ChangeNotifier {
  static final StepProvider _singleton = StepProvider._internal();

  factory StepProvider() { return _singleton; }

  StepProvider._internal();

  int step = 0;

  getStep() => step;

  setStep(int step2) {
    step = step2;
    notifyListeners();
  }
}
