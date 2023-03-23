import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

bool _initialized = false;

// ignore: must_be_immutable
class NoticeView extends StatefulWidget {
  String wrId;

  NoticeView(
      {Key? key, required this.wrId})
      : super(key: key);

  @override
  NoticeViewState createState() => NoticeViewState();
}

class NoticeViewState extends State<NoticeView> {
  // late Member mb;
  // late String mbId;
  // late SharedPreferences prefs;
  String wrSubject = "";
  String wrContent = "";
  String wrDate = "";

  @override
  void initState () {

    if(widget.wrId != "")
    {
      getBoardData();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

      return Scaffold(
        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.
        body: Builder(builder: (BuildContext context) {
          // Size size = MediaQuery.of(context).size;
          return Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    title: const Text("알림", textAlign: TextAlign.left,
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
                resizeToAvoidBottomInset: false, //정의된 스크린 키보드에 의해 스스로 크기를 재조정
                body:
                (!_initialized)
                ?
                Container(
                  color: Colors.white,
                  child:const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                :
                SafeArea(
                  child: GestureDetector(
                    // behavior: HitTestBehavior.opaque,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.only(left: 15.0,
                                        bottom: 0.0,
                                        top: 25.0,
                                        right: 15.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        wrDate, textAlign: TextAlign.right,
                                        style: const TextStyle(color: Colors.black,
                                            fontSize: 13),),
                                    )
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 15.0,
                                      bottom: 15.0,
                                      top: 5.0,
                                      right: 15.0),
                                  child: Text(
                                    wrSubject, textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),),

                                ),
                                const Divider(thickness: 1, color: Colors.grey,),
                              ]
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 15.0, bottom: 15.0, top: 0, right: 15.0),
                            // Text('Gender:'),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding: const EdgeInsets.all(10),
                              ),
                              child:
                              (wrContent.isNotEmpty)
                              ?
                              Html(
                                  data:wrContent,
                                  style: {
                                    // tables will have the below background color
                                    "body": Style(
                                      color: const Color(0XFF727272),
                                      fontSize: FontSize(14.0),
                                      lineHeight: const LineHeight(0.8),
                                    ),
                                    "div": Style(
                                      lineHeight: const LineHeight(0.8),
                                      // margin: EdgeInsets.all(16),
                                      // border: Border.all(width: 6),
                                      // backgroundColor: Colors.grey,
                                    ),
                                    "span": Style(
                                      lineHeight: const LineHeight(0.8),
                                    ),
                                    "a": Style(
                                      lineHeight: const LineHeight(0.8),
                                    ),
                                    "p": Style(
                                      lineHeight: const LineHeight(1.2),
                                    ),
                                    "br": Style(
                                      lineHeight: const LineHeight(0.8),
                                    ),
                                  },
                                  onLinkTap: (url, _, __, ___) {
                                    debugPrint("Opening $url...");
                                    launchUrl(Uri.parse(url!));
                                  },
                              )
                              :
                              Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          );
        }),
      );
  }

  // 게시물 상세 정보 가져오기
  Future<void> getBoardData() async {

    Uri url = Uri.parse('${appApiUrl}app_board_data.php?bo_table=notice&wr_id=${widget.wrId}&r=${Random.secure().nextInt(10000).toString()}');

    // debugPrint('${appApiUrl}app_board_data.php?bo_table=notice&wr_id=${widget.wrId}');

    var response = await http.get(url);
    var responseBody = response.body;
    final responseData = json.decode(responseBody); // json 응답 값을 decode

    Future.delayed(const Duration(milliseconds: 1000), () {
      if(mounted) {
        setState(() {
          wrSubject = responseData[0]['wr_subject'];
          wrContent = responseData[0]['wr_content'];

          debugPrint(wrContent);
          wrDate = responseData[0]['wr_datetime'].substring(0, 10);

          _initialized = true;
        });
      }

    });

  }
}