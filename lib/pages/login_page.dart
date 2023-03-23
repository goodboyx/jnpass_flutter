import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jnpass/common.dart';
import 'package:jnpass/pages/searchidpw.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../api/jsonapi.dart';
import '../models/apiResponse.dart';
import '../models/bannermodel.dart';
import '../models/notiJwttokenEvent.dart';
import 'noticeview.dart';
import 'resgister_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late SharedPreferences prefs;

  Uuid uuid = const Uuid();
  late String uuidV4 = uuid.v4().toString();

  DateTime? currentBackPressTime;

  bool passwordVisible = true;
  NotiJwttokenEvent notiJwttokenEvent = NotiJwttokenEvent();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) {
      prefs = value;
      prefs.setString('jwt_token', '');
    });

    dataAdSlide();
  }

  //상단 이미지 배너
  void dataAdSlide() {
    // BannerData.items.clear();

    final parameters = {"": ""};
    JsonApi.getApi("rest/banner", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data}');

        if(responseData['code'].toString() == "0")
        {
          BannerData.items = List.from(responseData['items'])
              .map<BannerModel>((item) => BannerModel.fromJson(item))
              .toList();

          setState(() {});
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

  }

  Widget _entryField(String title, TextEditingController controller, String action, {bool isPassword = false} ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   title,
          //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
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
              decoration: InputDecoration(
                  hintText: title,
                  // hintStyle: const TextStyle(color: Color(0xFFA09E9E)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFA485BB),
                      width: 0.0,
                    ),
                  ),
                  fillColor: const Color(0xFFFFFFFF),
                  filled: true,
                  suffixIcon: (isPassword) ? IconButton(
                    icon: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ) : null

              )
          )
        ],
      ),
    );
  }

  void _submitButton() {
    // FocusScope.of(context).requestFocus(FocusNode());
    // debugPrint(' ${id_controller.text.trim()} : ${pw_controller.text.trim()}');
    if (idController.text.trim() == "") {
      Fluttertoast.showToast(
          msg: "아이디를 입력해주세요",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 13.0
      );
    }
    else if (pwController.text.trim() == "") {
      Fluttertoast.showToast(
          msg: "비밀번호를 입력해주세요",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 13.0
      );
    }
    else {

      final parameters = {"mb_id": idController.text, "mb_password": pwController.text};
      JsonApi.postApi("rest/login", parameters).then((value) {

        ApiResponse apiResponse = ApiResponse();

        apiResponse = value;

        if((apiResponse.apiError).error == "9") {
          final responseData = json.decode(apiResponse.data.toString());
          debugPrint('data ${apiResponse.data}');

          if(responseData['code'].toString() == "0")
          {

            jwtToken = responseData['jwt_token'];

            debugPrint('login jwt_token ${jwtToken}' );
            prefs.setString('jwt_token', responseData['jwt_token']);
            notiJwttokenEvent.notify(jwtToken);

            Navigator.pushReplacementNamed(context, '/');
            // Navigator.of(context, rootNavigator: true).pop('ok');
            // Navigator.of(context);
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

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("아이디를 입력해주세요",  idController, 'next'),
        _entryField("비밀번호를 입력해주세요", pwController, 'action', isPassword: passwordVisible),
      ],
    );
  }

  Future<bool> onWillPop(){
    Navigator.pushReplacementNamed(context, '/');

    // DateTime now = DateTime.now();
    //
    // if(currentBackPressTime == null || now.difference(currentBackPressTime!)
    //     > const Duration(seconds: 2))
    // {
    //   currentBackPressTime = now;
    //   const msg = "'뒤로'버튼을 한 번 더 누르면 종료됩니다.";
    //
    //   Fluttertoast.showToast(msg: msg);
    //   return Future.value(false);
    // }
    //
    // // Navigator.pop(context, 'exit');
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("로그인", textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 15),),
          backgroundColor: Colors.white,
          // elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {

            },
            color: Colors.white,
          )
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child:  WillPopScope(
          onWillPop: onWillPop,
          child: GestureDetector(
            // behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: SizedBox(
                height: height,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: height * .05),
                            const Image(image:AssetImage("assets/images/logo.png")),
                            const SizedBox(height: 20),
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 120,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                              ),
                              items: BannerData.items.toList().map((item) => GestureDetector(
                                  child: Image.network(item.img_src, fit:BoxFit.cover, width: 900),
                                  onTap: () {
                                    Navigator.of(context,rootNavigator: true).push(
                                        MaterialPageRoute(builder: (context) =>
                                            NoticeView(wrId:item.link))
                                    );
                                  }
                              ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                            _emailPasswordWidget(),
                            const SizedBox(height: 10),
                            InkWell(
                                onTap: () {
                                  _submitButton();
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
                                    '로그인',
                                    style: TextStyle(fontSize: 20, color: Colors.white),
                                  ),
                                )
                            ),
                            _divider(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.of(context,rootNavigator: true).push(
                                            MaterialPageRoute(builder: (context) =>
                                                const RegisterPage()),).then((value){

                                            if(value != null)
                                            {
                                              if(value['mb_id'] != "")
                                              {
                                                Navigator.pop(context, value);
                                              }

                                            }

                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          alignment: Alignment.center,
                                          child: const Text('회원가입',
                                              style: TextStyle(
                                                  fontSize: 14, fontWeight: FontWeight.w500)),
                                        )
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      height: 20,
                                      child: VerticalDivider(
                                        color: Colors.grey,
                                        thickness: 1,
                                        indent: 0,
                                        endIndent: 0,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.of(context,rootNavigator: true).push(
                                            MaterialPageRoute(builder: (context) => const SearchIDPWPage())
                                          ).then((value) {

                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          alignment: Alignment.center,
                                          child: const Text('비밀번호찾기',
                                              style: TextStyle(
                                                  fontSize: 14, fontWeight: FontWeight.w500)),
                                        )
                                    ),
                                  ),
                                ]
                            ),
                            // _facebookButton(),
                            SizedBox(height: height * .055),
                            // _createAccountLabel(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        )
      )
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
