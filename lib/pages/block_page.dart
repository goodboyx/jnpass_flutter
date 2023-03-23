import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/apiError.dart';
import '../models/apiResponse.dart';
import '../models/blockuser.dart';
import '../models/member.dart';
import '../util.dart';
import 'login_page.dart';

class BlockPage extends StatefulWidget {

  const BlockPage( {Key? key}) : super(key: key);

  @override
  BlockPageState createState() => BlockPageState();
}

class BlockPageState extends State<BlockPage> {
  late SharedPreferences prefs;

  @override
  void initState () {
    SharedPreferences.getInstance().then((value) async {
      prefs = value;

    });

    super.initState();
  }


  Future<void> reloadData() async {

    ApiResponse apiResponse = ApiResponse();

    dataLoad(1, true).then((value) {
      apiResponse = value;
      if((apiResponse.apiError).error == "9")
      {

      }
      else
      {
        Fluttertoast.showToast(
            msg: (apiResponse.apiError).msg,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 13.0
        );
      }

    });
  }


  Future<ApiResponse> dataLoad(int page, bool init) async {
    ApiResponse apiResponse = ApiResponse();

    BlockUserData.items.clear();

    try {
      Uri url = Uri.parse(
          '${appApiUrl}app_block_user.php?app_token=$token&r=${Random.secure()
              .nextInt(10000)
              .toString()}');
      final response = await http.get(url);

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;

          final responseData = json.decode(responseBody);
          debugPrint('responseBody : $responseBody');

          apiResponse.apiError = ApiError("9", "");

          setState(() {
            BlockUserData.items = List.from(responseData)
                .map<BlockUser>((item) => BlockUser.fromJson(item))
                .toList();
          });

        break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
        break;
        default:
          apiResponse.apiError = ApiError("1", "http 상태 에러");
        break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "app_block_user.php socket error");
    }

    return apiResponse;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Builder(builder: (BuildContext context) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                  appBar: AppBar(
                      centerTitle: true,
                      title: const Text("차단사용자목록", textAlign: TextAlign.center,
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
                  resizeToAvoidBottomInset: false,  //정의된 스크린 키보드에 의해 스스로 크기를 재조정
                  body: ListView.builder(
                    itemCount: BlockUserData.items.length,
                    itemBuilder: (context, index) {

                      if(BlockUserData.items.isEmpty)
                      {
                        return const Card(
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: ListTile(
                                  title: Text('데이타가 존재하지 않습니다.', maxLines: 2,),
                                  trailing: Icon(FontAwesomeIcons.trash, size: 20,),
                                )
                            )
                        );
                      }
                      else
                      {
                        return Card(
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ListTile(
                                  title: Text('${BlockUserData.items[index].mb_nick} (${BlockUserData.items[index].mb_id})', maxLines: 2,),
                                  trailing: const Icon(FontAwesomeIcons.trash, size: 20,),
                                  onTap: (){
                                    _showDialog(BlockUserData.items[index].mb_id);
                                  },
                                )
                            )
                        );
                      }

                    },
                  )

              )
          );

        })
    );
  }

  // 이미지 삭제 경고창
  Future<void> _showDialog(String blMbId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Text('차단목록를 삭제하시겠습니까?'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {

                // 푸쉬 회원아이디 업데이트
                postRequest() async {
                  String url = '${appApiUrl}app_block_delete.php';
                  Codec<String, String> stringToBase64 = utf8.fuse(base64);

                  http.Response response = await http.post(
                    Uri.parse(url),
                    headers: <String, String> {
                      'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: <String, String> {
                      'at_token': prefs.getString('at_token').toString(),
                      // 'mb_id': mbId,
                      'bl_mb_id': stringToBase64.encode(blMbId),
                    },
                  );

                  var responseBody = response.body;
                  final responseData = json.decode(responseBody);

                  if(responseData['result'] == "ok")
                  {
                    Fluttertoast.showToast(
                        msg: "삭제되었습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.orange,
                        textColor: Colors.white,
                        fontSize: 13.0
                    );

                    reloadData();
                  }
                  else
                  {

                  }
                }

                postRequest();

                Navigator.of(context).pop();


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


  @override
  void dispose() {
    super.dispose();
  }

}