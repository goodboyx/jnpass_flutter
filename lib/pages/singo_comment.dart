
// ignore_for_file: prefer_typing_uninitialized_variables, camel_case_types, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/jsonapi.dart';
import '../common.dart';
import '../models/apiResponse.dart';

class SingoComment extends StatefulWidget {
  String bo_table;
  String wr_id;
  String fs_id;
  String fs_message;

  SingoComment(
      {Key? key, required this.bo_table, required this.wr_id, required this.fs_id, required this.fs_message})
      : super(key: key);

  @override
  SingoCommentState createState() => SingoCommentState();
}

class SingoCommentState extends State<SingoComment> {
  late SharedPreferences prefs;
  final ScrollController scrollController = ScrollController();
  late dynamic mbData;
  late BuildContext _context;
  final TextEditingController _controller = TextEditingController();
  bool writeState = false;
  var currentSelectedValue;  // 카테고리 구분

  @override
  void initState () {
    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      jwtToken = prefs.getString('jwt_token') ?? "";

      if(jwtToken == "")
      {
        Navigator.pop(_context);
      }
      else
      {
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


    });

    super.initState ();
  }

  // 등록완료
  Future<void> uploadAction() async {
    if(currentSelectedValue == null)
    {
      ScaffoldMessenger.of(_context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("신고유형을 선택해주세요")));
    }

    setState(() {
      writeState = true;
    });

    final parameters = {"jwt_token":jwtToken, "ca_id":currentSelectedValue, "bs_reason" : await json.decode(json.encode(_controller.text)), "fs_content" : json.decode(json.encode(widget.fs_message))};

    JsonApi.postApi("rest/singo/${widget.bo_table}/${widget.wr_id}/${widget.fs_id}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data}');

        if(responseData['code'].toString() == "101")
        {
          prefs.remove('jwt_token');

          Navigator.pop(_context, widget.wr_id);

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

            Navigator.pop(_context, widget.fs_id);
          }
          else
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

            Navigator.pop(_context);
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
    _context = context;

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("신고", textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 15),),
            backgroundColor: Colors.white,
            // elevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () =>
                  Navigator.pop(context),
              color: Colors.black,
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 0, right: 10, bottom: 10),
                child: MaterialButton(
                  minWidth:50,
                  color: const Color(0xFF98BF54),
                  onPressed: () {
                    uploadAction();
                  },
                  child: Text((writeState == false) ? '등록' : '등록중', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                ),
              ),
            ]
        ),
        resizeToAvoidBottomInset: false,  //정의된 스크린 키보드에 의해 스스로 크기를 재조정
        body: SingleChildScrollView(
            controller: scrollController,
            child:SafeArea (
                child : GestureDetector(
                  // behavior: HitTestBehavior.opaque,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment : CrossAxisAlignment.start,
                            children: <Widget> [
                              Container(
                                  margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 20, right: 15.0),
                                  child: InputDecorator(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: currentSelectedValue,
                                          isDense: true,
                                          isExpanded: true,
                                          items: <String>['', '1', '2', '3', '4']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text({'1': '비방 게시물', '2': '광고 게시물', '3':'욕설 게시물', '4':'기타'}[value] ?? '신고유형'),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              currentSelectedValue = newValue!;
                                              // print(currentSelectedValue);
                                            });
                                          },
                                          hint: Text("신고유형"),
                                        ),
                                      )
                                  )
                              ),
                              Column(
                                crossAxisAlignment : CrossAxisAlignment.start,
                                children: <Widget> [
                                  Container(
                                    margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 0, right: 15.0),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                      child:
                                      TextField(
                                        controller: _controller,
                                        minLines: 6,
                                        maxLines: 8,
                                        keyboardType: TextInputType.multiline,
                                        decoration: InputDecoration.collapsed(hintText: "신고이유를 입력해주세요."),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                        )
                    )
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