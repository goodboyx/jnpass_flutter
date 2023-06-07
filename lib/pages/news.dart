import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:jnpass/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/jsonapi.dart';
import '../common.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import '../models/boardcategory.dart';
import '../provider/notiEvent.dart';
import '../util.dart';
import '../widgets/sosAppBar.dart';
import '../models/boardmodel.dart';
import 'newsForm.dart';
import 'newsview.dart';

GetIt getIt = GetIt.instance;

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends State<NewsPage> {
  late SharedPreferences prefs;

  bool isLoading = false;
  int page = 1;
  int totalPage = 1;
  int limit = 15;
  List<BoardCategory> cateData = [];
  late String ca_name = "1";
  final ScrollController scBoard = ScrollController();
  final ScrollController scCate  = ScrollController();
  final ScrollController scrollController = ScrollController();

  NotiEvent notiEvent = NotiEvent();

  @override
  void initState() {

    SharedPreferences.getInstance().then((value) async {
      prefs = value;

      if(NewsBoardCategoryData.items.isEmpty)
      {
        dataBoardCate();
      }
      else
      {
        cateData = NewsBoardCategoryData.items;
        setState(() {

        });
      }
    });

    notiEvent.addListener(notiEventListener);
    NewsBoardData.items.clear();
    dataBoard(1, true);

    scBoard.addListener(() {
      if (scBoard.offset >= scBoard.position.maxScrollExtent && !scBoard.position.outOfRange) {
        // if (scBoard.position.pixels ==
        //     scBoard.position.maxScrollExtent) {

        debugPrint('$totalPage : $page ');

        setState(() {
          if (isLoading) {
            // 화면 끝에 닿았을 때 이루어질 동작
            page = page + 1;

            if(totalPage < totalPage) {
              page = totalPage;
            }
            else
            {
              dataBoard(page, false);
            }
          }

        });

      }
    });

    super.initState();
  }

  void notiEventListener() {
    // Current class name print
    debugPrint('notiEventListener ${notiEvent.msg}');
    dataBoard(1, true);
  }

  Future<void> dataBoardCate() async {

    setState(() {
      isLoading = false;
    });

    final parameters = {"": ""};
    JsonApi.getApi("rest/board_cate/news", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());

        if(kDebug)
        {
          debugPrint('data ${apiResponse.data}');
        }

        if(List.from(responseData['items']).toList().isNotEmpty)
        {
          NewsBoardCategoryData.items = List.from(responseData['items'])
              .map<BoardCategory>((item) => BoardCategory.fromJson(item))
              .toList();

          if(mounted)
          {
            setState(() {
              cateData = NewsBoardCategoryData.items;
            });
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

  Future<void> dataBoard(int page, bool init) async {
    setState(() {
      isLoading = false;
    });

    final parameters = {"page": page.toString(), "ca_name" : ca_name, "limit": limit.toString(), "jwt_token":jwtToken, "area" : meLoc};
    JsonApi.getApi("rest/news", parameters).then((value) {
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
              NewsBoardData.items = List.from(responseData['items'])
                  .map<BoardModel>((item) => BoardModel.fromJson(item))
                  .toList();
            }
            else {
              NewsBoardData.items += List.from(responseData['items'])
                  .map<BoardModel>((item) => BoardModel.fromJson(item))
                  .toList();
            }

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
            setState(() {
              isLoading = true;
            });
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
    // var _crossAxisCount = ((_screenWidth - 32) / 160).floor(); //컬럼 갯수
    var crossAxisCount = 1; //컬럼 갯수
    var crossAxisSpacing = 8;
    var width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
        crossAxisCount;
    var cellHeight = 100;
    var aspectRatio = width / cellHeight;
    var mainHeight = screenHeight - 200;

    if(Platform.isIOS){
      cellHeight = 290;
      mainHeight = screenHeight - 270;
    }

    return Scaffold(
      appBar: const SosAppBar(),
      body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: <Widget>[
              Container(
                height: 70,
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                color: const Color(0xFFEEEEEE),
                child :CustomScrollView(
                  controller: scCate,
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 70.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            BoardCategory category = cateData[index];
                            return GestureDetector(
                                onTap: () {
                                  if(category.id != ca_name)
                                  {
                                    setState(() {
                                      ca_name = category.id;
                                      debugPrint('카테고리클릭 : $ca_name');
                                    });

                                    // NewsBoardData.items.clear();

                                    dataBoard(1, true);
                                  }
                                },
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip
                                      .antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius
                                        .circular(10),
                                  ),
                                  color:
                                  (category.id == "9")
                                      ? Colors.orange
                                      :
                                  (category.id == ca_name)
                                      ? const Color(0xFFA586BC)
                                      :
                                  const Color(0xFFCCCCCC),
                                  elevation: 0.0,
                                  // 그림자 효과
                                  margin: const EdgeInsets.only(
                                      top: 20,
                                      bottom: 20,
                                      left: 15),
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets
                                            .only(left: 10.0,
                                            right: 10.0,
                                            top: 6.0,
                                            bottom: 6.0),
                                        child: Text(
                                            category.name,
                                            style: const TextStyle(
                                                color: Color(
                                                    0xFFFFFFFF), fontSize: 12)),
                                      ),
                                    ),
                                  ),
                                )
                            );
                          },
                          itemCount: cateData.length,
                        )
                      ),
                    ),
                  ]),
              ),
              // Container(
              //   height: 50,
              //   color: Colors.white,
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: cateData.length,
              //     itemBuilder: (context, index) {
              //       return GestureDetector(
              //         onTap: () {
              //           setState(() {
              //             BoardCategory category = cateData[index];
              //             dataBoard(1, true);
              //           });
              //         },
              //         child: Container(
              //           padding: const EdgeInsets.only(left: 10, right: 10),
              //           child: Text(cateData[index].id,
              //               style: TextStyle(
              //                   color: ca_name == cateData[index].name ? Colors.red : Colors.black,
              //                   fontSize: 15,
              //                   fontWeight: FontWeight.bold)),
              //         ),
              //       );
              //     },
              //   ),
              // ),

              (NewsBoardData.items.length.toString() == "0" && isLoading == true)
              ?
              Container(
                color: const Color(0XFFFFFFFF),
                height: mainHeight,
                child: const Center(
                  child: Text("등록된 게시물이 없습니다. ",
                  style: TextStyle(color: Colors.black, height: 1, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              )
              :
              SingleChildScrollView(
                scrollDirection:Axis.vertical,
                child: Container(
                    height: mainHeight,
                    color: Colors.white,
                    child: GridView.builder(
                        shrinkWrap: false,
                        controller: scBoard,
                        itemCount: NewsBoardData.items.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio),
                          itemBuilder: (context, index) {
                          return Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(0),
                              // ),
                              elevation: 1,
                              margin: const EdgeInsets.only(left: 0, top: 5, right:0, bottom: 10),
                              // TODO: Adjust card heights (123)
                              child: Column(
                                // TODO: Center items on the card (123)
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 16.0, 0.0),
                                        child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context,rootNavigator: true).push(
                                                  MaterialPageRoute(builder: (context) =>
                                                      NewsView(wrId:NewsBoardData.items[index].wr_id))).then((value) {
                                                        // debugPrint("value : $value");

                                                        if(value == "reload")
                                                        {
                                                          dataBoard(1, true);
                                                        }
                                                        else if(value == "login")
                                                        {
                                                            Navigator.of(context,rootNavigator: true).push(
                                                              MaterialPageRoute(builder: (context) =>
                                                              const LoginPage()),).then((value){

                                                            });
                                                        }

                                                        setState(() {
                                                      //     debugPrint("BoardData.items[index].wr_is_like : ${BoardData.items[index].wr_is_like}");
                                                        });
                                                });
                                            },
                                            child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                // TODO: Change innermost Column (123)
                                                children: <Widget>[
                                                  SizedBox (
                                                      width: screenWidth - 160,
                                                      child: Column(
                                                          children: <Widget>[
                                                            Align(alignment: Alignment.topLeft,
                                                              child: RichText(
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                                text: TextSpan(
                                                                  text: NewsBoardData.items[index].wr_subject,
                                                                  style: const TextStyle(
                                                                      color: Colors.black,
                                                                      height: 1.4,
                                                                      fontSize: 16.0,)),
                                                              )
                                                            ),
                                                            const SizedBox(height: 5,),
                                                            Align(alignment: Alignment.topLeft,
                                                                child: Text(NewsBoardData.items[index].wr_date, style: const TextStyle(color: Color(0xFF8E8E8E), fontSize: 13),)
                                                            ),
                                                            const SizedBox(height: 5,),
                                                            Align(alignment: Alignment.topLeft,
                                                                child: RichText(
                                                                  text: TextSpan(
                                                                    children: [
                                                                      const WidgetSpan(
                                                                        child: Icon(Icons.favorite, size: 14, color: Color(0xFF8E8E8E),),
                                                                      ),
                                                                      const TextSpan(
                                                                        text: "  ",
                                                                        style: TextStyle(
                                                                          color: Color(0xFF8CC152),
                                                                          fontSize: 14.0,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text: NewsBoardData.items[index].wr_like.toString(),
                                                                        style: const TextStyle(
                                                                          color: Color(0xFF8CC152),
                                                                          fontSize: 12.0,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const TextSpan(
                                                                        text: "    ",
                                                                        style: TextStyle(
                                                                          color: Color(0xFF8CC152),
                                                                          fontSize: 14.0,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const WidgetSpan(
                                                                        child: Icon(Icons.comment, size: 14, color: Color(0xFF8E8E8E)),
                                                                      ),
                                                                      const TextSpan(
                                                                        text: "  ",
                                                                        style: TextStyle(
                                                                          color: Color(0xFF8CC152),
                                                                          fontSize: 12.0,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text: NewsBoardData.items[index].wr_comment.toString(),
                                                                        style: const TextStyle(
                                                                          color: Color(0xFF8CC152),
                                                                          fontSize: 12.0,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),

                                                                    ],
                                                                  ),
                                                                )
                                                            ),
                                                          ]
                                                      )
                                                  ),
                                                  if(NewsBoardData.items[index].thum != "")
                                                    Flexible(
                                                        child:
                                                        Align(alignment: Alignment.topRight,
                                                            child: Container (
                                                                width: 100,
                                                                padding: const EdgeInsets.only(left:10.0),
                                                                child:Image.network(NewsBoardData.items[index].thum, fit:BoxFit.fitHeight, width: screenWidth))
                                                        ))

                                                ]
                                            )
                                        )
                                    )
                                  ]
                              )
                          );
                        }
                    )
                ),

              ),
            ]
          )
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          (jwtToken != null && jwtToken.isNotEmpty)
          ?
          FloatingActionButton(
            heroTag: "btn1",
            backgroundColor: const Color(0xFFa586bc),
            child: const Icon(Icons.add),
            onPressed: () {

              if(meLoc == "0")
              {
                Fluttertoast.showToast(
                    msg: "지역을 선택해주세요. " ,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 13.0
                );
              }
              else
              {
                Navigator.of(context,rootNavigator: true).push(
                  MaterialPageRoute(builder: (context) =>
                      NewsForm(wrId: '',)),
                ).then((value) async {
                  if(value != null)
                  {
                    debugPrint('작성 후 새로고침');
                    dataBoard(1, true);
                  }
                });
              }

            },
          )
          :
          const SizedBox(),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "kakao_btn",
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/images/kakaotalk.png", fit:BoxFit.fitWidth),
            onPressed: () {
              Util.launchKaKaoChannel();
            },
          ),

        ]
      )
    );
  }

  @override
  void dispose() {
    scCate.dispose();
    scBoard.dispose();
    notiEvent.removeListener(notiEventListener);

    super.dispose();
  }

}
