import 'dart:convert';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:jnpass/pages/singo.dart';
import 'package:jnpass/pages/userprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/jsonapi.dart';
import '../common.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import '../models/bannermodel.dart';
import '../models/boardmodel.dart';


class NewsView extends StatefulWidget {
  String wrId;

  String like;

  NewsView(
      {Key? key, required this.wrId, required this.like})
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
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState () {

    // connect();
    // DonationCommentData.items.clear();

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
            setState(() {

            });
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

    url = "$siteUrl/bbs/board.php?bo_table=news&wr_id=${widget.wrId}";

    SharedPreferences.getInstance().then((value) async {
      prefs = value;

      reloadData();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(!isLoading && mbData.isNotEmpty)
    {
      return Container(
        color: Colors.white,
        child:const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("동네소식", textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 15),),
          backgroundColor: Colors.white,
          // elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                Navigator.pop(context, '${widget.wrId}@@${widget.like}'),
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
                      debugPrint('data ${apiResponse.data}');

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
            IconButton( icon: const FaIcon(FontAwesomeIcons.ellipsisVertical, size: 16.0), color: Colors.black, onPressed: () {
              // _handleFABPressed();
            })
          ]
      ),
      body: SafeArea(
          child:WillPopScope(
              onWillPop: () async {
                Navigator.pop(context, 'news@@${widget.wrId}@@${widget.like}');
                return false;
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
              SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
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
                                        // if(jwtToken.isNotEmpty && mbData['mb_id'] != boardData['mb_id'])
                                        // {
                                          // 상대방 프로필 화면으로 이동
                                          Navigator.of(context,rootNavigator: true).push(
                                            MaterialPageRoute(builder: (context) =>
                                                UserProfile(user_id:boardData['mb_id'])),).then((value) async {
                                            if (value != null) {
                                              // dataComment(1, true);
                                            }
                                          });
                                        // }
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
                                          CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors.transparent,
                                              backgroundImage: NetworkImage(boardData['wr_mb_img'].toString())
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
                          options: CarouselOptions(height: 200),
                          items: DonationBannerData.items.toList().map((item) =>
                              Image.network(item.img_src, fit:BoxFit.fitWidth, width: 1000))
                              .toList(),
                        )
                            :
                        Container(),
                        // (NewsCommentData.items.isEmpty)
                        //     ?
                        // Container(
                        //     padding: EdgeInsets.only(left:10, right:10, top: 10, bottom: 10),
                        //     color: const Color(0xFFEEEEEE),
                        //     width: _screenWidth,
                        //     height:100,
                        //     child:Center(
                        //         child: Text("현재 등록한 댓글은 없습니다.")
                        //     )
                        // )
                        //     :
                        // Container(
                        //     padding: EdgeInsets.only(left:10, right:10, top: 10, bottom: 10),
                        //     color: const Color(0xFFEEEEEE),
                        //     height:_screenHeight - 300,
                        //     child: ListView.builder(
                        //         scrollDirection: Axis.vertical,
                        //         controller: scBoard,
                        //         itemCount: NewsCommentData.items.length,
                        //         itemBuilder: (context, index) {
                        //           return
                        //             (NewsCommentData.items[index].is_me == 0)
                        //                 ?
                        //             Column(
                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                 children: [
                        //                   Row(
                        //                       children: [
                        //                         InkWell(
                        //                           onTap: () async {
                        //                             // 상대방 프로필 화면으로 이동
                        //                             Navigator.of(context,rootNavigator: true).push(
                        //                               MaterialPageRoute(builder: (context) =>
                        //                                   UserProfile(user_id:NewsCommentData.items[index].mb_id)),).then((value) async {
                        //                               if (value != null) {
                        //                                 dataComment(1, true);
                        //                               }
                        //                             });
                        //                           },
                        //                           child:
                        //                           (NewsCommentData.items[index].cm_img == "")
                        //                               ?
                        //                           CircleAvatar(
                        //                               radius: 24,
                        //                               backgroundColor: Colors.transparent,
                        //                               backgroundImage: AssetImage("assets/images/profile.png")
                        //                           )
                        //                               :
                        //                           CircleAvatar(
                        //                               radius: 24,
                        //                               backgroundColor: Colors.transparent,
                        //                               backgroundImage: NetworkImage(NewsCommentData.items[index].cm_img)
                        //                           ),
                        //                         ),
                        //                         SizedBox(width: 10,),
                        //                         RichText(
                        //                             text: TextSpan(
                        //                                 children: [
                        //                                   TextSpan(
                        //                                     text: NewsCommentData.items[index].mb_nick,
                        //                                     style: TextStyle(
                        //                                       color: const Color(0XFF1f1f1f),
                        //                                       fontSize: 12.0,
                        //                                       fontWeight: FontWeight.bold,
                        //                                     ),
                        //                                   ),
                        //                                 ]
                        //                             )
                        //                         ),
                        //                         SizedBox(width: 10,),
                        //                         Text(NewsCommentData.items[index].c_time,
                        //                             style: TextStyle(
                        //                               color: const Color(0XFF1f1f1f),
                        //                               fontSize: 12.0,
                        //                             )
                        //                         ),
                        //                         // child: Padding(
                        //                         //   padding:EdgeInsets.only(right: 10),
                        //                       ]
                        //                   ),
                        //                   Card(
                        //                     semanticContainer: true,
                        //                     clipBehavior: Clip.antiAliasWithSaveLayer,
                        //                     shape: RoundedRectangleBorder(
                        //                       borderRadius: BorderRadius.circular(10),
                        //                     ),
                        //                     color:const Color(0xFFe8f1f3),
                        //                     elevation: 1.0, // 그림자 효과
                        //                     margin: EdgeInsets.only(top: 2, bottom: 10, left: 15),
                        //                     child: Container(
                        //                       padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                        //                       width: MediaQuery.of(context).size.width * 0.7 ,
                        //                       child: Text(NewsCommentData.items[index].wr_content,
                        //                         style: TextStyle(
                        //                             color: const Color(0xFF444444),
                        //                             fontSize: 12.0,
                        //                             fontWeight: FontWeight.w600
                        //                         ),
                        //                         // overflow: TextOverflow.ellipsis,
                        //                       ),
                        //                     ),
                        //                   ),
                        //                   (NewsCommentData.items[index].singo_mode == 1)
                        //                       ?
                        //                   Row(
                        //                       children: [
                        //                         SizedBox(width: 30,),
                        //                         InkWell(
                        //                           onTap: () async {
                        //                             _commentLike(NewsCommentData.items[index].wr_id);
                        //                           },
                        //                           child: Padding(
                        //                             padding: EdgeInsets.all(3.0),
                        //                             child:
                        //                             (NewsCommentData.items[index].like_mode == 2)
                        //                                 ?
                        //                             Text("좋아요 취소 ",
                        //                                 style: TextStyle(
                        //                                     color: const Color(0xFFa586bc),
                        //                                     fontSize: 11.0,
                        //                                     fontWeight: FontWeight.bold
                        //                                 )
                        //                             )
                        //                                 :
                        //                             Text("좋아요 ",
                        //                                 style: TextStyle(
                        //                                   color: const Color(0xFF1f1f1f),
                        //                                   fontSize: 11.0,
                        //                                 )
                        //                             ),
                        //                           ),
                        //                         ),
                        //                         SizedBox(width: 10,),
                        //                         InkWell(
                        //                           onTap: () async {
                        //                             Navigator.of(context,rootNavigator: true).push(
                        //                               MaterialPageRoute(builder: (context) =>
                        //                                   Singo(title: "신고", bo_table: widget.bo_table, wr_id: NewsCommentData.items[index].wr_id, wr_is_comment: '1',)),).then((value) {
                        //                               if (value != null) {
                        //                                 dataComment(1, true);
                        //                               }
                        //                             });
                        //                           },
                        //                           child: Padding(
                        //                             padding: EdgeInsets.all(3.0),
                        //                             child: Text("신고",
                        //                                 style: TextStyle(
                        //                                   color: const Color(0XFF1f1f1f),
                        //                                   fontSize: 11.0,
                        //                                 )
                        //                             ),
                        //                           ),
                        //                         )
                        //                       ]
                        //                   )
                        //                       :
                        //                   Container(),
                        //                   SizedBox(height: 10,)
                        //                 ]
                        //             )
                        //                 :
                        //             Column(
                        //                 crossAxisAlignment: CrossAxisAlignment.end,
                        //                 children: [
                        //                   Row(
                        //                       mainAxisAlignment: MainAxisAlignment.end,
                        //                       crossAxisAlignment: CrossAxisAlignment.center,
                        //                       children: [
                        //                         Text(NewsCommentData.items[index].c_time,
                        //                             style: TextStyle(
                        //                               color: const Color(0XFF1f1f1f),
                        //                               fontSize: 12.0,
                        //                             )
                        //                         ),
                        //                         SizedBox(width: 10,),
                        //                         RichText(
                        //                             text: TextSpan(
                        //                                 children: [
                        //                                   TextSpan(
                        //                                     text: NewsCommentData.items[index].mb_nick,
                        //                                     style: TextStyle(
                        //                                       color: const Color(0XFF1f1f1f),
                        //                                       fontSize: 12.0,
                        //                                       fontWeight: FontWeight.bold,
                        //                                     ),
                        //                                   ),
                        //                                 ]
                        //                             )
                        //                         ),
                        //                         SizedBox(width: 10,),
                        //                         (NewsCommentData.items[index].cm_img == "")
                        //                             ?
                        //                         CircleAvatar(
                        //                             radius: 24,
                        //                             backgroundColor: Colors.transparent,
                        //                             backgroundImage: AssetImage("assets/images/profile.png")
                        //                         )
                        //                             :
                        //                         CircleAvatar(
                        //                             radius: 24,
                        //                             backgroundColor: Colors.transparent,
                        //                             backgroundImage: NetworkImage(NewsCommentData.items[index].cm_img)
                        //                         ),
                        //                         // child: Padding(
                        //                         //   padding:EdgeInsets.only(right: 10),
                        //                       ]
                        //                   ),
                        //                   Card(
                        //                     semanticContainer: true,
                        //                     clipBehavior: Clip.antiAliasWithSaveLayer,
                        //                     shape: RoundedRectangleBorder(
                        //                       borderRadius: BorderRadius.circular(10),
                        //                     ),
                        //                     color:const Color(0xFFffc107),
                        //                     elevation: 1.0, // 그림자 효과
                        //                     margin: EdgeInsets.only(top: 2, bottom: 10, left: 15),
                        //                     child: Container(
                        //                         padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                        //                         width: MediaQuery.of(context).size.width * 0.7 ,
                        //                         child: Align(
                        //                           alignment:Alignment.centerRight,
                        //                           child: Text(NewsCommentData.items[index].wr_content,
                        //                             style: TextStyle(
                        //                                 color: const Color(0xFF444444),
                        //                                 fontSize: 12.0,
                        //                                 fontWeight: FontWeight.w600
                        //                             ),
                        //                             // overflow: TextOverflow.ellipsis,
                        //                           ),
                        //
                        //                         )
                        //                     ),
                        //                   ),
                        //                   Row(
                        //                       mainAxisAlignment: MainAxisAlignment.end,
                        //                       crossAxisAlignment: CrossAxisAlignment.center,
                        //                       children: [
                        //                         (NewsCommentData.items[index].del_mode == 1)
                        //                             ?
                        //                         InkWell(
                        //                           onTap: () async {
                        //                             _showDialogDel(NewsCommentData.items[index].wr_id);
                        //                           },
                        //                           child: Padding(
                        //                             padding: EdgeInsets.all(3.0),
                        //                             child: Text(" 삭제",
                        //                                 style: TextStyle(
                        //                                   color: const Color(0XFF1f1f1f),
                        //                                   fontSize: 11.0,
                        //                                 )
                        //                             ),
                        //                           ),
                        //                         )
                        //                             :
                        //                         Container()
                        //                         ,
                        //                         // SizedBox(width: 20,),
                        //                       ]
                        //                   ),
                        //                 ]
                        //             );
                        //
                        //         }
                        //     )
                        // ),

                        const SizedBox(height: 20,),
                      ]
                  )
              )
          )
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // 코멘트 입력
                (jwtToken.isNotEmpty)
                ?
                Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultPadding * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                        children: [
                          // 아이콘 선택
                          // Icon(
                          //   Icons.sentiment_satisfied_alt_outlined,
                          //   color: Theme.of(context)
                          //       .textTheme
                          //       .bodyText1
                          //       ?.color
                          //       ?.withOpacity(0.64),
                          // ),
                          const SizedBox(width: kDefaultPadding / 4),
                          Expanded(
                            child: TextField(
                              onSubmitted: (value) {
                                debugPrint('${textEditingController.text} : $value');
                                // onSendMessage(textEditingController.text, TypeMessage.text);
                              },
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                hintText: "메세지를 입력해주세요.",
                                // hintStyle: TextStyle(color: ColorConstants.greyColor),
                                border: InputBorder.none,
                              ),
                              focusNode: focusNode,
                            ),
                          ),
                          // 사진첨부, 사진 촬영시
                          // Icon(
                          //   Icons.attach_file,
                          //   color: Theme.of(context)
                          //       .textTheme
                          //       .bodyText1
                          //       ?.color
                          //       ?.withOpacity(0.64),
                          // ),
                          const SizedBox(width: kDefaultPadding / 4),
                          // InkWell(
                          //     onTap: () async {
                          //       loadAssets();
                          //     },
                          //     child: Icon(
                          //       Icons.camera_alt_outlined,
                          //       color: Theme.of(context)
                          //           .textTheme
                          //           .bodyText1
                          //           ?.color
                          //           ?.withOpacity(0.64),
                          //     )
                          // ),
                        ]
                    )
                )
                :
                const SizedBox(),
                // (DonationBoardViewData.items[0].wr_link1 != "")
                //     ?
                // ElevatedButton(
                //     onPressed: () {
                //       if(Platform.isIOS)
                //       {
                //         sendSms();
                //       }
                //       else
                //       {
                //         launchUrl(Uri.parse(DonationBoardViewData.items[0].wr_link1));
                //       }
                //
                //     },
                //     style: ElevatedButton.styleFrom(elevation: 10,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(30.0),
                //         side: BorderSide(color: kButtonColor),
                //       ),
                //     ),
                //     child: Text((Platform.isIOS) ? "기부하기 SMS 전송" : "기부하기",
                //         style: const TextStyle(fontSize: 13))
                // )
                //     :
                // const Text("기부 링크가 없습니다. "),
              ]
          )
      )
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
          debugPrint('datavv ${apiResponse.data}');
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

}