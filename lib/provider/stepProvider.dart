import 'package:flutter/material.dart';

class StepProvider extends ChangeNotifier {
  int step = 0;

  getStep() => step;

  setStep(int step2) {
    if (step == step2) {
      notifyListeners();
    }
    step = step2;
  }
}
