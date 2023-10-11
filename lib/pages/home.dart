import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jnpass/constants.dart';
import 'package:jnpass/pages/news.dart';
import 'package:jnpass/pages/newsview.dart';
import 'package:jnpass/pages/walk.dart';
import 'package:jnpass/provider/stepProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/jsonapi.dart';
import '../common.dart';
import '../models/apiResponse.dart';
import '../models/bannermodel.dart';
import '../models/boardmodel.dart';
import '../provider/notiEvent.dart';
import '../util.dart';
import '../widgets/sosAppBar.dart';
import 'consultWrite.dart';
import 'login_page.dart';
import 'noticeview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late SharedPreferences prefs;
  final ScrollController scrollController = ScrollController();
  late String step = '0';
  StepProvider stepProvider = StepProvider();
  bool isLoading = false;
  NotiEvent notiEvent = NotiEvent();

  @override
  void initState() {

    var f = NumberFormat('###,###,###,###');

    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      jwtToken = prefs.getString('jwt_token') ?? "";
      meLoc    = prefs.getString('me_loc') ?? '0';

      int todaySteps = prefs.getInt("todaySteps") ?? 0;

      setState(() {
        step = f.format(todaySteps);
      });

      dataConsult();
    });

    stepProvider.addListener(stepEventListener);

    dataAdSlide();

    notiEvent.addListener(notiEventListener);

    super.initState();
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
    var cellHeight = 180;
    var aspectRatio = width / cellHeight;

    var mainHeight = screenHeight - 150;

    if(Platform.isIOS){
      mainHeight = screenHeight - 190;
    }

    return  Scaffold(
        appBar: const SosAppBar(),
        body: SingleChildScrollView(
          scrollDirection:Axis.vertical,
          child:Column(
            children: <Widget>[
              Container(
              height: mainHeight,
              // color: const Color(0xFFDDDDDD),
                child: Padding(
                  padding: const EdgeInsets.only(top:30.0, left:15.0, right:15.0),
                    child: ListView(
                        controller: scrollController,
                        // physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context,rootNavigator: true).push(
                                  MaterialPageRoute(builder: (context) =>
                                      const ConsultWrite())
                              );
                            }, // Image tapped
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child:  Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text("우리동네SOS ", style: TextStyle(fontFamily: 'SCDream', fontSize: 22),),
                                      Text("긴급돌봄 서비스", style: TextStyle(fontFamily: 'SCDream', fontSize: 22, fontWeight: FontWeight.bold),),
                                    ]
                                  ),
                                  SizedBox(height: 7,),
                                  Text("긴급 또는 일시적인 돌봄이 필요할 때", style: TextStyle(fontFamily: 'SCDream', fontSize: 16, color: Color(0xFF626262)),),
                                  SizedBox(height: 5,),
                                  Text("상담을 신청하시면 도움을 드리겠습니다.", style: TextStyle(fontFamily: 'SCDream', fontSize: 16, color: Color(0xFF626262)),),
                                ]
                              )
                            ),
                          ),
                          const SizedBox(height: 15,),
                          Row(
                              children: [
                                Flexible(
                                  flex: 11, // default
                                  fit: FlexFit.tight, // default
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9.0),
                                        ),
                                        side: const BorderSide(width: 2, color:Color(0xff60A7D3)),
                                        backgroundColor:const Color(0xff60A7D3),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context,rootNavigator: true).push(
                                            MaterialPageRoute(builder: (context) =>
                                            const ConsultWrite())
                                        );
                                      },
                                      child: const Column(
                                          children: [
                                            SizedBox(height: 15,),
                                            Text("온라인상담", style: TextStyle(fontFamily: 'SCDream', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                                            SizedBox(height: 5,),
                                            Text("글 남기기", style: TextStyle(fontFamily: 'SCDream', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                            SizedBox(height: 15,),
                                          ]
                                      )
                                  )
                                ),
                                Flexible(
                                  flex: 1, // default
                                  fit: FlexFit.loose, // default
                                  child: Container(),
                                ),
                                Flexible(
                                  flex: 11, // default
                                  fit: FlexFit.tight, // default
                                  // 1522-0365 배너
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9.0),
                                        ),
                                        side: const BorderSide(width: 2, color:Color(0xff9BC360)),
                                        backgroundColor:const Color(0xff9BC360),
                                      ),
                                      onPressed: () {
                                        launchUrl(Uri.parse('tel: 1522-0365'));
                                      },
                                      child: const Column(
                                        children: [
                                          SizedBox(height: 15,),
                                          Text("전화상담", style: TextStyle(fontFamily: 'SCDream', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                                          SizedBox(height: 5,),
                                          Text("1522-0365", style: TextStyle(fontFamily: 'SCDream', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                          SizedBox(height: 15,),
                                        ]
                                      )
                                    )
                                )
                              ]
                          ),
                          const SizedBox(height: 15),
                          // 현재까지 걸음수
                          GestureDetector(
                              onTap: (){
                                if(jwtToken.isEmpty)
                                {
                                  Navigator.of(context,rootNavigator: true).push(
                                    MaterialPageRoute(builder: (context) =>
                                    const LoginPage()),).then((value){

                                  });
                                }
                                else
                                {
                                  Navigator.of(context,rootNavigator: true).push(
                                      MaterialPageRoute(builder: (context) =>
                                          const Walk())
                                  );
                                }
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 20.0,
                                ),
                                child:Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Image.asset(
                                    //   'assets/images/step1.png',
                                    // ),
                                    // const Padding(padding: EdgeInsets.only(left: 15) ),
                                    const Text("오늘의 탄소중립걷기 ", style: TextStyle(fontFamily: 'SCDream', fontSize: 15),),
                                    Text(" $step ", style: const TextStyle(color: Color(0xFFFF6D1C), fontFamily: 'SCDream', fontWeight: FontWeight.bold, fontSize: 24),),
                                    const Text(" 걸음 ", style: TextStyle(fontFamily: 'SCDream', fontSize: 15),),
                                    // const Expanded(child:
                                    //         Align(alignment: Alignment.topRight,
                                    //         child: Icon(Icons.arrow_forward_ios,)))
                                  ]
                                ),
                              ),
                          ),
                          const SizedBox(height: 10),
                          // 공지사항 배너
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 120,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 3),
                            ),
                            items: BannerData.items.toList().map((item) => GestureDetector(
                                child: Image.network(item.img_src, fit:BoxFit.cover, width: 900),
                                onTap: () {

                                  Navigator.of(context,rootNavigator: true).push(
                                      MaterialPageRoute(builder: (context) =>
                                          NoticeView(wrId:item.link))
                                  );
                                }
                            ))
                                .toList(),
                          ),
                          // 일반 배너
                          const SizedBox(height: 10,),

                          // 동네소식
                          Container(
                              height: 630,
                              color: Colors.transparent,
                              child: GridView.builder(
                                shrinkWrap: false,
                                // controller: scrollController,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: BoardData.items.length,
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: aspectRatio),
                                itemBuilder: (context, index) {
                                  return Column(
                                    // TODO: Center items on the card (123)
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context,rootNavigator: true).push(
                                                    MaterialPageRoute(builder: (context) =>
                                                        NewsView(wrId:BoardData.items[index].wr_id))).then((value) {

                                                          if(value =="reload")
                                                          {
                                                            dataConsult();
                                                          }
                                                          else if(value == "login")
                                                          {
                                                            Navigator.of(context,rootNavigator: true).push(
                                                              MaterialPageRoute(builder: (context) =>
                                                              const LoginPage()),).then((value){

                                                            });
                                                          }
                                                  });
                                              },

                                              child:
                                                Stack(
                                                  children: [
                                                    if(BoardData.items[index].thum != "")
                                                      Positioned(
                                                        top: 0,
                                                        right: -20,
                                                        child: Container(
                                                          width: 120,
                                                          child:Image.network(BoardData.items[index].thum, fit:BoxFit.fitHeight, width: screenWidth)
                                                        )
                                                      ),

                                                    Positioned(
                                                        bottom: 5,
                                                        right: 0,
                                                        child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            const WidgetSpan(
                                                              child: Icon(Icons.favorite, size: 14, color: Color(0xFFA5A5A5),),
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
                                                              text: BoardData.items[index].wr_like.toString(),
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
                                                              child: Icon(Icons.comment, size: 14, color: Color(0xFFA5A5A5),),
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
                                                              text: BoardData.items[index].wr_comment.toString(),
                                                              style: const TextStyle(
                                                                color: Color(0xFF8CC152),
                                                                fontSize: 12.0,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),

                                                          ],
                                                        )
                                                      )
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Align(alignment: Alignment.topLeft,
                                                            child: Container(
                                                                width: 60,
                                                                alignment: Alignment.topLeft,
                                                                padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
                                                                decoration: const BoxDecoration(
                                                                    color: Color(0xFFE1E1E1),
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                ),
                                                                child: const Center(child: Text('동네소식', style: TextStyle(
                                                                  color: Color(0xFF818181),
                                                                  fontFamily: 'SCDream',
                                                                  fontSize: 11.0,
                                                                  fontWeight: FontWeight.bold,
                                                                )),
                                                                )
                                                            )
                                                        ),
                                                      ]
                                                    ),
                                                    Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Container (
                                                            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                                                            width: BoardData.items[index].thum != "" ? screenWidth - 140 : screenWidth - 60,
                                                            child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[
                                                                    RichText(
                                                                      overflow: TextOverflow.ellipsis,
                                                                      maxLines: 2,
                                                                      text: TextSpan(
                                                                          text: BoardData.items[index].wr_content,
                                                                          style: const TextStyle(
                                                                            color: Colors.black,
                                                                            fontFamily: 'SCDream',
                                                                            fontWeight: FontWeight.bold,
                                                                            height: 1.8,
                                                                            fontSize: 14.0,)),
                                                                    ),
                                                                    const SizedBox(height: 15,),
                                                                    Align(alignment: Alignment.topLeft,
                                                                        child: Text('${BoardData.items[index].wr_area} · ${BoardData.items[index].wr_date} · 조회${BoardData.items[index].wr_hit.toString()}회',
                                                                            style:const TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Color(0xFFA5A5A5),
                                                                                fontFamily: 'SCDream',
                                                                                fontSize: 11.0)
                                                                        )
                                                                    ),
                                                                    const SizedBox(height: 5,),
                                                                  ]
                                                              )
                                                          ),
                                                        ]
                                                    ),
                                                  ]

                                                ),
                                            )
                                        ),
                                        const Divider(thickness: 1, height: 1, color: Color(0xFFA5A5A5)),
                                      ]
                                  );
                                }
                              )
                          ),
                          const SizedBox(height: 15),
                          //더보기 버튼
                          GestureDetector(
                            onTap: () async {
                              Navigator.of(context,rootNavigator: true).push(
                                MaterialPageRoute(builder: (context) =>
                                const NewsPage()),).then((value){

                              });
                            }, // Image tapped
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 20.0,
                              ),
                              child: Align(alignment: Alignment.center,
                                child: RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "더보기  ",
                                        style: TextStyle(
                                          color: Color(0xFF707070),
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: Icon(Icons.keyboard_arrow_down, size: 20),
                                      )
                                  ]
                                )
                                ),
                              )
                            )
                          ),
                          const SizedBox(height: 20),
                        ]
                    )
                )
              )
            ]
          )
        ),
        floatingActionButton: FloatingActionButton(
        heroTag: "kakao_btn",
        backgroundColor: Colors.transparent,
            child: Image.asset("assets/images/kakaotalk.png", fit:BoxFit.fitWidth),
        onPressed: () {
          Util.launchKaKaoChannel();
        },
    ),

    );
  }

  @override
  void dispose() {
    stepProvider.removeListener(stepEventListener);
    notiEvent.removeListener(notiEventListener);
    super.dispose();
  }

  //상단 이미지 배너
  void dataAdSlide() {
    // BannerData.items.clear();

    final parameters = {"": ""};
    JsonApi.getApi("rest/banner", parameters).then((value) {
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
          BannerData.items = List.from(responseData['items'])
              .map<BannerModel>((item) => BannerModel.fromJson(item))
              .toList();

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

  // 동네소식
  void dataConsult() {
    BoardData.items.clear();

    final parameters = {"page": "1", "limit": "4", "jwt_token":jwtToken, "me_loc":meLoc};

    JsonApi.getApi("rest/board/news", parameters).then((value) {
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
            BoardData.items = List.from(responseData['items'])
                .map<BoardModel>((item) => BoardModel.fromJson(item))
                .toList();

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

  void notiEventListener() {
    // Current class name print
    debugPrint('main notiEventListener ${notiEvent.msg}');
    dataConsult();
  }

  // provider 걸음수 함수
  void stepEventListener() {
    // Current class name print
    // if (mounted) {
    if(kDebug)
    {
      debugPrint('home step ${stepProvider.getStep()}');
    }

    var f = NumberFormat('###,###,###,###');

    setState(() {
      step = f.format(stepProvider.getStep());
    });
  }
}

