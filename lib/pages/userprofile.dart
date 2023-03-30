import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/jsonapi.dart';
import '../common.dart';
import '../constants.dart';
import '../models/apiResponse.dart';


class UserProfile extends StatefulWidget {
  String user_id;

   UserProfile({Key? key, required this.user_id}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<UserProfile> {
  late SharedPreferences prefs;
  bool isLoading = false;
  dynamic mbData = json.decode('{"mb_id": ""}');

  @override
  void initState () {
    super.initState();
    SharedPreferences.getInstance().then((value){
      prefs = value;

      getUser();

    });

  }

  void getUser() async {
    final parameters = {"jwt_token": jwtToken};
    JsonApi.getApi("rest/member/${widget.user_id}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());

        if(kDebug)
        {
          debugPrint('data ${apiResponse.data}');
        }

        if(mounted)
        {
          setState(() {
            mbData = responseData;
            isLoading = true;
          });
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

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("사용자 프로필", textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 15),),
          backgroundColor: Colors.white,
          // elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                Navigator.pop(context),
            color: Colors.black,
          ),
          // actions: <Widget>[
          // ]
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child:
            (!isLoading)
            ?
            Container(
              color: Colors.white,
              child:const Center(
                child: CircularProgressIndicator(),
              ),
            )
            :
            Column(
                children: [
                  SizedBox(
                      height: 115,
                      width: 115,
                      child: Stack(
                          fit: StackFit.expand,
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(mbData['mb_img']),
                              backgroundColor: Colors.transparent,
                            ),
                          ]
                      )
                  ),
                  const SizedBox(height: 15),
                  Text(mbData['mb_nick'], style: const TextStyle(fontSize: 14.0)),
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(40.0, 8.0, 40.0, 0.0),
                    child: Divider(
                      color: Color(0xff78909c),
                      height: 0.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        // padding: const EdgeInsets.only(top: 10, left: 0, right: 10, bottom: 10),
                        child: ElevatedButton.icon(
                          onPressed: (){
                            _showMyDialog(1);
                          },
                          icon: const Icon(Icons.dangerous),  //icon data for elevated button
                          label: Text(mbData['mb_block'] == "Y" ? "차단해제" : "차단하기",
                            style: const TextStyle(color: Colors.white, fontSize: 16.0), //label text
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: kColor, //background color
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),),
                      Container(
                        alignment: Alignment.center,
                        // padding: const EdgeInsets.only(top: 10, left: 0, right: 10, bottom: 10),
                        child: ElevatedButton.icon(
                          onPressed: (){
                            _showMyDialog(2);
                          },
                          icon: const Icon(Icons.safety_check_outlined),  //icon data for elevated button
                          label: Text(mbData['mb_singo'] == "Y" ? "신고해제" : "신고하기",
                            style: const TextStyle(color: Colors.white, fontSize: 16.0), //label text
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: kButtonColor, //background color
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
            )
        );
      }),
    );
  }


  // 이미지 삭제 경고창
  Future<void> _showMyDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if(index == 1 && mbData['mb_block'] == "Y")
                  Text('${mbData['mb_nick']}님을 차단해제하시겠습니까?')
                else if(index == 1 && mbData['mb_block'] == "N")
                  Text('${mbData['mb_nick']}님을 차단하시겠습니까?')
                else if(index == 2 && mbData['mb_singo'] == "Y")
                  Text('${mbData['mb_nick']}님을 신고해제하시겠습니까?')
                else if(index == 2 && mbData['mb_singo'] == "N")
                  Text('${mbData['mb_nick']}님을 신고하시겠습니까?')
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                update_singo(index);
                // print('이미지삭제');

                // Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> update_singo(int index) async {

    final parameters = {"jwt_token": jwtToken, "type": index.toString()};
    JsonApi.postApi("rest/singo/member/${mbData['mb_id']}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        if(kDebug)
        {
          debugPrint('data ${apiResponse.data}');
        }

        if(responseData['code'].toString() == "0") {
          if (responseData['message'] != '') {
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

          Navigator.pop(context, 'reload');
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
  void dispose() {
    super.dispose();
  }


}


