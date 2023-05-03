import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/jsonapi.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import 'login_page.dart';


class UserPage extends StatefulWidget {

  const UserPage({Key? key}) : super(key: key);

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  late SharedPreferences prefs;
  String jwtToken = '';

  late dynamic mbData;
  late String meLoc;
  late String msgType;
  final TextEditingController pwController    = TextEditingController();
  final TextEditingController rePwController  = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool passwordVisible = true;
  bool passwordVisible2 = true;

  @override
  void initState() {

    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      jwtToken = prefs.getString('jwt_token') ?? "";

      final parameters = {"jwt_token": jwtToken};
      JsonApi.getApi("rest/jwt_token", parameters).then((value) {
        ApiResponse apiResponse = ApiResponse();

        apiResponse = value;

        if((apiResponse.apiError).error == "9") {

          final responseData = json.decode(apiResponse.data.toString());
          debugPrint('data ${apiResponse.data}');

          if(responseData['code'].toString() == "0")
          {
            mbData = responseData;
            debugPrint('data ${mbData['data']['mb_id']}');

            setState(() {

            });
          }
          else if(responseData['code'].toString() == "101")
          {
            prefs.remove('jwt_token');

            Navigator.of(context,rootNavigator: true).push(
              MaterialPageRoute(builder: (context) =>
              const LoginPage()),).then((value){
            });

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

    });

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      // behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child:WillPopScope(
        onWillPop: () async {
          Navigator.of(context, rootNavigator: true).pop(context);
          return true;
        },
        child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("회원정보수정", textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 15),),
            backgroundColor: Colors.white,
            // elevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
              },
              color: Colors.black,
            ),
        ),
        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.
        body: Builder(builder: (BuildContext context) {
          // return Container();
          return
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        const SizedBox(height: 10),

                        _entryField("비밀번호", pwController, isPassword: passwordVisible),
                        _entryField("비밀번호 확인", rePwController, isPassword: passwordVisible2),
                        // _entryField("이메일 주소", emailController, isPassword: false, isEmail: true),
                        const SizedBox(height: 10),
                        _submitButton(),
                      ]
                    )
                  )
            );
        }),
      )
      )
    );
  }

  // 이메일 양식 맞는지 체크
  String validateEmail(String? value) {

    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value.toString());

    // debugPrint(' emailValid : $emailValid');
    if (emailValid) {
      return 'Y';
    } else {
      return 'N';
    }
  }

  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false, bool isEmail = false}) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        // height: 35.0,
        // alignment: Alignment.center,
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
          style: const TextStyle(
            fontSize: 12.0,
          ),
          keyboardType:(isEmail) ? TextInputType.emailAddress : TextInputType.text,
          onSubmitted: (value) {

          },
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            hintText: title,
            // hintStyle: TextStyle(color: ColorConstants.greyColor),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              borderSide: BorderSide(width: 1.0),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
            ),
            suffixIcon: (isPassword) ? IconButton(
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.grey,
              ),
              onPressed: () {
                // Update the state i.e. toogle the state of passwordVisible variable
                setState(() {
                  if(title == "비밀번호")
                  {
                    passwordVisible = !passwordVisible;
                  }
                  else
                  {
                      passwordVisible2 = !passwordVisible2;
                  }
                });
              },
            ) : null

          ),
          // focusNode: focusNode,
        )
        ]
      )
    );

    /*
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              controller: _controller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xffdcdcdc),
                  filled: true))
        ],
      ),
    );
    */
  }

  Widget _submitButton() {
    return MaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());

        msgType = '';

        if(pwController.text.isNotEmpty || rePwController.text.isNotEmpty)
        {
          if(pwController.text.trim().length < 6 ) {
            msgType = '5';
          }

          if(pwController.text != rePwController.text)
          {
            msgType = '6';
          }
        }
        // 이메일 양식 체크
        // if(validateEmail(emailController.text) == "N")
        // {
        //   msgType = '7';
        // }

        // debugPrint('msgType : $msgType');

        if(msgType == "")
        {
          // final parameters = {"jwt_token": jwtToken, "mb_password" : pwController.text, "mb_email" : emailController.text};
          final parameters = {"jwt_token": jwtToken, "mb_password" : pwController.text};
          JsonApi.postApi("rest/member_password", parameters).then((value) {
            ApiResponse apiResponse = ApiResponse();

            apiResponse = value;

            if((apiResponse.apiError).error == "9") {

              // final responseData = json.decode(apiResponse.data.toString());
              // debugPrint('data ${apiResponse.data}');
              // if(responseData['code'].toString() == "0")
              // {
              //
              //   setState(() {
              //
              //   });
              // }
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
        else
        {
          Fluttertoast.showToast(
              msg: msgList[int.parse(msgType)]['val'] ,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              fontSize: 13.0
          );

        }
      },
      height: 34.0,
      minWidth: 100.0,
      color: Colors.blue,
      child: const Text(
        "정보수정",
        style: TextStyle(color: Colors.white, fontSize: 13.0),
      ),
    );
  }

  @override
  void dispose() {
    // debugPrint('dispose');
    super.dispose();
  }

}








