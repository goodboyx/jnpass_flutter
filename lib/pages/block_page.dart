import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/jsonapi.dart';
import '../common.dart';
import '../models/apiResponse.dart';
import '../models/blockuser.dart';

class BlockPage extends StatefulWidget {

  const BlockPage( {Key? key}) : super(key: key);

  @override
  BlockPageState createState() => BlockPageState();
}

class BlockPageState extends State<BlockPage> {
  late SharedPreferences prefs;
  int page = 1;
  int limit = 15;
  bool isLoading = false;
  bool init = true;

  @override
  void initState () {
    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      dataLoad(1, true);
    });

    super.initState();
  }

  Future<void> dataLoad(int page, bool init) async {
    BlockUserData.items.clear();

    final parameters = {"jwt_token": jwtToken, "page": page.toString(), "limit": limit.toString()};
    JsonApi.getApi("rest/block_user", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data} ${responseData['code']}');

        if(responseData['code'].toString() == "0")
        {
          if (init == true) {
            BlockUserData.items = List.from(responseData['items'])
                .map<BlockUser>((item) => BlockUser.fromJson(item))
                .toList();
          }
          else {
            BlockUserData.items += List.from(responseData['items'])
                .map<BlockUser>((item) => BlockUser.fromJson(item))
                .toList();
          }

          setState(() {
            isLoading = true;
          });

        }
        else
        {
          prefs.remove('jwt_token');

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


  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
      body:
        (BlockUserData.items.length.toString() == "0" && isLoading == true)
        ?
        const Center(
          child: Text('데이타가 존재하지 않습니다.', maxLines: 2,),
        )
        :
        ListView.builder(
        itemCount: BlockUserData.items.length,
        itemBuilder: (context, index) {
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
      )
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

                final parameters = {"jwt_token": jwtToken};
                JsonApi.postApi("rest/delete/block_user/$blMbId", parameters).then((value) {
                  ApiResponse apiResponse = ApiResponse();

                  apiResponse = value;

                  if((apiResponse.apiError).error == "9") {

                    final responseData = json.decode(apiResponse.data.toString());
                    debugPrint('data ${apiResponse.data} ${responseData['code']}');

                    if(responseData['code'].toString() == "0")
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

                      dataLoad(1, true);

                      Navigator.of(context).pop();
                    }
                    else
                    {
                      prefs.remove('jwt_token');

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