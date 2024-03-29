import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/jsonapi.dart';
import '../common.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import '../models/bannermodel.dart';

class NoticeView extends StatefulWidget {
  String wrId;

  NoticeView(
      {Key? key, required this.wrId})
      : super(key: key);

  @override
  NoticeViewState createState() => NoticeViewState();
}

class NoticeViewState extends State<NoticeView> {
  late SharedPreferences prefs;
  String url = '';
  bool isLoading = false;
  bool isLike = false;
  late dynamic boardData;
  dynamic mbData = json.decode('{"mb_id": ""}');

  @override
  void initState () {

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

    url = "${siteUrl}notice/${widget.wrId}?type=app";


    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      reloadData();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var screenWidth = MediaQuery.of(context).size.width;
    // var screenHeight = MediaQuery.of(context).size.height;

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
                title: const Text("공지사항", textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 15),),
                backgroundColor: Colors.white,
                shape: const Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                elevation: 0.0,
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      Navigator.pop(context),
                  color: Colors.black,
                ),
                actions: <Widget>[
                  IconButton(icon: const FaIcon(FontAwesomeIcons.shareNodes, size: 16.0),
                      color: Colors.black,
                      onPressed: (){
                        JsonApi.shareFun(context, url, "공지사항");
                      },
                  ),
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
                        JsonApi.postApi("rest/like/notice/${widget.wrId}", parameters).then((value) {
                          ApiResponse apiResponse = ApiResponse();

                          apiResponse = value;

                          if((apiResponse.apiError).error == "9") {

                            final responseData = json.decode(apiResponse.data.toString());
                            // if(kDebug)
                            // {
                              debugPrint('data ${apiResponse.data} ${responseData['code']}');
                            // }

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
                ]
            ),
            body: SafeArea(
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
                                (NoticeBannerData.items.isNotEmpty)
                                    ?
                                CarouselSlider(
                                  options: CarouselOptions(height: 300),
                                  items: NoticeBannerData.items.toList().map((item) =>
                                      Image.network(item.img_src, fit:BoxFit.fitHeight, width: 800))
                                      .toList(),
                                )
                                    :
                                Container(),
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
                                const SizedBox(height: 10,),
                              ]
                          )
                      ),
                    ),
                    (boardData['wr_link1'].toString() != "")
                    ?
                    Padding(
                        padding:  const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ElevatedButton.icon(
                                onPressed: () {
                                  launchUrl(Uri.parse(boardData['wr_link1'].toString()));
                                },
                                label: const Text(' 링크클릭 '),
                                icon: const Icon(Icons.link),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ]
                        )
                    )
                    :
                    Container(),
                  ],
                )
            )
          ),
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
    JsonApi.getApi("rest/like/notice/${widget.wrId}", parameters).then((value) {
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
    JsonApi.getApi("rest/board/notice/${widget.wrId}", parameters).then((value) {
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
    NoticeBannerData.items.clear();

    final parameters = {"jwt_token": jwtToken};
    JsonApi.getApi("rest/image/notice/${widget.wrId}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());

        if(responseData['items'].toString() != "null") {
          NoticeBannerData.items = List.from(responseData['items'])
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