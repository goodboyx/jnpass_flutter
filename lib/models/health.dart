
import 'package:flutter/cupertino.dart';

class Health with ChangeNotifier {
  Health({required this.step});

  int step;

  getStep() => step;

  void notify(int steps)
  {
    step = steps;
    notifyListeners();
  }
}
