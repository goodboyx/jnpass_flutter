import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jnpass/pages/newsForm.dart';
import 'dart:async';
import 'package:jnpass/pages/singo.dart';
import 'package:jnpass/pages/singo_comment.dart';
import 'package:jnpass/pages/userprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/jsonapi.dart';
import '../common.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import '../models/bannermodel.dart';
import '../models/messagemodel.dart';


class NewsView extends StatefulWidget {
  String wrId;

  NewsView(
      {Key? key, required this.wrId})
      : super(key: key);

  @override
  NewsViewState createState() => NewsViewState();
}

class NewsViewState extends State<NewsView> {
  late SharedPreferences prefs;
  String url = '';
  bool isLoading = false;
  bool isLike = false;
  late dynamic boardData;
  dynamic mbData = json.decode('{"mb_id": ""}');
  final ScrollController scrollController = ScrollController();
  final ScrollController scBoard = ScrollController();

  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  int commentCnt = 0;

  @override
  void initState () {

    initCommment();

    if(jwtToken.isNotEmpty)
    {
      final parameters = {"jwt_token": jwtToken};
      JsonApi.getApi("rest/jwt_token", parameters).then((value) {
        ApiResponse apiResponse = ApiResponse();

        apiResponse = value;

        if((apiResponse.apiError).error == "9") {

          final responseData = json.decode(apiResponse.data.toString());

          if(kDebug)
          {
            debugPrint('data ${apiResponse.data} ${responseData['code']}');
          }

          if(responseData['code'].toString() == "0")
          {
            mbData = responseData['data'];

            if(mounted)
            {
              setState(() {
              });
            }
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

    url = "${siteUrl}news/${widget.wrId}?type=app";


    SharedPreferences.getInstance().then((value) async {
      prefs = value;

      reloadData();
    });

    super.initState();
  }

  void initCommment() async {
    try {
      var db = FirebaseFirestore.instance;

      QuerySnapshot<Map<String, dynamic>> answersQuery =
      await db
          .collection("news")
          .doc(widget.wrId)
          .collection("messages")
          .where("state", isNotEqualTo: "3")
          .get();

      commentCnt = answersQuery.docs.length;

      setState(() {

      });

      debugPrint('현재 코멘트 수(삭제 제외) : ${commentCnt}');

    } catch (e) {
      debugPrint('commentCnt e ${e.toString()}');
    }
  }
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // var _crossAxisCount = ((_screenWidth - 32) / 160).floor(); //컬럼 갯수
    var crossAxisCount = 1; //컬럼 갯수
    var crossAxisSpacing = 8;
    var width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) / crossAxisCount;
    var cellHeight = 160;
    // var aspectRatio = width / cellHeight;
    var mainHeight = screenHeight - 200;

    if(Platform.isIOS){
      mainHeight = screenHeight - 190;
    }

    if(!isLoading && mbData.isNotEmpty)
    {
      return Container(
        color: Colors.white,
        child:const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
        children: [
          Scaffold(
            // resizeToAvoidBottomInset: true,
            appBar: AppBar(
                centerTitle: true,
                title: const Text("동네소식", textAlign: TextAlign.center,
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
                  // 좋아요 클릭
                  IconButton(icon: FaIcon((isLike == false) ? FontAwesomeIcons.heart : FontAwesomeIcons.solidHeart, size: 16.0),
                    color: (isLike == false) ? Colors.black : Colors.red,
                    onPressed: (){

                      isLike = !isLike;

                      if(jwtToken.isNotEmpty)
                      {
                        setState(() {

                        });

                        final parameters = {"jwt_token": jwtToken};
                        JsonApi.postApi("rest/like/news/${widget.wrId}", parameters).then((value) {
                          ApiResponse apiResponse = ApiResponse();

                          apiResponse = value;

                          if((apiResponse.apiError).error == "9") {

                            final responseData = json.decode(apiResponse.data.toString());
                            if(kDebug)
                            {
                              debugPrint('data ${apiResponse.data} ${responseData['code']}');
                            }

                            if(mounted)
                            {
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
                      else
                      {
                        Fluttertoast.showToast(
                            msg: "로그인이 필요한 서비스입니다.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 13.0
                        );
                      }

                    },),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 0, right: 10, bottom: 10),
                    child: MaterialButton(
                      minWidth:50,
                      color: const Color(0xFF98BF54),
                      onPressed: () {
                        JsonApi.shareFun(context, url, "동네소식");
                      },
                      child: const Text('공유', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                    ),
                  ),

                  if(jwtToken.isNotEmpty && mbData['mb_id'] != boardData['mb_id'])
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 0, right: 10, bottom: 10),
                      child: MaterialButton(
                        minWidth:50,
                        color: const Color(0xFFE97031),
                        onPressed: () {
                          Navigator.of(context,rootNavigator: true).push(
                            MaterialPageRoute(builder: (context) =>
                                Singo(bo_table: 'news', wr_id: widget.wrId)),).then((value){
                            debugPrint('value : $value');
                            if(value == "singo")
                            {
                              Navigator.pop(context, 'reload');
                            }
                          });
                        },
                        child: const Text('신고', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                      ),
                    ),

                  if(jwtToken.isNotEmpty && mbData['mb_id'] == boardData['mb_id'])
                  // 자산의 글이라면 수정하기
                    const SizedBox(width: 50),
                ]
            ),
            body: SafeArea(
                child:GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child :
                    (!isLoading)
                        ?
                    Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                        :
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                              scrollDirection:Axis.vertical,
                              // controller: scrollController,
                              child:  Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 10),
                                    (boardData.isNotEmpty)
                                        ?
                                    Padding(
                                        padding:const EdgeInsets.only(left:10, right:10, top: 10, bottom: 10),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Align(alignment: Alignment.topLeft,
                                                  child: Container(
                                                      width: 100,
                                                      alignment: Alignment.topLeft,
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: const BoxDecoration(
                                                          color: Color(0xFFF2F3F7),
                                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                      ),
                                                      child: Center(child: Text(boardData['ca_name_text'].toString(), style: const TextStyle(
                                                        color: Color(0xFF76777B),
                                                        fontSize: 12.0,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                      )
                                                  )
                                              ),
                                              const SizedBox(height: 10,),
                                              InkWell(
                                                  onTap: () async {
                                                    if(jwtToken.isNotEmpty && mbData['mb_id'] != boardData['mb_id'])
                                                    {
                                                      // 상대방 프로필 화면으로 이동
                                                      Navigator.of(context,rootNavigator: true).push(
                                                        MaterialPageRoute(builder: (context) =>
                                                            UserProfile(user_id:boardData['mb_id'])),).then((value) async {

                                                        if(value == "reload")
                                                        {
                                                          Navigator.pop(context, 'reload');
                                                        }

                                                      });
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [

                                                      (boardData['wr_mb_img'].toString() == "")
                                                          ?
                                                      const CircleAvatar(
                                                          radius: 24,
                                                          backgroundColor: Colors.transparent,
                                                          backgroundImage: AssetImage("assets/images/profile.png")
                                                      )
                                                          :
                                                      Container(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(25.0),
                                                          child: FadeInImage(
                                                            placeholder: const AssetImage("assets/images/profile.png"),
                                                            image: NetworkImage(boardData['wr_mb_img'].toString()),
                                                            imageErrorBuilder:
                                                                (context, error, stackTrace) {
                                                              return Image.asset(
                                                                  'assets/images/profile.png',
                                                                  fit: BoxFit.fitWidth);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      RichText(
                                                          text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: boardData['wr_name'],
                                                                  style: const TextStyle(
                                                                    color: Color(0XFF1f1f1f),
                                                                    fontSize: 13.0,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: "\n${boardData['wr_area']}",
                                                                  style: const TextStyle(
                                                                    color: Color(0XFF727272),
                                                                    fontSize: 12.0,
                                                                    // fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),

                                                              ]
                                                          )
                                                      ),
                                                      Expanded(
                                                        // child: Padding(
                                                        //   padding:EdgeInsets.only(right: 10),
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: Text(boardData['wr_datetime2'].toString()),
                                                          )
                                                      )
                                                      // )
                                                    ],
                                                  )
                                              )
                                            ]
                                        )
                                    )
                                        :
                                    Container(),
                                    const Divider(
                                      color: Colors.grey,
                                      height: 1.0,
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.only(left: 20.0,
                                          bottom: 15.0,
                                          top: 15.0,
                                          right: 15.0),
                                      child: Text(
                                        boardData['wr_subject'].toString(), textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),

                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.only(left: 20.0,
                                          bottom: 15.0,
                                          top: 10.0,
                                          right: 15.0),
                                      child: Text(
                                        boardData['wr_content'].toString(), textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),),

                                    ),
                                    (DonationBannerData.items.isNotEmpty)
                                        ?
                                    CarouselSlider(
                                      options: CarouselOptions(height: 300),
                                      items: DonationBannerData.items.toList().map((item) =>
                                          Image.network(item.img_src, fit:BoxFit.fitHeight, width: 800))
                                          .toList(),
                                    )
                                        :
                                    Container(),
                                    const SizedBox(height: 10,),

                                    (commentCnt > 0)
                                        ?
                                    SizedBox(height: 250,
                                      child: StreamBuilder<List<MessageModel>>(
                                          stream: streamMessages(), //중계하고 싶은 Stream을 넣는다.
                                          builder:
                                              (BuildContext context, asyncSnapshot) {
                                            //비동기 데이터가 존재할 경우 리스트뷰 표시
                                            if (!asyncSnapshot.hasData) {
                                              //데이터가 없을 경우 로딩위젯을 표시한다.
                                              return const Center(child:CircularProgressIndicator());
                                            }
                                            else if (asyncSnapshot.hasError) {
                                              return const Center(
                                                child: Text('오류가 발생했습니다.'),
                                              );
                                            }
                                            else
                                            {
                                              List<MessageModel> messages = asyncSnapshot.data!;

                                              return  ListView.builder(
                                                // 상위 위젯의 크기를 기준으로 잡는게 아닌 자식위젯의 크기를 기준으로 잡음
                                                  itemCount: messages.length,
                                                  itemBuilder: (context, index) {
                                                    return _buildMessage(messages[index]);
                                                  });
                                            }
                                          }),
                                    )
                                        :
                                    Container(
                                      height: 100,
                                      color: const Color(0XFFF3F3F3),
                                      child: const Center(
                                        child: Text("댓글이 없습니다."),
                                      ),
                                    ),
                                  ]
                              )
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  getInputWidget(),
                                ]
                            )
                        )
                      ],
                    )
                )
            ),
          ),

          if(jwtToken.isNotEmpty && mbData['mb_id'] == boardData['mb_id'])
          // 자산의 글이라면 수정하기
            Positioned(
                right: 0.0,
                top: 25,
                child: SpeedDial(
                  icon: Icons.settings_sharp,
                  iconTheme: const IconThemeData(color: Colors.black),
                  // animatedIcon: AnimatedIcons.menu_close,
                  visible: true,
                  direction: SpeedDialDirection.down,
                  curve: Curves.bounceIn,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  overlayColor: Colors.transparent,
                  children: [
                    SpeedDialChild(
                        child: const Icon(Icons.edit_note, color: Colors.white),
                        label: "수정",
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 13.0),
                        backgroundColor: Colors.indigo.shade900,
                        labelBackgroundColor: Colors.indigo.shade900,
                        onTap: () {

                          Navigator.of(context,rootNavigator: true).push(
                              MaterialPageRoute(builder: (context) =>
                                  NewsForm(wrId:widget.wrId))).then((value) {
                            debugPrint('value $value');

                            if(value == "reload")
                            {
                              reloadData();
                            }

                            setState(() {
                              //     debugPrint("BoardData.items[index].wr_is_like : ${BoardData.items[index].wr_is_like}");
                            });
                          });

                        }
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.delete_forever, color: Colors.white,),
                      label: "삭제",
                      backgroundColor: Colors.indigo.shade900,
                      labelBackgroundColor: Colors.indigo.shade900,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13.0),
                      onTap: () {
                        _showDialog();
                      },
                    )
                  ],
                )

              // FloatingActionButton(
              //   onPressed: () {
              //   print('FAB tapped!');
              //   },
              //   elevation: 0,
              //   backgroundColor: Colors.transparent,
              //   foregroundColor: Colors.transparent,
              //   hoverColor: Colors.transparent,
              //   child: Icon(Icons.settings_sharp, color: Colors.black,),
              //
              //   ),
            )
        ]
    );
  }

  Future<void> reloadData() async {
    goodLike();
    boardViewData();
    boardViewImgData();
  }

  // 좋아요 정보 가져오기
  Future<void> goodLike() async {

    final parameters = {"jwt_token": jwtToken};
    JsonApi.getApi("rest/like/news/${widget.wrId}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());

        if(kDebug)
        {
          debugPrint('data ${apiResponse.data}');
        }

        if(responseData['result'].toString() == "true")
        {
          isLike = true;
        }
        else
        {
          isLike = false;
        }

        if(mounted)
        {
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

  // 게시물 상세 정보 가져오기
  Future<void> boardViewData() async {

    final parameters = {"jwt_token": jwtToken};
    JsonApi.getApi("rest/board/news/${widget.wrId}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());

        if(kDebug)
        {
          debugPrint('data ${apiResponse.data}');
        }

        boardData = responseData;

        if(boardData['code'].toString() == '0')
        {
          isLoading = true;
        }

        if(mounted)
        {
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

  // 게시물 상세 정보 이미지 가져오기
  Future<void> boardViewImgData() async {
    DonationBannerData.items.clear();

    final parameters = {"jwt_token": jwtToken};
    JsonApi.getApi("rest/image/news/${widget.wrId}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());

        if(responseData['items'].toString() != "null") {
          DonationBannerData.items = List.from(responseData['items'])
              .map<BannerModel>((item) => BannerModel.fromJson(item))
              .toList();
        }

        if(mounted)
        {
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

  // 댓글 삭제 경고창
  Future<void> _showCommentDialog(String receiverId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Text('해당 글을 하시겠습니까?'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () async {
                try {
                  var db = FirebaseFirestore.instance;

                  db.collection("news")
                      .doc(widget.wrId)
                      .collection("messages").doc(receiverId).update({
                    "state": "3",
                    "sendDate": "0",
                    "content": "삭제된 메시지입니다.",
                  });

                  final parameters = {"jwt_token": jwtToken, "wr_password": "1234"};
                  JsonApi.postApi("rest/delete/comment/news/$receiverId", parameters).then((value) {
                    ApiResponse apiResponse = ApiResponse();
                    apiResponse = value;

                    if((apiResponse.apiError).error == "9") {

                      final responseData = json.decode(apiResponse.data.toString());

                      // if(kDebug)
                      // {
                      debugPrint('datavv ${apiResponse.data}');
                      // }

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

                  Navigator.pop(context);

                  setState(() {

                  });

                } catch (e) {
                  debugPrint(e.toString());
                }
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

  // 본글 삭제
  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: const SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('해당 글을 하시겠습니까?'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () async {

                final parameters = {"jwt_token": jwtToken};
                JsonApi.postApi("rest/delete/board/news/${widget.wrId}", parameters).then((value) {
                  ApiResponse apiResponse = ApiResponse();

                  apiResponse = value;


                  if((apiResponse.apiError).error == "9") {

                    final responseData = json.decode(apiResponse.data.toString());

                    if(kDebug)
                    {
                      debugPrint('data ${apiResponse.data} ${responseData['code']}');
                    }

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

                      Navigator.of(context).pop();
                      Navigator.of(context).pop("reload");
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

  // 코멘트 UI 위젯
  Widget _buildMessage(MessageModel message) {

    bool isMe = false;
    // String time = "";

    if(message.mb_id == mbData['mb_id'])
    {
      isMe = true;
    }

    return Row(
      mainAxisAlignment:
      (isMe == false) ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 5,),

        (message.mb_img != "")
            ?
        InkWell(
            onTap: () async {
              if(jwtToken.isNotEmpty && mbData['mb_id'] != boardData['mb_id'])
              {
                // 상대방 프로필 화면으로 이동
                Navigator.of(context,rootNavigator: true).push(
                  MaterialPageRoute(builder: (context) =>
                      UserProfile(user_id:boardData['mb_id'])),).then((value) async {

                  debugPrint('value : $value');
                  if(value == "reload")
                  {
                    Navigator.pop(context, 'reload');
                  }
                });
              }
            },
            child: Container(
              width: 50.0,
              height: 50.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: FadeInImage(
                  placeholder: const AssetImage("assets/images/profile.png"),
                  image: NetworkImage(message.mb_img.toString()),
                  imageErrorBuilder:
                      (context, error, stackTrace) {
                    return Image.asset(
                        'assets/images/profile.png',
                        fit: BoxFit.fitWidth);
                  },
                ),
              ),
            )
        )
            :
        Column(
          children: [
            (isMe == true && message.state != "3")
                ?
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
              child: MaterialButton(
                minWidth:30,
                height: 25,
                color: kErrorColor,
                onPressed: () {
                  _showCommentDialog(message.id);
                },
                child: const Text('삭제', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
              ),
            )
                :
            const SizedBox(),

            (isMe == false && message.state != "2")
                ?
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
              child: MaterialButton(
                minWidth:40,
                height: 25,
                color: const Color(0xFFE97031),
                onPressed: () {
                  Navigator.of(context,rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) =>
                        SingoComment(bo_table: 'news', wr_id: widget.wrId, fs_id: message.id, fs_message: message.content,)),).then((value){

                    if(value != null)
                    {
                      debugPrint('value : $value');
                      try {
                        var db = FirebaseFirestore.instance;

                        db.collection("news")
                            .doc(widget.wrId)
                            .collection("messages").doc(value).update({
                          "state": "2",
                          "content": "신고 접수된 글입니다.",
                        });

                        setState(() {

                        });

                      } catch (e) {
                        print(e);
                      }

                    }

                  });
                },
                child: const Text('신고', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
              ),
            )
                :
            const SizedBox(),

            Text(
              message.sendDate.toDate().toLocal().toString().substring(5,16),
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
        Flexible(
          child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isMe == false) ? Colors.indigo.shade100 : Colors.indigo.shade50,
                borderRadius: (isMe == false)
                    ? const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )
                    : const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: RichText(
                text: TextSpan(text: message.content.toString(), style: const TextStyle(color: Colors.black38)),
              )
          ),
        ),
        (message.mb_img != "")
            ?
        Column(
          children: [
            (isMe == true && message.state != "3")
                ?
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
              child: MaterialButton(
                minWidth:30,
                height: 25,
                color: kErrorColor,
                onPressed: () {
                  _showCommentDialog(message.id);
                },
                child: const Text('삭제', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
              ),
            )
                :
            const SizedBox(height: 0,),
            Text(
              message.sendDate.toDate().toLocal().toString().substring(5,16),
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        )
            :
        const SizedBox(),
        const SizedBox(width: 5,),
      ],
    );
  }

  Widget? floatingButtons() {

    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: Colors.indigo.shade900,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.settings_sharp, color: Colors.white),
            label: "수정",
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 13.0),
            backgroundColor: Colors.indigo.shade900,
            labelBackgroundColor: Colors.indigo.shade900,
            onTap: () {

            }),
        SpeedDialChild(
          child: const Icon(
            Icons.add_chart_rounded,
            color: Colors.white,
          ),
          label: "삭제",
          backgroundColor: Colors.indigo.shade900,
          labelBackgroundColor: Colors.indigo.shade900,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13.0),
          onTap: () {

          },
        )
      ],
    );
  }

  // 하단 키보드
  Widget getInputWidget() {
    return Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
            child:
            (jwtToken.isNotEmpty)
                ?
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // IconButton(
                //   icon: const Icon(Icons.photo),
                //   color: kButtonColor,
                //   iconSize: 25.0,
                //   onPressed: () {
                //
                //   },
                // ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (value) {
                      _onPressedSendButton();
                      // debugPrint('${controller.text} : $value');
                    },
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(fontSize: 15, color: Colors.black26),
                      labelText: "메세지를 입력해주세요.",
                      border: InputBorder.none,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(
                          color: Colors.black26,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                RawMaterialButton(
                  onPressed: _onPressedSendButton, //전송버튼을 누를때 동작시킬 메소드
                  constraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0
                  ),
                  elevation: 2,
                  fillColor: kButtonColor,
                  shape: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.send, color: Colors.white,),
                  ),
                )
              ],
            )
                :
            GestureDetector(
                onTap: () {
                  Navigator.pop(context, "login");
                }, // Image tapped
                child: const Center(
                  child: Text("로그인이 필요한 서비스입니다.", style: TextStyle(fontSize: 16),
                  ),
                )
            )
        )
    );
  }

  // 댓글 메세지 전송
  void _onPressedSendButton(){
    try{
      //서버로 보낼 데이터를 모델클래스에 담아둔다.
      //여기서 sendDate에 Timestamp.now()가 들어가는데 이는 디바이스의 시간을 나타내므로 나중에는 서버의 시간을 넣는 방법으로 변경하도록 하자.
      String mb_img = "";
      if(mbData['mb_img'].toString() != "")
      {
        mb_img = '$mbImgUrl/${mbData['mb_id']}/${mbData['mb_img']}';
      }

      MessageModel messageModel = MessageModel(content: controller.text, sendDate: Timestamp.now(), mb_id: mbData['mb_id'], mb_nick: mbData['mb_nick'], mb_img: mb_img);

      //Firestore 인스턴스 가져오기
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      //원하는 collection 주소에 새로운 document를 Map의 형태로 추가하는 모습.
      firestore.collection('news/${widget.wrId}/messages').add(messageModel.toMap()).then((value) {
        debugPrint('valuevv : ${value.id}');

        initCommment();

        String temp = controller.text;
        controller.text = '';

        final parameters = {"jwt_token": jwtToken, "wr_content": temp, "wr_password": "1234", "wr_subject": value.id.toString()};

        JsonApi.postApi("rest/comment/news/${widget.wrId}", parameters).then((value) {
          ApiResponse apiResponse = ApiResponse();
          apiResponse = value;

          if((apiResponse.apiError).error == "9") {

            final responseData = json.decode(apiResponse.data.toString());

            if(kDebug)
            {
              debugPrint('data ${apiResponse.data}');
            }

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

      } );

      FocusScope.of(context).requestFocus(FocusNode());

    }catch(ex){
      debugPrint('error: ${ex.toString()} stackTrace: ${StackTrace.current}');
      // log('error)',error: ex.toString(),stackTrace: StackTrace.current);
    }
  }

  Stream<List<MessageModel>> streamMessages(){
    try{
      var db = FirebaseFirestore.instance;

      final Stream<QuerySnapshot> snapshots =
      db
          .collection("news")
          .doc(widget.wrId)
          .collection("messages")
          .where('sendDate', isNotEqualTo: '0')
          .orderBy('sendDate')
          .snapshots();

      // debugPrint('snapshots: ${snapshots.docs.length}');

      //새낭 스냅샷(Stream)내부의 자료들을 List<MessageModel> 로 변환하기 위해 map을 사용하도록 한다.
      //참고로 List.map()도 List 안의 element들을 원하는 형태로 변환하여 새로운 List로 반환한다
      return snapshots.map((querySnapshot){
        List<MessageModel> messages = [];//querySnapshot을 message로 옮기기 위해 List<MessageModel> 선언
        querySnapshot.docs.forEach((element) { //해당 컬렉션에 존재하는 모든 docs를 순회하며 messages 에 데이터를 추가한다.
          messages.add(
              MessageModel.fromMap(
                  id:element.id,
                  map:element.data() as Map<String, dynamic>
              )
          );
        });
        return messages; //QuerySnapshot에서 List<MessageModel> 로 변경이 됐으니 반환
      }); //Stream<QuerySnapshot> 에서 Stream<List<MessageModel>>로 변경되어 반환됨

    }catch(ex){//오류 발생 처리
      // log('error)',error: ex.toString(),stackTrace: StackTrace.current);
      debugPrint('error: ${ex.toString()} stackTrace: ${StackTrace.current}');

      return Stream.error(ex.toString());
    }
  }
}

