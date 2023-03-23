import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jnpass/pages/shareview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/jsonapi.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import '../models/boardmodel.dart';

class PasswordPage extends StatefulWidget {
  String wrId;

  PasswordPage( {Key? key, required this.wrId}) : super(key: key);

  @override
  PasswprdPageState createState() => PasswprdPageState();
}

class PasswprdPageState extends State<PasswordPage> {
  late SharedPreferences prefs;
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  int page = 1;
  int totalPage = 1;
  int limit = 8;

  @override
  void initState () {
    SharedPreferences.getInstance().then((value) async {
      prefs = value;
    });

    super.initState();
  }

  void password_check(String wrId, String password) async {
    // BoardData.items.clear();

    final parameters = {"wr_id": wrId , "password": password };
    JsonApi.getApi("rest/cs/password_check", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        // if(kDebug)
        // {
        debugPrint('data ${apiResponse.data}');
        // }

        if(responseData['code'].toString() == "101")
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
        else if(responseData['code'].toString() == "0")
        {
          Navigator.of(context,rootNavigator: true).push(
              MaterialPageRoute(builder: (context) =>
                  ShareView(wrId:wrId))
          );

          // Navigator.pop(context);

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


  @override
  Widget build(BuildContext context) {

    return Scaffold (
        appBar: AppBar(
          centerTitle: true,
          title: const Text("상담내역", textAlign: TextAlign.center,
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
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  verticalDirection: VerticalDirection.down,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 15, bottom: 0),
                      child: const Text('등록하신 휴대폰 뒷자리를 입력해주세요', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF626363)),),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 20, right: 15.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: const BorderSide(color: Color(0xFF98BF54), width: 2.0)),
                          contentPadding: const EdgeInsets.only(left:15, top: 5, bottom: 0, right: 5),
                        ),
                        child:
                        TextField(
                          controller: passwordController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '휴대폰 뒷자리를 입력해 주세요',
                              // suffixIcon: IconButton(
                              //   icon: const Icon(
                              //     Icons.search,
                              //     color: Color(0xFF98BF54),
                              //   ),
                              //   onPressed: () {
                              //   },
                              // )
                          ),

                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.all(13),
                        child: InkWell(
                            onTap: () {
                              password_check(widget.wrId, passwordController.text);
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
                                '확인',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            )
                        )
                    ),
                  ],
                )
            )
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}