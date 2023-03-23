import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api/jsonapi.dart';
import '../constants.dart';
import '../models/apiError.dart';
import '../models/apiResponse.dart';
import '../provider/formProvider.dart';
import '../widgets/customFormField.dart';

class SearchIDPWPage extends StatefulWidget {
  const SearchIDPWPage({Key? key}) : super(key: key);

  @override
  SearchIDPWPageState createState() => SearchIDPWPageState();
}


class SearchIDPWPageState extends State<SearchIDPWPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hpController = TextEditingController();
  final TextEditingController authController = TextEditingController();

  late SharedPreferences prefs;

  late FocusNode myFocusNode;
  bool certReadOnly = false;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  Widget _entryField(String title, TextEditingController controller, String action, {bool isPassword = false} ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              controller: controller,
              textInputAction: (action == 'next') ? TextInputAction.next : TextInputAction.done,
              onEditingComplete: () {
                // Move the focus to the next node explicitly.
                if(action == 'next')
                {
                  // FocusScope.of(context).requestFocus(FocusNode());
                  FocusScope.of(context).nextFocus();
                }
              },
              onSubmitted: (__){
                if(action == 'action')
                {
                  _submitButton();
                }
              },
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xffc2c2c2),
                  filled: true))
        ],
      ),
    );
  }

  void _submitButton() {
    // FocusScope.of(context).requestFocus(FocusNode());
    // debugPrint(' ${id_controller.text.trim()} : ${pw_controller.text.trim()}');
    if (nameController.text.trim() == "") {
      Fluttertoast.showToast(
          msg: "이름을 입력해주세요",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 13.0
      );
    }
    else if (hpController.text.trim() == "") {
      Fluttertoast.showToast(
          msg: "휴대폰번호를 입력해주세요",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 13.0
      );
    }
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: const <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("아이디 비밀번호 찾기", textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 15),),
        backgroundColor: Colors.white,
        // elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () =>
              Navigator.pop(context),
          color: Colors.black,
        ),
      ),
      body: SafeArea (
          child : GestureDetector(
            // behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(myFocusNode);
              },
              child: SingleChildScrollView(
                  child: Container(
                      margin: const EdgeInsets.all(10.0),
                      child: Form(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                  child: Stack(
                                    alignment: Alignment.centerRight,
                                    children: <Widget>[
                                      Focus(
                                        child: CustomFormField(
                                          hintText: '이름',
                                          controller: nameController,
                                          keyBoardType: TextInputType.text,
                                          textInputAction:TextInputAction.next,
                                          isAutoFocus: false,
                                          isReadonly: false,
                                          isEnable: true,
                                          isPassword: false,
                                          isRequired: true,
                                          textAlign: TextAlign.left,
                                          validator: (val) {
                                            // debugPrint('validator ${val.toString()}');
                                            // return 'Enter valid email';
                                          },
                                          // onChanged: formProvider.validateEmail,
                                        ),
                                        onFocusChange: (hasFocus) {

                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                  child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: <Widget>[
                                        Focus(
                                          child: CustomFormField(
                                            hintText: '휴대전화',
                                            controller: hpController,
                                            keyBoardType: TextInputType.phone,
                                            textInputAction:TextInputAction.next,
                                            isAutoFocus: false,
                                            isReadonly: false,
                                            isEnable: true,
                                            isPassword: false,
                                            isRequired: true,
                                            textAlign: TextAlign.left,
                                            validator: (val) {
                                              debugPrint('validator ${val.toString()}');
                                            },
                                            // onChanged: formProvider.validateEmail,
                                          ),
                                          onFocusChange: (hasFocus) {
                                          },
                                        ),
                                        Positioned( // <-- doesn't work
                                            top: 10.0, // <-- how to make it also relative to parent's height parameter?
                                            right: -2.0, // <-- how to make it also relative to parent's height parameter?
                                            child: Container(
                                                margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 25.0),
                                                child: TextButton(
                                                  onPressed: () {
                                                    final parameters = {"mb_hp": hpController.text, "mb_name": nameController.text, "sms_id": "jnpass", "sms_pw": "qhrehd@ss"};
                                                    JsonApi.postApi("rest/cert_idpw_phone", parameters).then((value) {
                                                      ApiResponse apiResponse = ApiResponse();

                                                      apiResponse = value;

                                                      certReadOnly = true;
                                                      FocusScope.of(context).unfocus();

                                                      setState(() {

                                                      });

                                                      if((apiResponse.apiError).error == "9") {

                                                        final responseData = json.decode(apiResponse.data.toString());
                                                        debugPrint('data ${apiResponse.data}');

                                                        if(responseData['result'])
                                                        {

                                                        }
                                                        else
                                                        {
                                                          if(responseData['message'] != '')
                                                          {
                                                            Fluttertoast.showToast(
                                                                msg: responseData['message'],
                                                                toastLength: Toast.LENGTH_SHORT,
                                                                gravity: ToastGravity.BOTTOM,
                                                                timeInSecForIosWeb: 1,
                                                                backgroundColor: Colors.red,
                                                                textColor: Colors.white,
                                                                fontSize: 13.0
                                                            );
                                                          }
                                                        }
                                                      }
                                                      else
                                                      {
                                                        Fluttertoast.showToast(
                                                            msg: (apiResponse.apiError).msg,
                                                            toastLength: Toast.LENGTH_SHORT,
                                                            gravity: ToastGravity.BOTTOM,
                                                            timeInSecForIosWeb: 1,
                                                            backgroundColor: Colors.red,
                                                            textColor: Colors.white,
                                                            fontSize: 13.0
                                                        );
                                                      }

                                                    });

                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.only(left: 15.0, bottom: 0.0, top: 0.0, right: 15.0),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                    backgroundColor: kButtonColor,
                                                  ),
                                                  child:
                                                  const Text("인증번호받기",
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                )
                                            )
                                        )
                                      ]
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                  child: Stack(
                                    alignment: Alignment.centerRight,
                                    children: <Widget>[
                                      Focus(
                                        child: CustomFormField(
                                          hintText: '인증번호',
                                          controller: authController,
                                          keyBoardType: TextInputType.number,
                                          textInputAction:TextInputAction.next,
                                          isAutoFocus: false,
                                          isReadonly: false,
                                          isEnable: certReadOnly,
                                          isPassword: false,
                                          isRequired: true,
                                          textAlign: TextAlign.left,
                                          validator: (val) {
                                            // debugPrint('validator ${val.toString()}');
                                            // return 'Enter valid email';
                                          },
                                          // onChanged: formProvider.validateEmail,
                                        ),
                                        onFocusChange: (hasFocus) {

                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(13),
                                  child: InkWell(
                                    onTap: () {
                                      final parameters = {"mb_name": nameController.text, "mb_hp": hpController.text, "cert_number": authController.text};
                                      JsonApi.getApi("rest/idpw", parameters).then((value) {
                                        ApiResponse apiResponse = ApiResponse();

                                        apiResponse = value;
                                        FocusScope.of(context).unfocus();

                                        if((apiResponse.apiError).error == "9") {

                                          final responseData = json.decode(apiResponse.data.toString());
                                          debugPrint('data ${apiResponse.data}');

                                          Fluttertoast.showToast(
                                              msg: responseData['message'],
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 13.0
                                          );
                                        }
                                        else
                                        {
                                          Fluttertoast.showToast(
                                              msg: (apiResponse.apiError).msg,
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 13.0
                                          );
                                        }

                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          color: Color(0xff98BF54)
                                      ),
                                      child: const Text(
                                        '아이디 비밀번호 찾기',
                                        style: TextStyle(fontSize: 20, color: Colors.white),
                                      ),
                                    )
                                  )
                                ),
                              ]
                          )
                      )
                  )
              )
          )
      ),
    );
  }
}

extension Utility on BuildContext {
  void nextEditableTextFocus() {
    do {
      FocusScope.of(this).nextFocus();
    } while (FocusScope.of(this).focusedChild!.context == null);
  }
}
