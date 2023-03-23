import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jnpass/models/boardcategory.dart';
import 'package:jnpass/pages/shareview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/jsonapi.dart';
import '../constants.dart';
import '../models/apiError.dart';
import '../models/apiResponse.dart';
import '../models/boardmodel.dart';
import '../models/member.dart';
import '../util.dart';
import '../widgets/sosAppBar.dart';
import 'donationview.dart';
import 'login_page.dart';


class DonationPage extends StatefulWidget {

  const DonationPage({Key? key}) : super(key: key);

  @override
  DonationPageState createState() => DonationPageState();
}

class DonationPageState extends State<DonationPage> {
  bool _initialized = false;
  late Member mb;
  late String mbId;
  late String selected = "0";
  late SharedPreferences prefs;
  late List<BoardCategory> cateData;
  final ScrollController scCate  = ScrollController();
  final ScrollController scBoard = ScrollController();

  bool isLoading = false;
  int pageCount = 1;
  int totalPage = 1; // 전체 페이지수
  int pageRows = 10;

  @override
  void initState() {

    // 스크롤 컨트롤러에 리스너 부여
    scBoard.addListener(() {
      if (scBoard.offset >= scBoard.position.maxScrollExtent && !scBoard.position.outOfRange) {
        // if (scBoard.position.pixels ==
        //     scBoard.position.maxScrollExtent) {

        debugPrint('$totalPage : $pageCount ');

        setState(() {
          if(totalPage > pageCount) {
            isLoading = true;
          }
          else
          {
            isLoading = false;
          }

          if (isLoading) {
            // 화면 끝에 닿았을 때 이루어질 동작
            pageCount = pageCount + 1;

            if(totalPage < pageCount) {
              pageCount = totalPage;
            }
            else
            {
              dataBoard(pageCount, false);
            }

          }
        });

      }
    });

    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      mbId  = prefs.getString('mb_id') ?? '';

      if(mbId.isEmpty)
      {
        loginCheck(mbId);
      }
      else
      {
        reloadData();
      }
    });

    super.initState();
  }

  Future<void> loginCheck(mbId) async {

    ApiResponse apiResponse = ApiResponse();

    Util.loginCheck(mbId).then((value) {
      apiResponse = value;

      if((apiResponse.apiError).error == "9")
      {
        debugPrint('login ok');
        mb = apiResponse.data as Member ;

        reloadData();
      }
      else
      {
        debugPrint('loginPage');

        prefs.setString('mb_id', '');
        Navigator.of(context,rootNavigator: true).push(
          MaterialPageRoute(builder: (context) =>
          const LoginPage()),).then((value){

          if(value == "ok") {
            prefs.reload();
            mbId  = prefs.getString('mb_id') ?? '';
            loginCheck(mbId);
          }
        });
      }
    });
  }

  void reloadData() {

    // 게시판 가져오기
    // JsonApi.getBoardCate("donate", mbId).then((value) {
    //   ApiResponse apiResponse = ApiResponse();
    //
    //   apiResponse = value;
    //
    //   if((apiResponse.apiError).error == "9") {
    //
    //     BoardCategoryData.items = List.from((apiResponse.data as List)).map<BoardCategory>((item) => BoardCategory.fromJson(item)).toList();
    //
    //     dataBoard(1, true).then((value){
    //       if(mounted) {
    //         setState(() {
    //           cateData = BoardCategoryData.items;
    //
    //           if (cateData.isNotEmpty) {
    //             _initialized = true;
    //           }
    //         });
    //       }
    //     });
    //
    //   }
    //   else
    //   {
    //     Fluttertoast.showToast(
    //         msg: (apiResponse.apiError).msg ,
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.BOTTOM,
    //         timeInSecForIosWeb: 1,
    //         backgroundColor: Colors.red,
    //         textColor: Colors.white,
    //         fontSize: 13.0
    //     );
    //
    //   }
    // });
  }

  Future<void> dataBoard(int page, bool init) async {

    ApiResponse apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse(
          '${appApiUrl}app_board_donation.php?app_token$token&sca=$selected&page=${page.toString()}&r=${Random.secure()
              .nextInt(10000)
              .toString()}');
      final response = await http.get(url);

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;

          final responseData = json.decode(responseBody);
          // debugPrint('responseBody : $responseBody');

          if(mounted) {
            setState(() {
              if (init == true) {
                BoardData.items =
                    List.from(responseData).map<BoardModel>((item) =>
                        BoardModel.fromJson(item)).toList();
              }
              else {
                BoardData.items +=
                    List.from(responseData).map<BoardModel>((item) =>
                        BoardModel.fromJson(item)).toList();
              }

              debugPrint("기부 : ${BoardData.items.length}");

              if (BoardData.items.isNotEmpty) {
                totalPage = BoardData.items[0].total_page;
              }

              isLoading = false;
            });
          }
          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          break;
        default:
          apiResponse.apiError = ApiError("1", "http 상태 에러");
          break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "app_board_donation.php socket error");
    }
  }


  @override Widget build(BuildContext context) {

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // var _crossAxisCount = ((_screenWidth - 32) / 160).floor(); //컬럼 갯수
    var crossAxisCount = 2; //컬럼 갯수
    var crossAxisSpacing = 8;
    var width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
        crossAxisCount;
    var cellHeight = 207;
    var aspectRatio = width / cellHeight;
    // _selected = "0";
    var mainHeight = screenHeight - 220;

    if(Platform.isIOS){
      mainHeight = screenHeight - 270;
    }

    return  WillPopScope(
        onWillPop: () async {
      debugPrint('donation pop');
      return true;
    },
    child: Scaffold(
        appBar: SosAppBar(),
        body:
        (!_initialized) ?
        Container(
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        )
            :
        Column(
            children: <Widget>[
              Expanded(
                  child: CustomScrollView(
                      controller: scCate,
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 70.0,
                            child: Container(
                                color: const Color(0xFFEEEEEE),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    BoardCategory category = cateData[index];
                                    return GestureDetector(
                                        onTap: () {
                                          if(selected != category.id)
                                          {
                                            setState(() {
                                              selected = category.id;
                                              debugPrint('카테고리 클릭 $selected');
                                            });
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
                                          (category.id == selected)
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
                            )
                          ),
                        ),
                      ])
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: mainHeight,
                      color: Colors.transparent,
                      child:
                      (BoardData.items.isEmpty)
                          ?
                      Container(
                        color: const Color(0XFFFFFFFF),
                        child: const Center(
                          child: Text("등록된 자료가 없습니다.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      )
                          :
                      GridView.builder(
                          physics: const ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: BoardData.items.length,
                          controller: scBoard,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: aspectRatio
                          ),
                          itemBuilder: (context, index) {
                            return Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                              margin: const EdgeInsets.all(5),
                              // TODO: Adjust card heights (123)
                              child: Column(
                                // TODO: Center items on the card (123)
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            // TODO: Change innermost Column (123)
                                            children: <Widget>[
                                              AspectRatio(
                                                aspectRatio: 18 / 11,
                                                child: GestureDetector(
                                                    child: Image.network(BoardData.items[index].thum, fit:BoxFit.cover, width: 900),
                                                    onTap: () {
                                                      /*
                                                      if(BoardData.items[index].bo_table == "donate")
                                                      {
                                                        debugPrint("BoardData.items[index].wr_is_like : ${BoardData.items[index].wr_is_like}");

                                                        Navigator.of(context,rootNavigator: true).push(
                                                            MaterialPageRoute(builder: (context) =>
                                                                DonationView(boTable:'donate', wrId:BoardData.items[index].wr_id, like:BoardData.items[index].wr_is_like.toString(), share:'1',))).then((value) async {

                                                          if(value != null)
                                                          {
                                                            var split = value.split("@@");
                                                            BoardData.items[index].wr_is_like = int.parse(split[2]);
                                                          }

                                                          Uri url = Uri.parse('${appApiUrl}app_count_like_comment.php');
                                                          var request = http.MultipartRequest('POST', url);
                                                          // request.headers.content

                                                          request.fields["token"]    = token;
                                                          request.fields["mb_id"]    = mbId;
                                                          request.fields["bo_table"] = BoardData.items[index].bo_table;
                                                          request.fields["wr_id"]    = BoardData.items[index].wr_id;

                                                          var res = await request.send();

                                                          if (res.statusCode == 200) {
                                                            var response = await http.Response.fromStream(res);
                                                            final responseData = json.decode(response.body); // json 응답 값을 decode

                                                            debugPrint('index : $index : $responseData');

                                                            BoardData.items[index].wr_like    = int.parse(responseData['wr_good_cnt']);
                                                            BoardData.items[index].wr_comment = responseData['wr_comment_cnt'];
                                                          }

                                                          setState(() {

                                                          });

                                                        });

                                                      }
                                                      else
                                                      {
                                                        Navigator.of(context,rootNavigator: true).push(
                                                            MaterialPageRoute(builder: (context) =>
                                                                ShareView(boTable:'share',
                                                                  wrId:BoardData.items[index].wr_id,
                                                                  like:BoardData.items[index].wr_is_like.toString(),
                                                                  share:'1',)))
                                                            .then((value) async {

                                                          if(value != null)
                                                          {
                                                            var split = value.split("@@");
                                                            debugPrint(split[2]);

                                                            BoardData.items[index].wr_is_like = int.parse(split[2]);
                                                            debugPrint("BoardData.items[index].wr_is_like : ${BoardData.items[index].wr_is_like}");
                                                          }

                                                          setState(() {

                                                          });

                                                        });
                                                      }
                                                      */
                                                    }
                                                ),

                                              ),
                                            ]

                                        )
                                    ),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                                                  child: Column(
                                                    // TODO: Align labels to the bottom and center (123)
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      // TODO: Change innermost Column (123)
                                                      children: <Widget>[
                                                        Text(BoardData.items[index].ca_name_text, textAlign: TextAlign.left, style: const TextStyle(color: Color(0xFF4A89DC), fontSize:12)),
                                                        const SizedBox(height: 5),
                                                        Text(BoardData.items[index].wr_content, textAlign: TextAlign.left, maxLines:2, style: const TextStyle(color: kPrimaryColor, fontSize:13, fontWeight: FontWeight.bold)),
                                                      ]
                                                  )
                                              ),
                                              Container(
                                                height: 30,
                                                padding: const EdgeInsets.only(top: 10, bottom:5),
                                                margin: const EdgeInsets.symmetric(vertical:0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                const WidgetSpan(
                                                                  child: FaIcon(FontAwesomeIcons.heart, size: 14),
                                                                ),
                                                                const TextSpan(
                                                                  text: "   ",
                                                                  style: TextStyle(
                                                                    color: Color(0xFF8CC152),
                                                                    fontSize: 12.0,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: BoardData.items[index].wr_like.toString(),
                                                                  style: const TextStyle(
                                                                    color: Color(0xFF8CC152),
                                                                    fontSize: 12.0,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const VerticalDivider(
                                                      width: 0,
                                                      thickness: 1,
                                                      indent: 0,
                                                      endIndent: 0,
                                                      color: Colors.grey,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                const WidgetSpan(
                                                                  child: FaIcon(FontAwesomeIcons.comment, size: 14),
                                                                ),
                                                                const TextSpan(
                                                                  text: "   ",
                                                                  style: TextStyle(
                                                                    color: Color(0xFF8CC152),
                                                                    fontSize: 12.0,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: BoardData.items[index].wr_comment.toString(),
                                                                  style: const TextStyle(
                                                                    color: Color(0xFF8CC152),
                                                                    fontSize: 12.0,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ]
                                        )
                                    )

                                  ]
                              ),
                            );
                          }
                        // scrollDirection: Axis.horizontal,
                      ),
                    ),

                  (isLoading == true)
                      ?
                  const Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 20.0),
                      child: Center(child: RefreshProgressIndicator()),)
                    :
                  Container()

                  ]
                )

              ),

            ]
        )
      )
    );

  }

  @override
  void dispose() {
    scCate.dispose();
    scBoard.dispose();

    super.dispose();
  }

}
