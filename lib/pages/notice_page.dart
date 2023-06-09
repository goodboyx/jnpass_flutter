import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jnpass/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/jsonapi.dart';
import '../models/apiResponse.dart';
import '../models/boardcategory.dart';
import '../models/boardmodel.dart';
import '../util.dart';
import '../widgets/sosAppBar.dart';
import 'login_page.dart';
import 'noticeview.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  NoticePageState createState() => NoticePageState();
}

class NoticePageState extends State<NoticePage> {
  late final prefs;
  String jwtToken = '';

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

    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      jwtToken = prefs.getString('jwt_token') ?? "";

      // dataBoardCate();
    });

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

    final parameters = {"page": page.toString(), "limit": limit.toString(), "jwt_token":jwtToken};

    debugPrint(parameters.toString());

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
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const SosAppBar(),
      body:
        // (cateData.isEmpty)
        // ?
        // Container(
        //   color: Colors.white,
        //   child: const Center(
        //     child: CircularProgressIndicator(),
        //   ),
        // )
        // :
        ListView.builder(
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
                                                              height: 1.4,
                                                              fontSize: 16.0,
                                                              fontFamily: 'NanumSquareRegular')),
                                                    )
                                                ),
                                                const SizedBox(height: 5,),
                                                Align(alignment: Alignment.topLeft,
                                                    child: Text(NoticeBoardData.items[index].wr_date)
                                                ),
                                                const SizedBox(height: 5,),
                                                // Align(alignment: Alignment.topLeft,
                                                //     child: RichText(
                                                //       text: TextSpan(
                                                //         children: [
                                                //           const WidgetSpan(
                                                //             child: Icon(Icons.favorite, size: 14),
                                                //           ),
                                                //           const TextSpan(
                                                //             text: "  ",
                                                //             style: TextStyle(
                                                //               color: Color(0xFF8CC152),
                                                //               fontSize: 14.0,
                                                //               fontWeight: FontWeight.bold,
                                                //             ),
                                                //           ),
                                                //           TextSpan(
                                                //             text: NoticeBoardData.items[index].wr_like.toString(),
                                                //             style: const TextStyle(
                                                //               color: Color(0xFF8CC152),
                                                //               fontSize: 12.0,
                                                //               fontWeight: FontWeight.bold,
                                                //             ),
                                                //           ),
                                                //           const TextSpan(
                                                //             text: "    ",
                                                //             style: TextStyle(
                                                //               color: Color(0xFF8CC152),
                                                //               fontSize: 14.0,
                                                //               fontWeight: FontWeight.bold,
                                                //             ),
                                                //           ),
                                                //           const WidgetSpan(
                                                //             child: Icon(Icons.comment, size: 14),
                                                //           ),
                                                //           const TextSpan(
                                                //             text: "  ",
                                                //             style: TextStyle(
                                                //               color: Color(0xFF8CC152),
                                                //               fontSize: 12.0,
                                                //               fontWeight: FontWeight.bold,
                                                //             ),
                                                //           ),
                                                //           TextSpan(
                                                //             text: NoticeBoardData.items[index].wr_comment.toString(),
                                                //             style: const TextStyle(
                                                //               color: Color(0xFF8CC152),
                                                //               fontSize: 12.0,
                                                //               fontWeight: FontWeight.bold,
                                                //             ),
                                                //           ),
                                                //
                                                //         ],
                                                //       ),
                                                //     )
                                                // ),
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
                                      // AspectRatio(
                                      //   aspectRatio: 20 / 11,
                                      //   child: GestureDetector(
                                      //       child: Image.network(BoardData.items[index].thum, fit:BoxFit.fitWidth, width: screenWidth),
                                      //
                                      //   )
                                      // )
                                    ]
                                )
                            )
                        ),
                        const Divider(
                          thickness: 1,
                          color: Colors.grey,
                        )


                      ]
                  )
              );
            },
        ),
        // Column(
        //     children: <Widget>[
        //       // Expanded(
        //       //     child: CustomScrollView(
        //       //         controller: scCate,
        //       //         slivers: <Widget>[
        //       //           SliverToBoxAdapter(
        //       //             child: SizedBox(
        //       //               height: 70.0,
        //       //               child: Container(
        //       //                   color: const Color(0xFFEEEEEE),
        //       //                   child: ListView.builder(
        //       //                     scrollDirection: Axis.horizontal,
        //       //                     itemBuilder: (context, index) {
        //       //                       BoardCategory category = cateData[index];
        //       //                       return GestureDetector(
        //       //                           onTap: () {
        //       //                             if(selected != category.id)
        //       //                             {
        //       //                               setState(() {
        //       //                                 selected = category.id;
        //       //                                 debugPrint('카테고리 클릭 : $selected');
        //       //                               });
        //       //                               dataBoard(1, true);
        //       //                             }
        //       //                           },
        //       //                           child: Card(
        //       //                             semanticContainer: true,
        //       //                             clipBehavior: Clip
        //       //                                 .antiAliasWithSaveLayer,
        //       //                             shape: RoundedRectangleBorder(
        //       //                               borderRadius: BorderRadius
        //       //                                   .circular(10),
        //       //                             ),
        //       //                             color:
        //       //                             (category.id == "9")
        //       //                                 ? Colors.orange
        //       //                                 :
        //       //                             (category.id == selected)
        //       //                                 ? const Color(0xFFA586BC)
        //       //                                 :
        //       //                             const Color(0xFFCCCCCC),
        //       //                             elevation: 0.0,
        //       //                             // 그림자 효과
        //       //                             margin: const EdgeInsets.only(
        //       //                                 top: 20,
        //       //                                 bottom: 20,
        //       //                                 left: 15),
        //       //                             child: SizedBox(
        //       //                               height: double.infinity,
        //       //                               child: Center(
        //       //                                 child: Padding(
        //       //                                   padding: const EdgeInsets
        //       //                                       .only(left: 10.0,
        //       //                                       right: 10.0,
        //       //                                       top: 6.0,
        //       //                                       bottom: 6.0),
        //       //                                   child: Text(
        //       //                                       category.name,
        //       //                                       style: const TextStyle(
        //       //                                           color: Color(
        //       //                                               0xFFFFFFFF), fontSize: 12)),
        //       //                                 ),
        //       //                               ),
        //       //                             ),
        //       //                           )
        //       //                       );
        //       //                     },
        //       //                     itemCount: cateData.length,
        //       //                   )
        //       //               ),
        //       //             ),
        //       //           ),
        //       //         ])
        //       // ),
        //     ]
        // ),
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