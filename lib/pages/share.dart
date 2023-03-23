import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:jnpass/pages/shareview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/jsonapi.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import '../models/boardcategory.dart';
import '../models/csmodel.dart';
import 'login_page.dart';

GetIt getIt = GetIt.instance;

class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  SharePageState createState() => SharePageState();
}

class SharePageState extends State<SharePage> {
  late SharedPreferences prefs;
  String jwtToken = '';
  bool isLoading = false;

  String selected = "0";

  List<BoardCategory> cateData = [];

  final ScrollController scCate  = ScrollController();
  final ScrollController scBoard = ScrollController();
  int pageCount = 1;
  int totalPage = 1;
  int limit = 8;

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
            // isLoading = false;
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
      jwtToken = prefs.getString('jwt_token') ?? "";

      dataBoardCate();
      dataBoard(1, true);
    });

    super.initState();
  }

  Future<void> dataBoardCate() async {

    final parameters = {"": ""};
    JsonApi.getApi("rest/board_cate/share", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data}');

        if(List.from(responseData['items']).toList().isNotEmpty)
        {
          BoardCategoryData.items = List.from(responseData['items'])
              .map<BoardCategory>((item) => BoardCategory.fromJson(item))
              .toList();

          setState(() {
            cateData = BoardCategoryData.items;
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
    JsonApi.getApi("rest/cs", parameters).then((value) {

      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;


      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data}');

        if(responseData['code'].toString() == "101")
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
        else if(responseData['code'].toString() == "0")
        {
          isLoading = true;

          if(List.from(responseData['items']).toList().isNotEmpty)
          {

            if (init == true) {
              CsData.items = List.from(responseData['items'])
                  .map<CsModel>((item) => CsModel.fromJson(item))
                  .toList();
            }
            else {
              CsData.items += List.from(responseData['items'])
                  .map<CsModel>((item) => CsModel.fromJson(item))
                  .toList();
            }

            totalPage = responseData['total_page'];
          }

          if(mounted)
          {
            setState(() {
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

  Color getColor(String state) {
    //red is just a sample color
    Color color;
    if(state == "" || state == "1") {
      color = const Color(0xFF52A4DA);
    } else if(state == "2") {
      color = const Color(0xFFE97031);
    } else if(state == "3") {
      color = const Color(0xFF98BF54);
    }
    else {
      color = const Color(0xFF52A4DA);
    }
    return color;
  }

  @override Widget build(BuildContext context) {

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // var _crossAxisCount = ((_screenWidth - 32) / 160).floor(); //컬럼 갯수
    var crossAxisCount = 2; //컬럼 갯수
    var crossAxisSpacing = 8;
    var width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
        crossAxisCount;
    var cellHeight = 208; // card  높이 조정
    var aspectRatio = width / cellHeight;

    var mainHeight = screenHeight - 85;

    if(Platform.isIOS){
      cellHeight = 290;
      mainHeight = screenHeight - 270;
    }

    return   WillPopScope(
        onWillPop: () async {
      debugPrint('donation pop');
      return true;
    },
    child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("상담내역", textAlign: TextAlign.center,
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
        body:
        (!isLoading) ?
        Container(
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        )
        :
        Column(
            children: <Widget>[
              // Expanded(
              //     child: CustomScrollView(
              //         controller: scCate,
              //         slivers: <Widget>[
              //           SliverToBoxAdapter(
              //             child: SizedBox(
              //               height: 70.0,
              //               child: Container(
              //                   color: const Color(0xFFEEEEEE),
              //                   child: ListView.builder(
              //                     scrollDirection: Axis.horizontal,
              //                     itemBuilder: (context, index) {
              //                         BoardCategory category = cateData[index];
              //                       return GestureDetector(
              //                           onTap: (){
              //                             if(selected != category.id)
              //                             {
              //                               setState(() {
              //                                 selected = category.id;
              //                                 debugPrint('카테고리 클릭 : $selected');
              //                               });
              //                               dataBoard(1, true).then((value) {
              //                                 setState(() {
              //
              //                                 });
              //                               });
              //                             }
              //                           },
              //                           child: Card(
              //                             semanticContainer: true,
              //                             clipBehavior: Clip.antiAliasWithSaveLayer,
              //                             shape: RoundedRectangleBorder(
              //                               borderRadius: BorderRadius.circular(10),
              //                             ),
              //                             color:
              //                             (category.id == "9") ? Colors.orange :
              //                             (category.id == selected) ? const Color(0xFFA586BC) :
              //                             const Color(0xFFCCCCCC),
              //                             elevation: 0.0, // 그림자 효과
              //                             margin: const EdgeInsets.only(top: 20, bottom: 20, left: 15),
              //                             child: SizedBox(
              //                               height: double.infinity,
              //                               child:
              //                               Center(
              //                                 child: Padding(
              //                                   padding: const EdgeInsets.only(left:10.0, right: 10.0, top: 6.0, bottom: 6.0),
              //                                   child: Text(category.name,
              //                                       style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12)),
              //                                 ),
              //                               ),
              //                             ),
              //                           )
              //                       );
              //                     },
              //                     itemCount: cateData.length,
              //                   )
              //               )
              //             ),
              //           ),
              //         ])
              // ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                child: Container(
                  height: mainHeight,
                  color: Colors.transparent,
                  child:
                  (CsData.items.isEmpty)
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
                      itemCount: CsData.items.length,
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
                                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        // TODO: Change innermost Column (123)
                                        children: <Widget>[
                                          AspectRatio(
                                            aspectRatio: 17 / 11,
                                            child: GestureDetector(
                                                child: Image.network(CsData.items[index].thum, fit:BoxFit.cover, width: screenWidth, height: 105,),
                                                onTap: () {

                                                    Navigator.of(context,rootNavigator: true).push(
                                                        MaterialPageRoute(builder: (context) =>
                                                            ShareView(wrId:CsData.items[index].wr_id)))
                                                        .then((value) async {

                                                      if(value != null)
                                                      {
                                                        // debugPrint('value : $value');
                                                        var split = value.split("@@");
                                                        debugPrint('split : $split');

                                                        setState(() {
                                                          CsData.items[index].wr_is_like = int.parse(split[2]);
                                                          // CsData.items[index].wr_6 = split[3];
                                                          // CsData.items[index].wr_7 = split[4];
                                                          debugPrint("CsData.items[index].wr_is_like : ${CsData.items[index].wr_is_like}");
                                                        });
                                                      }
                                                    });

                                                }
                                            ),

                                          ),
                                        ]

                                    )
                                ),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Padding(
                                              padding: const EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 0.0),
                                              child: SizedBox(
                                                height: 54,
                                                // color: const Color(0xFF4A89DC),
                                                child: Column(
                                                // TODO: Align labels to the bottom and center (123)
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  // TODO: Change innermost Column (123)
                                                  children: <Widget>[
                                                    // Text(CsData.items[index].ca_name_text, textAlign: TextAlign.left, style: const TextStyle(color: Color(0xFF4A89DC), fontSize:12)),
                                                    const SizedBox(height: 5),
                                                    Text(CsData.items[index].wr_content, textAlign: TextAlign.left, maxLines:2, style: const TextStyle(color: kPrimaryColor, fontSize:13, fontWeight: FontWeight.bold)),
                                                  ]
                                                )
                                              )
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF52A4DA),
                                                  borderRadius: const BorderRadius.only(
                                                      bottomLeft: Radius.circular(4.0),
                                                      bottomRight: Radius.circular(4.0))),
                                              child: Center(child: Text(
                                                  CsData.items[index].state.toString(), style: const TextStyle(color: Colors.white, fontSize: 12))),
                                            )
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