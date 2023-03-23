
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class MemberState  with ChangeNotifier, DiagnosticableTreeMixin {
  String gr_id = '';
  String mb_auth = 'N';
  String me_loc = '';

  setGrid(String _gr_id) {
    gr_id = _gr_id;

    notifyListeners();
  }

  setMbAuth(String _mb_auth) {
    mb_auth = _mb_auth;

    notifyListeners();
  }

  setMbLoc(String _me_loc) {
    me_loc = _me_loc;

    notifyListeners();
  }


  String getGrid()
  {
    return gr_id;
  }

  String getMbAuth()
  {
    return mb_auth;
  }

  String getMbLoc()
  {
    return me_loc;
  }

}