// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jnpass/constants.dart';
import 'package:jnpass/provider/stepProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/jsonapi.dart';
import '../models/apiResponse.dart';
import '../models/pointmodel.dart';
import 'login_page.dart';

String selected = "0";
int point = 0;

class Walk extends StatefulWidget {

  const Walk({Key? key}) : super(key: key);

  @override
  WalkState createState() => WalkState();
}

class WalkState extends State<Walk> {
  late final prefs;
  String jwtToken = '';
  StepProvider stepProvider = StepProvider();
  late Future<List<dynamic>> cateData;
  late String step = '0';
  late String step_nocomma = '0';

  final ScrollController scrollController = ScrollController();
  final ScrollController scBoard = ScrollController();
  bool isLoading = false;
  bool point1 = false;
  bool point2 = false;
  String step_money = "0";
  String active_money = "0";
  int pageCount = 1;
  int totalCount = 1;
  int page_rows = 10;
  var f = NumberFormat('###,###,###,###');

  @override
  void initState () {

    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      jwtToken = prefs.getString('jwt_token') ?? "";
      int todaySteps = prefs.getInt("todaySteps") ?? 0;

      dataPoint(pageCount, true);

      setState(() {
        step_nocomma = todaySteps.toString();
        step = f.format(todaySteps);
      });

      reloadData();

    });

    stepProvider.addListener(stepEventListener);

    scBoard.addListener(() {
      if (scBoard.offset >=
          scBoard.position.maxScrollExtent &&
          !scBoard.position.outOfRange) {
        // if (scBoard.position.pixels ==
        //     scBoard.position.maxScrollExtent) {

        setState(() {

          if (isLoading) {
            // 화면 끝에 닿았을 때 이루어질 동작
            pageCount = pageCount + 1;

            if(totalCount <= pageCount) {
              pageCount = totalCount;
            }
            else
            {
              // dataPoint(pageCount, false);
            }

          }
        });

      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    var screenWidth  = size.width;
    var screenHeight = size.height;
    // var _crossAxisCount = ((_screenWidth - 32) / 160).floor(); //컬럼 갯수
    var crossAxisCount = 1; //컬럼 갯수
    var crossAxisSpacing = 8;
    var width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
        crossAxisCount;
    var cellHeight = 45;
    var aspectRatio = width / cellHeight;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("포인트", textAlign: TextAlign.center,
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
          //
          //
          // ]
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: SafeArea (
        child: SingleChildScrollView(
            scrollDirection:Axis.vertical,
            controller: scrollController,
            child: Container(
              padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              // height: screenHeight,
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text("탄소중립걷기챌린지", textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                  // 오늘 나의 걸음
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0),
                      child: Row(
                        children: [
                          const Text("오늘 나의 걸음", textAlign: TextAlign.left,
                            style: TextStyle(color: Color(0XFF292929), fontSize: 16, fontWeight: FontWeight.bold),),
                          Expanded(
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: RichText(
                                  text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: step.toString(),
                                      style: const TextStyle(
                                        color: Color(0XFFE97031),
                                        fontSize: 36.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "걸음",
                                      style: TextStyle(
                                        color: Color(0XFFE97031),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]
                              )
                                )
                            )
                          ),
                        ],
                      )
                  ),

                  // 오늘 나의 걸음 gage
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: SfLinearGauge(
                        minimum: 0.0,
                        maximum: 10000.0,
                        animateRange: true,
                        animationDuration: 3000,
                        ranges: <LinearGaugeRange>[
                          LinearGaugeRange(
                            startValue: 0,
                            endValue: double.parse(step_nocomma),
                            color: const Color(0XFFE97031),
                            position:LinearElementPosition.cross,
                          ),
                        ]
                      ),
                    ),
                  ),
                  // 포인트 적립
                  Container(
                      padding: const EdgeInsets.only(top:10, bottom: 10, left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        // TODO: Center items on the card (123)
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/images/point.png',
                                  width: 40,
                                ),
                                const Padding(padding: EdgeInsets.only(left: 15) ),
                                const Text("5,000 걸음 걷기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                Expanded(child:
                                Align(alignment: Alignment.topRight,
                                    child: TextButton(
                                      onPressed: () {
                                        if(point1)
                                        {
                                          final parameters = {"jwt_token":jwtToken, "money":"30"};
                                          JsonApi.postApi("rest/step_money", parameters).then((value) {
                                            ApiResponse apiResponse = ApiResponse();

                                            apiResponse = value;

                                            if((apiResponse.apiError).error == "9") {

                                              final responseData = json.decode(apiResponse.data.toString());
                                              debugPrint('data ${apiResponse.data}');

                                              if(responseData['code'] == "101")
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
                                              else
                                              {
                                                if(responseData['return'])
                                                {
                                                  reloadData();

                                                  setState(() {
                                                    point1 = false;
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
                                      },
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          elevation: 2,
                                          backgroundColor: point1 ? const Color(0XFF98BF54) : const Color(0XFFC1C6C9)),
                                      child: const Text(
                                        '30P 적립',
                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    ),

                                ))
                              ]
                          ),
                            const SizedBox(height: 15,),
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    'assets/images/point.png',
                                    width: 40,
                                  ),
                                  const Padding(padding: EdgeInsets.only(left: 15) ),
                                  const Text("10,000 걸음 걷기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                  Expanded(child:
                                  Align(alignment: Alignment.topRight,
                                    child: TextButton(
                                      onPressed: () {
                                        if(point2)
                                        {
                                          final parameters = {"jwt_token":jwtToken, "money":"70"};
                                          JsonApi.postApi("rest/step_money", parameters).then((value) {
                                            ApiResponse apiResponse = ApiResponse();

                                            apiResponse = value;

                                            if((apiResponse.apiError).error == "9") {

                                              final responseData = json.decode(apiResponse.data.toString());
                                              debugPrint('data ${apiResponse.data}');

                                              if(responseData['code'] == "101")
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
                                              else
                                              {
                                                if(responseData['return'])
                                                {
                                                  reloadData();

                                                  setState(() {
                                                    point2 = false;
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


                                      },
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          elevation: 2,
                                          backgroundColor: point2 ? const Color(0XFF98BF54) : const Color(0XFFC1C6C9)),
                                      child: const Text(
                                        '70P 적립',
                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    ),

                                  ))
                                ]
                            ),
                        ]
                      )
                    //  D9D9D9
                  ),
                  // 걸음포인트, 활동포인트
                  SizedBox(
                      width: size.width,
                      child: Container(
                        color: const Color(0xFFf4f4f4),
                        child: Column(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 0.0, top: 10.0, right: 0.0, bottom: 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Flexible(
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.only(top:10, bottom: 5, left: 5, right: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF98BF54),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 5),
                                                const Text("걸음포인트", textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),),
                                                const SizedBox(height: 10),
                                                Container(
                                                  padding: const EdgeInsets.only(top:0, bottom: 0, left: 2, right: 2),
                                                  height: 80,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFFFFF),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: RichText(
                                                      text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: step_money.toString(),
                                                              style: const TextStyle(
                                                                color: Color(0xFF292929),
                                                                fontSize: 24.0,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const TextSpan(
                                                              text: " P",
                                                              style: TextStyle(
                                                                color: Color(0xFF292929),
                                                                fontSize: 14.0,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ]
                                                      )
                                                  ),
                                                )
                                              ],
                                            )
                                        ),
                                      ),
                                      const SizedBox(width: 5,),
                                      Flexible(
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.only(top:10, bottom: 5, left: 5, right: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF98BF54),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 5),
                                                const Text("활동포인트", textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),),
                                                const SizedBox(height: 10),
                                                Container(
                                                  padding: const EdgeInsets.only(top:0, bottom: 0, left: 2, right: 2),
                                                  height: 80,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFFFFF),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: RichText(
                                                      text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: active_money.toString(),
                                                              style: const TextStyle(
                                                                color: Color(0xFF292929),
                                                                fontSize: 24.0,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const TextSpan(
                                                              text: " P",
                                                              style: TextStyle(
                                                                color: Color(0xFF292929),
                                                                fontSize: 14.0,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ]
                                                      )
                                                  ),
                                                )
                                              ],
                                            )
                                        ),
                                      ),
                                    ],
                                )
                              ),
                            ]
                        )
                      ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //상품포인트
                  GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse('tel: 1522-0365'));
                    }, // Image tapped
                    child: Image.asset(
                      'assets/images/banner_point.png',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  // 적립내역
                  Container(
                    padding: const EdgeInsets.only(left: 0.0, top: 20.0, right: 0.0, bottom: 20.0),
                    child: const Text("적립내역", textAlign: TextAlign.left,
                      style: TextStyle(color: Color(0XFF292929), fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                  (!isLoading)
                  ?
                  Container(
                    color: Colors.white,
                    height: 100,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                  :
                  Container(
                    height: 70,
                    color: const Color(0xFFEEEEEE),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          Map<String, String> category = cateStep[index].cast<String, String>();
                          return GestureDetector(
                              onTap: (){
                                if(selected != category["id"])
                                {
                                  setState(() {
                                    selected = category["id"] ?? '';
                                    debugPrint('카테고리 클릭 : $selected');
                                  });

                                  dataPoint(1, true).then((value) {
                                    setState(() {

                                    });
                                  });
                                }
                              },
                              child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color:
                                  (category["id"] == selected) ? const Color(0xFFA586BC) :
                                  const Color(0xFFCCCCCC),
                                  elevation: 0.0, // 그림자 효과
                                  margin: const EdgeInsets.only(top: 20, bottom: 20, left: 15),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:10.0, right: 10.0, top: 0.0, bottom: 0.0),
                                      child: Text(category["name"] ?? '',
                                          style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12,)),
                                    ),
                                  )
                              )
                          );
                        }
                    )
                  ),

                  // // 리스트 출력
                  (PointListData.items.isEmpty)
                  ?
                  Container(
                    color: const Color(0XFFFFFFFF),
                    height: 100,
                    child: const Center(
                      child: Text("등록된 자료가 없습니다.",
                          style: TextStyle(color: Colors.black, height: 1, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  )
                  :
                  GridView.builder(
                      physics: const ScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: PointListData.items.length,
                      controller: scBoard,
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio
                      ),
                      itemBuilder: (context, index) {

                        return Row(
                          // mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                flex : 3,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: const Color(0xFFf4f4f4),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: PointListData.items[index].mo_content,
                                          style: const TextStyle(
                                            color: Color(0xFF212529),
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ),
                            Expanded(
                                flex : 2,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  // color: const Color(0xFFf4f4f4),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: PointListData.items[index].mo_datetime.substring(0, 10),
                                          style: const TextStyle(
                                            color: Color(0xFF999999),
                                            fontSize: 12.0,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ),
                            Expanded(
                                flex : 1,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  // color: const Color(0xFFf4f4f4),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: (int.parse(PointListData.items[index].mo_money) > 0)
                                              ? '+ ${PointListData.items[index].mo_money}'
                                              : PointListData.items[index].mo_money,
                                          style: TextStyle(
                                            color: (int.parse(PointListData.items[index].mo_money) > 0)
                                                ? Colors.red
                                                : Colors.grey,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ),

                          ],
                        );
                      }
                    // scrollDirection: Axis.horizontal,


                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15,),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "- 탄소중립걸음수에 따른 포인트",
                              style: TextStyle(
                                color: Color(0xFF212529),
                              ),
                            ),
                            TextSpan(
                              text: "(하루1회)",
                              style: TextStyle(
                                height: 1.5,
                                color: Color(0xFF98BF54),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "5,000걸음 30포인트, 10,000보 70포인트 총 100포인트",
                              style: TextStyle(
                                height: 1.5,
                                color: Color(0xFF212529),
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "- 긴급돌봄 상담접수 1건 (하루 1회): 10포인트",
                              style: TextStyle(
                                height: 1.5,
                                color: Color(0xFF212529),
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "- 신규가입자 (1회): 20포인트",
                              style: TextStyle(
                                height: 1.5,
                                color: Color(0xFF212529),
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "- 동네소식 글 작성자 1건당 10포인트(하루 1회), 댓글 1건당 2포인트(하루 5회)",
                              style: TextStyle(
                                height: 1.5,
                                color: Color(0xFF212529),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                    ],
                  ),
              ]
            )
          )
        )
      )
    );
  }

  @override
  void dispose() {
    stepProvider.removeListener(stepEventListener);
    scBoard.dispose();

    super.dispose();
  }

  Future<void> reloadData() async {

    final parameters = {"jwt_token":jwtToken};
    JsonApi.getApi("rest/today_step", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;
      if(mounted)
      {
        FocusScope.of(context).unfocus();
      }

      if((apiResponse.apiError).error == "9") {
        // BannerData.items.clear();

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data}');

        if(responseData['code'] == "101")
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
        else
        {
          point1 = responseData['point1'];
          point2 = responseData['point2'];

          step_money = f.format(responseData['step_money']);
          active_money = f.format(responseData['active_money']);
          String result = step.replaceAll(RegExp('[^0-9\\s]'), "");

          if(point1 == false && int.parse(result) > 4999)
          {
            point1 = true;
          }

          if(point2 == false && int.parse(result) > 9999)
          {
            point2 = true;
          }

          setState(() {

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


  Future<void> dataPoint(int page, bool init) async {

    final parameters = {"jwt_token":jwtToken, "sca":selected};
    JsonApi.getApi("rest/money", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if(mounted)
      {
        FocusScope.of(context).unfocus();
      }

      if((apiResponse.apiError).error == "9") {
        // BannerData.items.clear();

        final responseData = json.decode(apiResponse.data.toString());

        if(kDebug)
        {
          debugPrint('data ${apiResponse.data}');
        }

        setState(() {
          isLoading = true;
        });

        if(responseData['total_count'].toString() == "0")
        {

        }
        else
        {
          if(List.from(responseData['items']).toList().isNotEmpty) {

            if(init == true)
            {
              PointListData.items = List.from(responseData['items'])
                  .map<PointModel>((item) => PointModel.fromJson(item))
                  .toList();
            }
            else
            {
              PointListData.items += List.from(responseData['items'])
                  .map<PointModel>((item) => PointModel.fromJson(item))
                  .toList();
            }

            setState(() {

            });

          }
          else
          {
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

  // provider 걸음수 함수
  void stepEventListener() {
    // Current class name print
    // if (mounted) {
    // if(kDebug)
    // {
    debugPrint('walk provider.step $step');
    // }
    var f = NumberFormat('###,###,###,###');
    if (mounted) {
      setState(() {
        step = f.format(stepProvider.getStep());
        step_nocomma = stepProvider.getStep().toString();
      });
    }

  }
}
