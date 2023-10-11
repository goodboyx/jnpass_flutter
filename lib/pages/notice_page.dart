import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jnpass/constants.dart';

import '../api/jsonapi.dart';
import '../models/apiResponse.dart';
import '../models/boardcategory.dart';
import '../models/boardmodel.dart';
import '../util.dart';
import '../widgets/sosAppBar.dart';
import 'noticeview.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  NoticePageState createState() => NoticePageState();
}

class NoticePageState extends State<NoticePage> {
  bool isLoading = false;
  int page = 1;
  int totalPage = 1;
  int limit = 10;
  List<BoardCategory> cateData = [];
  late String selected = "0";
  final ScrollController scBoard = ScrollController();
  final ScrollController scCate  = ScrollController();

  @override
  void initState() {
    super.initState();

    NoticeBoardData.items.clear();
    dataBoard(1, true);

    // maxScrollExtent = 스크롤 맨 밑
    // minScrollExtent = 스크롤 맨 위
    // 화면 끝에 닿았을 때 이루어질 동작
    scBoard.addListener(() {
      if (scBoard.offset >= scBoard.position.maxScrollExtent && !scBoard.position.outOfRange) {

        setState(() {
          if (isLoading) {
            page = page + 1;

            if (totalPage < page) {
              page = totalPage;
            }
            else {
              dataBoard(page, false);
            }
          }
        });

      }
    });

  }

  Future<void> dataBoardCate() async {

    final parameters = {"": ""};
    JsonApi.getApi("rest/board_cate/notice", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());

        if(List.from(responseData['items']).toList().isNotEmpty)
        {
          NoticeBoardCategoryData.items = List.from(responseData['items'])
              .map<BoardCategory>((item) => BoardCategory.fromJson(item))
              .toList();

          setState(() {
            cateData = NoticeBoardCategoryData.items;
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


  Future<void> dataBoard(int page, bool init) async {

    final parameters = {"page": page.toString(), "limit": limit.toString(), "jwt_token":""};

    JsonApi.getApi("rest/board/notice", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());

        if(kDebug)
        {
          debugPrint('data ${apiResponse.data}');
        }

        if(responseData['code'].toString() == "0")
        {
          if(List.from(responseData['items']).toList().isNotEmpty)
          {

            if (init == true) {
              NoticeBoardData.items = List.from(responseData['items'])
                  .map<BoardModel>((item) => BoardModel.fromJson(item))
                  .toList();
            } else {
              NoticeBoardData.items += List.from(responseData['items'])
                  .map<BoardModel>((item) => BoardModel.fromJson(item))
                  .toList();
            }

            totalPage = int.parse(responseData['total_page'].toString());

            if(mounted)
            {
              setState(() {
                totalPage = responseData['total_page'];
                isLoading = true;
              });
            }
          }

          if(NewsBoardData.items.length.toString() == "0")
          {
            if(mounted)
            {
              setState(() {
                isLoading = true;
              });
            }

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
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const SosAppBar(),
      body: ListView.builder(
            itemCount: NoticeBoardData.items.length,
            controller: scBoard,
            itemBuilder: (context, index) {
              return Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                  margin: const EdgeInsets.only(left: 10, top: 0, right:10, bottom: 0),
                  // TODO: Adjust card heights (123)
                  child: Column(
                    // TODO: Center items on the card (123)
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 8.0),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context,rootNavigator: true).push(
                                      MaterialPageRoute(builder: (context) =>
                                          NoticeView(wrId:NoticeBoardData.items[index].wr_id)));
                                },
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    // TODO: Change innermost Column (123)
                                    children: <Widget>[
                                      SizedBox (
                                          width: (NoticeBoardData.items[index].thum != "") ? screenWidth - 120 : screenWidth - 20,
                                          child: Column(
                                              children: <Widget>[
                                                Align(alignment: Alignment.topLeft,
                                                    child: RichText(
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      text: TextSpan(
                                                          text: NoticeBoardData.items[index].wr_subject,
                                                          style: const TextStyle(
                                                            color: Colors.black,
                                                            fontFamily: 'SCDream',
                                                            fontWeight: FontWeight.bold,
                                                            height: 1.8,
                                                            fontSize: 14.0,)),
                                                    )
                                                ),
                                                const SizedBox(height: 10,),
                                                Align(alignment: Alignment.topLeft,
                                                    child: Text(NoticeBoardData.items[index].wr_date, style: const TextStyle(
                                                        color: Color(0xFFA5A5A5),
                                                        fontSize: 12.0,
                                                        fontFamily: 'SCDream'))
                                                ),
                                                const SizedBox(height: 5,),
                                              ]
                                          )
                                      ),
                                      if(NoticeBoardData.items[index].thum != "")
                                        Flexible(
                                            child:
                                            Align(alignment: Alignment.topRight,
                                                child: Container (
                                                    width: 100,
                                                    padding: const EdgeInsets.only(left:10.0),
                                                    child:Image.network(NoticeBoardData.items[index].thum, fit:BoxFit.fitHeight, width: screenWidth))
                                            )),
                                    ]
                                )
                            )
                        ),
                        const Divider(
                          thickness: 1,
                          color: Color(0xFFA5A5A5),
                        )


                      ]
                  )
              );
            },
        ),
      floatingActionButton: FloatingActionButton(
        heroTag: "kakao_btn",
        backgroundColor: Colors.transparent,
        child: Image.asset("assets/images/kakaotalk.png", fit:BoxFit.fitWidth),
        onPressed: () {
          Util.launchKaKaoChannel();
        },
      )
    );
  }
}