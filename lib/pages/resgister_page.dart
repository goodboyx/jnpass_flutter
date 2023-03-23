import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:hex/hex.dart';
import 'package:jnpass/constants.dart';
import 'package:jnpass/hpauth.dart';
import 'package:jnpass/pages/agree_page.dart';
import 'package:pointycastle/digests/md5.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

import '../api/jsonapi.dart';
import '../models/apiError.dart';
import '../models/apiResponse.dart';
import '../models/memberGroup.dart';
import '../models/notiEvent.dart';
import '../provider/formProvider.dart';
import '../widgets/customFormField.dart';
import 'package:http/http.dart' as http;

GetIt getIt = GetIt.instance;

class RegisterPage extends StatefulWidget {

  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {

  final globalKey = GlobalKey<ScaffoldState>();
  late SharedPreferences prefs;
  List<DropdownMenuItem<String>> menuItems = [];
  String currentSelectedValue = "gr03";  // 일반회원 선택
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController pw2Controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nickController = TextEditingController();
  final TextEditingController hpController = TextEditingController();
  final TextEditingController certController = TextEditingController();
  final TextEditingController recommendController = TextEditingController();
  late FocusNode myFocusNode;
  String mbSex = '';
  String mbBirth = '';
  String mbDupinfo = '';

  final provider = GetIt.I.get<FormProvider>();

  bool isAgreeEmail = true;
  bool isAgreeHp = true;
  bool isAgreeAll = false;
  bool isAgree1 = false;
  bool isAgree2 = false;
  bool initialized = false;
  // 본인인증 버튼
  bool hpAuthButton = false;

  bool passwordVisible = true;
  bool rePasswordVisible = true;
  bool certReadOnly = false;

  String _userAgent = '';
  String webViewUserAgent = '';
  String msg = '';
  late NotiEvent notiEvent;

  @override
  void initState() {

    myFocusNode = FocusNode();

    SharedPreferences.getInstance().then((value) {
      prefs = value;

    });

    provider.addListener(() {
      if(mounted) {
        setState(() {

        });
      }
    });

    notiEvent = NotiEvent();
    notiEvent.addListener(() {
      //액션을 취한다.
      debugPrint('register msg : ${notiEvent.msg}');

      if(notiEvent.msg == "pw")
      {
        passwordVisible = false;
      }
      else if(notiEvent.msg == "pw2")
      {
        rePasswordVisible = false;
      }

      setState(() {

      });
    });

    // 게시판 가져오기
    JsonApi.getMemberGroupCategory().then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        MemberGroupData.items = List.from((apiResponse.data as List)).map<MemberGroup>((item) => MemberGroup.fromJson(item)).toList();

        for(var item in MemberGroupData.items)
        {
          if(item.gr_id.isNotEmpty)
          {
            menuItems.add(DropdownMenuItem(
              value: item.gr_id,
              child: Text(item.gr_subject),
            ));
          }
        }

        if(mounted) {
          setState(() {
            initialized = true;
          });
        }
      }
      else
      {
        Fluttertoast.showToast(
            msg: (apiResponse.apiError).msg ,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 13.0
        );

      }
    });


    final Future<String> ua = userAgent();

    ua.then((val) {
      setState(() {
        _userAgent = val;

        if (Platform.isAndroid) {
          webViewUserAgent = '$_userAgent ANDROID_APP';
        } else if (Platform.isIOS) {
          webViewUserAgent = '$_userAgent IOS_APP';
        }

      });
      // int가 나오면 해당 값을 출력
      debugPrint('val: $webViewUserAgent');
    }).catchError((error) {
      // error가 해당 에러를 출력
      // print('error: $error');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(    // <-  WillPopScope로 감싼다.
          onWillPop: () {
            Navigator.pop(context);
            return Future(() => false);
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("회원가입", textAlign: TextAlign.center,
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
            body:
            (!initialized)
                ?
            Container(
              color: Colors.white,
              child:const Center(
                child: CircularProgressIndicator(),
              ),
            )
            :
            SafeArea (
              child : GestureDetector(
                // behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).requestFocus(myFocusNode);
                },
                child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  clipBehavior: Clip.antiAlias,
                  // color:const Color(0xFFdddddd),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Color(0xFFDDDDDD), spreadRadius: 1),
                    ],
                  ),
                  child: Form(
                    key:globalKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (menuItems.isNotEmpty)
                            ?
                        Column(
                            crossAxisAlignment : CrossAxisAlignment.start,
                            children: <Widget> [
                              Container(
                                margin: const EdgeInsets.only(left: 15.0, bottom: 5.0, top: 10.0, right: 15.0),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                    contentPadding: const EdgeInsets.only(left: 15.0, bottom: 0.0, top: 0.0, right: 0.0),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: currentSelectedValue,
                                      isDense: true,
                                      isExpanded: true,
                                      items: menuItems,
                                      onChanged: (newValue) {
                                        if(newValue != null)
                                        {
                                          setState(() {
                                            currentSelectedValue = newValue;
                                          });
                                        }
                                      },
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: kPrimaryColor),
                                      hint: const Text("카테고리 선택"),

                                    ),
                                  ),
                                ),
                              ),
                            ]
                        )
                            :
                        Container(),

                        Focus(
                          child: CustomFormField(
                            hintText: '아이디(대소문자 구분)',
                            controller: idController,
                            keyBoardType: TextInputType.text,
                            textInputAction:TextInputAction.next,
                            isAutoFocus: true,
                            isEnable: true,
                            isReadonly: false,
                            isPassword: false,
                            isRequired: true,
                            textAlign: TextAlign.left,
                            validator: (val) {
                              // debugPrint('validator ${val.toString()}');
                              // return 'Enter valid email';
                            },
                            errorText: provider.id.error,
                            // onChanged: formProvider.validateEmail,
                          ),
                          onFocusChange: (hasFocus) {
                            if(!hasFocus) {
                              debugPrint('포커스 OUT');
                              provider.validateId(idController.text);
                              idCheck();
                            }
                            else
                            {
                              // debugPrint('포커스 IN');
                            }
                          },
                        ),

                        Focus(
                          child: CustomFormField(
                            hintText: '비밀번호(대소문자 구분)',
                            controller: pwController,
                            keyBoardType: TextInputType.text,
                            textInputAction:TextInputAction.next,
                            isAutoFocus: false,
                            isReadonly: false,
                            isEnable: true,
                            isPassword: passwordVisible,
                            isRequired: true,
                            textAlign: TextAlign.left,
                            id: 'pw',
                            validator: (val) {
                              // debugPrint('validator ${val.toString()}');
                              // return 'Enter valid email';
                            },
                            errorText: provider.password.error,
                            // onChanged: formProvider.validateEmail,
                          ),
                          onFocusChange: (hasFocus) {
                            if(!hasFocus) {
                              provider.validatePassword(pwController.text);
                            }
                            else
                            {
                              // debugPrint('포커스 IN');
                            }
                          },
                        ),

                        Focus(
                          child: CustomFormField(
                            hintText: '비밀번호 확인',
                            controller: pw2Controller,
                            keyBoardType: TextInputType.text,
                            textInputAction:TextInputAction.next,
                            isAutoFocus: false,
                            isReadonly: false,
                            isEnable: true,
                            isPassword: rePasswordVisible,
                            isRequired: true,
                            id: 'pw2',
                            textAlign: TextAlign.left,
                            validator: (val) {
                              // debugPrint('validator ${val.toString()}');
                              // return 'Enter valid email';
                            },
                            errorText: provider.rePassword.error,
                            // onChanged: formProvider.validateEmail,
                          ),
                          onFocusChange: (hasFocus) {
                            if(!hasFocus) {
                              provider.validateRePassword(pw2Controller.text);
                            }
                            else
                            {
                              // debugPrint('포커스 IN');
                            }
                          },
                        ),

                        // Container(
                        //   margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                        //   child: Stack(
                        //     alignment: Alignment.centerRight,
                        //     children: <Widget>[
                        //       Focus(
                        //         child: CustomFormField(
                        //           hintText: '이메일',
                        //           controller: emailController,
                        //           keyBoardType: TextInputType.emailAddress,
                        //           textInputAction:TextInputAction.next,
                        //           isAutoFocus: false,
                        //           isReadonly: false,
                        //           isEnable: true,
                        //           isPassword: false,
                        //           isRequired: false,
                        //           textAlign: TextAlign.left,
                        //           validator: (val) {
                        //             debugPrint('validator ${val.toString()}');
                        //           },
                        //           errorText: provider.email.error,
                        //           // onChanged: formProvider.validateEmail,
                        //         ),
                        //         onFocusChange: (hasFocus) {
                        //
                        //           debugPrint('emailController.text ${emailController.text}');
                        //
                        //           if(!hasFocus) {
                        //
                        //             if(emailController.text != "")
                        //             {
                        //               provider.validateEmail(emailController.text);
                        //               emailCheck();
                        //             }
                        //           }
                        //           else
                        //           {
                        //             // debugPrint('포커스 IN');
                        //           }
                        //         },
                        //       ),
                        //       SizedBox(
                        //           width: 120,
                        //           height: 48,
                        //           child: Container(
                        //               padding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 5.0),
                        //               margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 5.0, right: 18.0),
                        //               color: const Color(0xFFe9ecef),
                        //               child: Row(
                        //                 children: [
                        //                   Transform.scale(
                        //                     scale: 0.9,
                        //                     child: Checkbox(value: isAgreeEmail,
                        //                         onChanged: (value) {
                        //                           setState(() {
                        //                             isAgreeEmail = value!;
                        //                           });
                        //                         }),
                        //                   ),
                        //                   const Text(
                        //                     "수신동의",
                        //                     style: TextStyle(fontSize: 12.0),
                        //                   )
                        //                 ],
                        //               ),
                        //           )
                        //       )
                        //     ]
                        //   ),
                        // ),

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
                                  errorText: provider.name.error,
                                  // onChanged: formProvider.validateEmail,
                                ),
                                onFocusChange: (hasFocus) {
                                  if(!hasFocus) {
                                    provider.validateName(nameController.text);
                                  }
                                  else
                                  {
                                    // debugPrint('포커스 IN');
                                  }
                                },
                              ),

                              (hpAuthButton)
                              ?
                              Positioned( // <-- doesn't work
                                top: 10.0, // <-- how to make it also relative to parent's height parameter?
                                right: -2.0, // <-- how to make it also relative to parent's height parameter?
                                child: Container(
                                  margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 25.0),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context,rootNavigator: true).push(
                                          MaterialPageRoute(builder: (context) => const HpAuth())
                                      ).then((value){
                                        if(value != null)
                                        {
                                          // hp,정병주,01027383653,9b244cf6cd1e0180e1926417abc4a8ea,M,1980,07,16
                                          debugPrint('본인인증 $value');

                                          final split = value.split(",");

                                          if(split[1] != "" && split[2] != "")
                                          {
                                            setState(() {
                                              nameController.text = split[1];
                                              hpController.text = split[2];

                                              provider.name.value = split[1];
                                              provider.name.error = null;

                                              provider.phone.value = split[2];
                                              provider.phone.error = null;

                                              mbDupinfo = split[3];
                                              mbSex     = split[4];
                                              mbBirth   = split[5] + '-' + split[6] + '-' + split[7];

                                              hpAuthButton = false;

                                              setState(() {

                                              });
                                            });
                                          }
                                        }
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.only(left: 15.0, bottom: 0.0, top: 0.0, right: 15.0),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                      backgroundColor: kButtonColor,
                                    ),
                                    child:
                                    const Text("휴대폰 본인인증",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  )
                                )
                              )
                              :
                              const SizedBox(),
                            ],
                          ),
                        ),

                        // _entryFieldHpAuth("이름", nameController),

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
                                    errorText: provider.phone.error,
                                    // onChanged: formProvider.validateEmail,
                                  ),
                                  onFocusChange: (hasFocus) {
                                    if(!hasFocus) {
                                      provider.validatePhone(hpController.text);
                                    }
                                    else
                                    {
                                      // debugPrint('포커스 IN');
                                    }
                                  },
                                ),
                                Positioned( // <-- doesn't work
                                    top: 11.0, // <-- how to make it also relative to parent's height parameter?
                                    right: -2.0, // <-- how to make it also relative to parent's height parameter?
                                    child: SizedBox(
                                    width: 120,
                                    height: 46,
                                    child: Container(
                                    padding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 5.0),
                                    margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 18.0),
                                    color: const Color(0xFFe9ecef),
                                    child: Row(
                                      children: [
                                        Transform.scale(
                                          scale: 0.9,
                                          child: Checkbox(value: isAgreeHp,
                                              onChanged: (value) {
                                                setState(() {
                                                  isAgreeHp = value!;
                                                });
                                              }),
                                        ),
                                        const Text(
                                          "수신동의",
                                          style: TextStyle(fontSize: 12.0),
                                        )
                                      ],
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
                                    controller: certController,
                                    keyBoardType: TextInputType.phone,
                                    textInputAction:TextInputAction.next,
                                    isAutoFocus: false,
                                    isReadonly: false,
                                    isEnable: certReadOnly,
                                    isPassword: false,
                                    isRequired: true,
                                    textAlign: TextAlign.left,
                                    validator: (val) {
                                      debugPrint('validator ${val.toString()}');
                                    },
                                    errorText: provider.phone.error,
                                    // onChanged: formProvider.validateEmail,
                                  ),
                                  onFocusChange: (hasFocus) {
                                    if(!hasFocus) {
                                      provider.validateCert(certController.text);
                                    }
                                    else
                                    {
                                      // debugPrint('포커스 IN');
                                    }
                                  },
                                ),
                                Positioned( // <-- doesn't work
                                    top: 11.0, // <-- how to make it also relative to parent's height parameter?
                                    right: -2.0, // <-- how to make it also relative to parent's height parameter?
                                    child: SizedBox(
                                        width: 120,
                                        height: 46,
                                        child: Container(
                                          padding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                          margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 18.0),
                                          color: kButtonColor,
                                          child: TextButton(
                                            onPressed: () {
                                              debugPrint('sdf');
                                              final parameters = {"sender_hp": hpController.text, "sms_id": "jnpass", "sms_pw": "qhrehd@ss"};
                                              JsonApi.postApi("rest/cert_phone", parameters).then((value) {
                                                ApiResponse apiResponse = ApiResponse();

                                                apiResponse = value;

                                                certReadOnly = true;
                                                FocusScope.of(context).unfocus();

                                                setState(() {

                                                });

                                                if((apiResponse.apiError).error == "9") {

                                                  final responseData = json.decode(apiResponse.data.toString());
                                                  debugPrint('data ${apiResponse.data}');

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
                                              padding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                              backgroundColor: kButtonColor,
                                            ),
                                            child:
                                            const Text("인증번호받기",
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                        )
                                    )
                                )
                              ]
                          ),
                        ),

                        Focus(
                          child: CustomFormField(
                            hintText: '닉네임(공백X,한글2자, 영문4자 이상)',
                            controller: nickController,
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
                            errorText: provider.nick.error,
                            // onChanged: formProvider.validateEmail,
                          ),
                          onFocusChange: (hasFocus) {
                            if(!hasFocus) {
                              provider.validateNick(nickController.text);
                              nickCheck();
                            }
                            else
                            {
                              // debugPrint('포커스 IN');
                            }
                          },
                        ),

                        Container(
                          margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                          child: Stack(
                              alignment: Alignment.centerRight,
                              children: <Widget>[
                                Focus(
                                  child: CustomFormField(
                                    hintText: '추천인',
                                    controller: recommendController,
                                    keyBoardType: TextInputType.text,
                                    textInputAction:TextInputAction.next,
                                    isAutoFocus: false,
                                    isReadonly: false,
                                    isEnable: certReadOnly,
                                    isPassword: false,
                                    isRequired: true,
                                    textAlign: TextAlign.left,
                                    validator: (val) {
                                      debugPrint('validator ${val.toString()}');
                                    },
                                    errorText: '',
                                    // onChanged: formProvider.validateEmail,
                                  ),
                                  onFocusChange: (hasFocus) {
                                    if(!hasFocus) {

                                    }
                                    else
                                    {
                                      // debugPrint('포커스 IN');
                                    }
                                  },
                                ),
                                Positioned( // <-- doesn't work
                                    top: 11.0, // <-- how to make it also relative to parent's height parameter?
                                    right: -2.0, // <-- how to make it also relative to parent's height parameter?
                                    child: SizedBox(
                                        width: 120,
                                        height: 46,
                                        child: Container(
                                          padding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                          margin: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 18.0),
                                          color: const Color(0xFFe9ecef),
                                          child: TextButton(
                                            onPressed: () {

                                              final parameters = {"": ''};
                                              JsonApi.getApi("rest/check/${recommendController.text}", parameters).then((value) {
                                                ApiResponse apiResponse = ApiResponse();

                                                apiResponse = value;

                                                if((apiResponse.apiError).error == "9") {

                                                  final responseData = json.decode(apiResponse.data.toString());
                                                  debugPrint('data ${apiResponse.data}');

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
                                              padding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                              backgroundColor: kButtonColor,
                                            ),
                                            child:
                                            const Text("아이디찾기",
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                        )
                                    )
                                )
                              ]
                          ),
                        ),

                        // _entryFieldAgree("휴대전화", hpController, isAgreeHp, isEnabled: false),
                        Container(
                          margin: const EdgeInsets.only(left: 15.0, bottom: 5.0, top: 10.0, right: 15.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: const Color(0xFFDDDDDD),
                            ),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                color: const Color(0xFFe9ecef),
                                child: CheckboxListTile(
                                  // 체크박스 앞으로 이동
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: const Text("전체동의",
                                      style:TextStyle(fontSize: 13)
                                  ),  // The named parameter 'title' isn't defined.
                                  contentPadding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                  value: isAgreeAll,
                                  onChanged: (value) {
                                    setState(() {
                                      isAgreeAll = value!;
                                      isAgree1 = value;
                                      isAgree2 = value;
                                    });
                                  },
                                  ),
                                ),
                                CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: const Text("이용약관(필수)",
                                      style:TextStyle(fontSize: 12)
                                  ),  // The named parameter 'title' isn't defined.
                                  contentPadding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                  secondary:Container(
                                      padding:const EdgeInsets.only(left: 0, bottom: 0.0, top: 0.0, right: 0.0),
                                      child: IconButton(
                                          tooltip:"약관 보기",
                                          onPressed: () {
                                            Navigator.of(context,rootNavigator: true).push(
                                              MaterialPageRoute(builder: (context) =>
                                              const AgreePage()),);
                                          },
                                          icon: const Icon(Icons.arrow_forward_ios_sharp)
                                      )
                                  ),
                                  value: isAgree1,
                                  onChanged: (value) {
                                    setState(() {
                                      isAgree1 = value!;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: const Text("개인정보 수집 및 이용(필수)",
                                      style:TextStyle(fontSize: 12)
                                  ),
                                  contentPadding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                                  secondary:Container(
                                      padding:const EdgeInsets.only(left: 0, bottom: 0.0, top: 0.0, right: 0.0),
                                      child: IconButton(
                                          tooltip:"약관 보기",
                                          onPressed: () {
                                            Navigator.of(context,rootNavigator: true).push(
                                              MaterialPageRoute(builder: (context) =>
                                              const AgreePage()),);
                                          },
                                          icon: const Icon(Icons.arrow_forward_ios_sharp)
                                      )
                                  ),
                                  value: isAgree2,
                                  onChanged: (value) {
                                    setState(() {
                                      isAgree2 = value!;
                                    });
                                  },
                                ),
                              ]
                            )
                        )

                      ]
                    )
                  )
                )
              )
              )
            ),
            bottomNavigationBar:
                Container(
                  height: 40,
                  color: Colors.transparent,
                  margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                  child:Padding(
                    padding: const EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                    child: TextButton(
                      onPressed: () {

                        String? msg = provider.validateMsg;

                        if(isAgree1 == false)
                        {
                          msg = "이용약관에 동의를 해주세요";
                        }

                        if(isAgree2 == false)
                        {
                          msg = "개인정보 수집 및 이용에 동의를 해주세요";
                        }

                        if(msg != "false" && msg != null)
                        {
                            Fluttertoast.showToast(
                                msg: msg,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.orange,
                                textColor: Colors.white,
                                fontSize: 13.0
                            );
                        }
                        else
                        {
                          if(provider.validate)
                          {
                            regisAction();
                          }
                        }

                      },
                      style: TextButton.styleFrom(
                        backgroundColor: kButtonColor,
                      ),
                      child: const Text('회원가입',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    )
              ),
            ),
      )
    );
  }

  Future<void> idCheck() async {
    if(provider.id.value.toString().length > 5) {

      ApiResponse apiResponse = ApiResponse();

      try {
        Uri url = Uri.parse(
            '${appApiUrl}app_id_chk.php');
        final response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String>{
            'mb_id': idController.text
          },
        );

        switch (response.statusCode) {
          case 200:
            var responseBody = response.body;
            Map<String, dynamic> responseData = json.decode(responseBody);

            // debugPrint(responseData['data']);

            if (responseData['data'] == 'false') {
              provider.id.value = null;
              provider.id.error = "아이디가 존재합니다. 다른 아이디로 등록해주세요.";
              apiResponse.apiError =
                  ApiError("7", "아이디가 존재합니다. 다른 아이디로 등록해주세요.");

              setState(() {

              });
            }
            else {
              apiResponse.apiError = ApiError("9", "");
            }

            break;
          case 401:
            apiResponse.apiError = ApiError("4", "401");
            break;
          default:
            apiResponse.apiError = ApiError("1", "http 상태 에러");
            break;
        }
      } on SocketException {
        apiResponse.apiError = ApiError("8", "app_id_chk.php socket error");
      }

      if ((apiResponse.apiError).error == "9") {

      }
      else
      {
        Fluttertoast.showToast(
            msg: (apiResponse.apiError).msg ,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 13.0
        );
      }

    }
  }

  Future<void> emailCheck()
  async {

    debugPrint('email ${provider.email.value.toString()}');

    if(provider.email.value.toString().isValidEmail)
    {
      // 이미 등록된 이메일이 있는지 확인
      ApiResponse apiResponse = ApiResponse();
      try {
        Uri url = Uri.parse(
            '${appApiUrl}app_email_chk.php');
        final response = await http.post(url,
          headers: <String, String> {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String> {
            'mb_email': provider.email.value.toString()
          },
        );

        switch (response.statusCode) {
          case 200:
            var responseBody = response.body;
            Map<String, dynamic> responseData = json.decode(responseBody);

            debugPrint('ccc ${responseData['data']} ');

            if(responseData['data'] == 'false')
            {
              apiResponse.apiError = ApiError("7", "이메일이 존재합니다. 다른 이메일로 입력해주세요.");
            }
            else
            {
              apiResponse.apiError = ApiError("9", "");
            }
            break;
          case 401:
            apiResponse.apiError = ApiError("4", "401");
            break;
          default:
            apiResponse.apiError = ApiError("1", "http 상태 에러");
            break;
        }
      } on SocketException {
        apiResponse.apiError = ApiError("8", "app_member_group_cate.php socket error");
      }

      if((apiResponse.apiError).error == "9") {

      }
      else
      {
        Fluttertoast.showToast(
            msg: (apiResponse.apiError).msg ,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 13.0
        );
      }
    }
  }

  Future<void> nickCheck()
  async {

    debugPrint('nick ${provider.nick.value.toString()}');

    // 이미 등록된 닉네임이 있는지 확인
    ApiResponse apiResponse = ApiResponse();
    try {
      Uri url = Uri.parse(
          '${appApiUrl}app_nick_chk.php');
      final response = await http.post(url,
        headers: <String, String> {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: <String, String> {
          'mb_nick': provider.nick.value.toString()
        },
      );

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;
          Map<String, dynamic> responseData = json.decode(responseBody);

          if(responseData['data'] == 'false')
          {
            apiResponse.apiError = ApiError("7", "닉네임이 존재합니다. 다른 닉네임을 입력해주세요.");
          }
          else
          {
            apiResponse.apiError = ApiError("9", "");
          }
          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          break;
        default:
          apiResponse.apiError = ApiError("1", "http 상태 에러");
          break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "app_nick_chk.php socket error");
    }

    if((apiResponse.apiError).error == "9") {

    }
    else
    {
      Fluttertoast.showToast(
          msg: (apiResponse.apiError).msg ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 13.0
      );
    }

  }

  Future<void> hpCheck()
  async {
    if(provider.phone.value.toString().length > 5) {

      ApiResponse apiResponse = ApiResponse();

      try {
        Uri url = Uri.parse(
            '${appApiUrl}app_hp_chk.php');
        final response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: <String, String>{
            'mb_id': idController.text,
            'mb_hp': hpController.text
          },
        );

        switch (response.statusCode) {
          case 200:
            var responseBody = response.body;
            Map<String, dynamic> responseData = json.decode(responseBody);

            debugPrint(responseData['data']);

            if (responseData['data'] == 'false') {
              provider.phone.value = null;
              provider.phone.error = "입력하신 본인확인 정보로 가입된 내역이 존재합니다.";
              apiResponse.apiError =
                  ApiError("7", "입력하신 본인확인 정보로 가입된 내역이 존재합니다.");

              setState(() {

              });
            }
            else {
              apiResponse.apiError = ApiError("9", "");
            }

            break;
          case 401:
            apiResponse.apiError = ApiError("4", "401");
            break;
          default:
            apiResponse.apiError = ApiError("1", "http 상태 에러");
            break;
        }
      } on SocketException {
        apiResponse.apiError = ApiError("8", "app_hp_chk.php socket error");
      }

      if ((apiResponse.apiError).error == "9") {

      }
      else
      {
        Fluttertoast.showToast(
            msg: (apiResponse.apiError).msg ,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 13.0
        );
      }

    }
  }


  Future<void> regisAction()
  async {
    debugPrint('regisAction');
    if(provider.id.value.toString().length > 5) {

      debugPrint('currentSelectedValue ${currentSelectedValue}');

      final parameters = {"gr_id": currentSelectedValue, "mb_id": idController.text, "mb_password": pwController.text, "re_mb_password": pw2Controller.text,
        "mb_hp": hpController.text, "mb_sms": (isAgreeHp) ? "1" : "0", "cert_number": certController.text,"mb_name": nameController.text,
        "mb_nick": nickController.text, "mb_recommend": recommendController.text};
      JsonApi.postApi("rest/join", parameters).then((value) {
        ApiResponse apiResponse = ApiResponse();

        apiResponse = value;

        if((apiResponse.apiError).error == "9") {

          final responseData = json.decode(apiResponse.data.toString());
          debugPrint('data ${apiResponse.data}');

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

            prefs.setString('jwt_token', responseData['jwt_token']);

            Navigator.pop(context, "");
            Navigator.pop(context, "");
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



      /*
      if ((apiResponse.apiError).error == "9") {

        prefs.setString('mb_id', idController.text.trim());

        var jsonString = '{"type": "regis_ok","result": "ok","mb_id": "${idController.text.trim()}"}';
        Map<String, dynamic> json = jsonDecode(jsonString);

        Fluttertoast.showToast(
            msg: "회원가입해주셔서 감사합니다." ,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 13.0
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context, json);
      }
      else
      {
        Fluttertoast.showToast(
            msg: (apiResponse.apiError).msg ,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 13.0
        );
      }
      */
    }
  }

  static const platform = MethodChannel('이름아무거나');

  Future<String> getAppUrl(String url) async {
    if (Platform.isAndroid) {
      return await platform
          .invokeMethod('getAppUrl', <String, Object>{'url': url});
    } else {
      return url;
    }
  }

  bool isAppLink(String url) {
    final appScheme = Uri.parse(url).scheme;

    return appScheme != 'http' &&
        appScheme != 'https' &&
        appScheme != 'about:blank' &&
        appScheme != 'data';
  }


  md5(String data) {
    var digestObject = MD5Digest();
    var bytes = digestObject.process(convertStringToUint8List(data));
    String digest = HEX.encode(bytes);

    return digest;
  }

  Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    pw2Controller.dispose();
    emailController.dispose();
    nickController.dispose();
    nameController.dispose();
    hpController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }


}