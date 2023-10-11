import 'package:flutter/cupertino.dart';
import 'package:jnpass/constants.dart';
import '../models/validationModel.dart';

class FormProvider extends ChangeNotifier {
  static final FormProvider _singleton = FormProvider._internal();
  factory FormProvider() { return _singleton; }

  FormProvider._internal();

  late ValidationModel _id = ValidationModel(null, "아이디는 필수항목");
  late ValidationModel _password = ValidationModel(null, "암호는 필수황목");
  late ValidationModel _rePassword = ValidationModel(null, null);
  late ValidationModel _nick = ValidationModel(null, "닉네임은 필수항목");
  late ValidationModel _email = ValidationModel(null, null);
  late ValidationModel _name = ValidationModel(null, "이름은 필수항목");
  late ValidationModel _auth = ValidationModel(null, "인증번호는 필수항목");
  late ValidationModel _phone = ValidationModel(null, "휴대폰번호는 필수항목");
  late ValidationModel _cert = ValidationModel(null, "인증번호는 필수항목");

  ValidationModel get id => _id;
  ValidationModel get password => _password;
  ValidationModel get rePassword => _rePassword;
  ValidationModel get nick => _nick;
  ValidationModel get email => _email;
  ValidationModel get name => _name;
  ValidationModel get auth => _auth;
  ValidationModel get phone => _phone;
  ValidationModel get cert => _cert;

  Future<void> validateId(String? val) async {
    if(val.toString().length < 6)
    {
      _id = ValidationModel(null, '아이디는 최소 6자리 입니다.');
    }
    else
    {
      _id = ValidationModel(val, null);
    }

    notifyListeners();
  }

  Future<void> validatePassword(String? val) async {

    if(val.toString().length < 6)
    {
      _password = ValidationModel(null, '비밀번호는 최소 6자리 입니다.');
    }
    else
    {
        if (val != null && val.toString().isValidPassword) {
          _password = ValidationModel(val, null);
        }
        else
        {
          _password = ValidationModel(null, '6자리 이상 및 알파벳 숫자 조합만 가능');
        }
    }

    notifyListeners();
  }


  Future<void> validateRePassword(String? val) async {

    debugPrint(password.value.toString());
    debugPrint(val.toString());
    if(password.value.toString() != val.toString() && val.toString().length > 5)
    {
      _rePassword = ValidationModel(null, '비밀번호가 동일하지 않습니다.');
    }
    else
    {
      _rePassword = ValidationModel(val, null);
    }

    notifyListeners();
  }

  Future<void> validateNick(String? val) async {

    if(val.toString().length < 3)
    {
      _nick = ValidationModel(null, '닉네임는 한글 3자리 / 영문 3자리 이상 입니다.');
    }
    else {
      _nick = ValidationModel(val, null);
    }

    notifyListeners();
  }


  Future<void> validateEmail(String? val) async {

    // 이메일 입력할때만 검색
    if(val != null && val.toString() != "")
    // if (val != null && val.toString().isValidEmail) {
    {
      // 이메이 양식이 맞지 않으면
      if(!val.toString().isValidEmail)
      {
        _email = ValidationModel(null, '이메일 양식이 맞지 않습니다.');
      }
      else
      {
        _email = ValidationModel(val, null);
      }

      notifyListeners();
    }
  }

  Future<void> validateName(String? val) async {
    if(val.toString() == "")
    {
      _name = ValidationModel(null, '이름을 등록 해주세요.');
    }
    else
    {
      _name = ValidationModel(val, null);
    }

    notifyListeners();
  }

  Future<void> validatePhone(String? val) async {
    if(val.toString() == "")
    {
      _phone = ValidationModel(null, '휴대폰번호를 입력해주세요.');
    }
    else
    {
      _phone = ValidationModel(val, null);
    }

    notifyListeners();
  }

  Future<void> validateCert(String? val) async {
    if(val.toString() == "")
    {
      _phone = ValidationModel(null, '인증번호를 입력해주세요.');
    }
    else
    {
      _phone = ValidationModel(val, null);
    }

    notifyListeners();
  }
  bool get validate {
    return _id.value != null &&
        // _email.value != null &&
        _password.value != null &&
        _rePassword.value != null &&
        _phone.value != null &&
        _name.value != null;
  }

  String? get validateMsg {
    if(_id.error != null)
    {
      return _id.error.toString();
    }

    if(_password.error != null)
    {
      return _password.error.toString();
    }

    if(_rePassword.error != null)
    {
      return _rePassword.error.toString();
    }

    if(_nick.error != null)
    {
      return _nick.error.toString();
    }

    if(_name.error != null)
    {
      return _name.error.toString();
    }
    return null;
  }

}