import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jnpass/api/jsonapi.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../chat_provider.dart';
import '../constants.dart';
import '../models/apiError.dart';
import '../models/apiResponse.dart';
import '../models/bannermodel.dart';
import '../models/boardmodel.dart';
import '../models/commentmodel.dart';
import '../models/member.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;

import '../util.dart';
import 'login_page.dart';

// ignore: must_be_immutable
class DonationView extends StatefulWidget {
  String boTable;
  String wrId;
  String like;
  String share;

  DonationView(
      {Key? key, required this.boTable, required this.wrId, required this.like, required this.share})
      : super(key: key);

  @override
  DonationViewState createState() => DonationViewState();
}

class DonationViewState extends State<DonationView> {
  dom.Document document = htmlparser.parse('');
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  Color kButtonColor  = const Color(0xFF138496);

  bool _initialized = false;
  bool isLoading = false;
  late Member mb;
  late String mbId;
  String selected = "0";
  int likeCnt = 0;
  int commentCnt = 0;
  int currentPage = 1;

  static final GlobalKey<ScaffoldState> globalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final ScrollController scBoard = ScrollController();
  // late MqttServerClient client;

  // List<Asset> imageList = <Asset>[];
  String error = 'No Error Dectected';
  int _count = 0;        // 이미지 갯수
  late SharedPreferences prefs;


  Future<ApiResponse> dataImageSlide() async {

    debugPrint(' wr_id ${widget.wrId} ');

    ApiResponse apiResponse = ApiResponse();

    DonationBannerData.items.clear();

    try {
      Uri url = Uri.parse(
          '${appApiUrl}app_board_banner.php?app_token=$token&bo_table=${widget.boTable}&wr_id=${widget
              .wrId}');

      final response = await http.get(url);

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;

          final responseData = json.decode(responseBody);

          isLoading = true;

          setState(() {
            DonationBannerData.items = List.from(responseData)
                .map<BannerModel>((item) => BannerModel.fromJson(item))
                .toList();
          });

          apiResponse.apiError = ApiError("9", "");
          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          break;
        default:
          apiResponse.apiError = ApiError("1", "http 상태 에러");
          break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "app_board_banner.php socket error");
    }

    return apiResponse;
  }


  @override
  void initState() {

    scBoard.addListener(() {
      if (scBoard.offset == 0.0) {
        _scrollController.animateTo(0,
            duration: const Duration(seconds: 1), curve: Curves.linear);
      } else if (scBoard.offset >=
          scBoard.position.maxScrollExtent &&
          !scBoard.position.outOfRange) {

        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(seconds: 1), curve: Curves.linear);
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
    // connect();

    DonationCommentData.items.clear();

    dataImageSlide();

    getDonationBoardViewData().then((value) {
      ApiResponse apiResponse = ApiResponse();
      apiResponse = value;

      if ((apiResponse.apiError).error == "9") {
        setState(() {
          _initialized = true;
        });
      }
      else {
        Fluttertoast.showToast(
            msg: (apiResponse.apiError).msg ,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 13.0
        );

        Navigator.pop(context);
      }
    });

    dataComment(1, true).then((value) {

      ApiResponse apiResponse = ApiResponse();
      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

      }
      else
      {
        Fluttertoast.showToast(
            msg: (apiResponse.apiError).msg ,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 13.0
        );

        Navigator.pop(context);
      }

    });
  }


    @override
  Widget build(BuildContext context) {

    String url = '${appApiUrl}app-donate_view.php?bo_table=${widget.boTable}&wr_id=${widget.wrId}';

    Size size = MediaQuery.of(context).size;

    // var screenWidth  = size.width;
    // var screenHeight = size.height;
    // debugPrint("url : $url");

    return GestureDetector(
      onTap: () {
        // 키보드 백그라운드 클릭시 사라지게 하기
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("기부", textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 15),),
          backgroundColor: Colors.white,
          // elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                Navigator.pop(context, '${widget.boTable}@@${widget.wrId}@@${widget.like}@@$likeCnt@@$commentCnt'),
            color: Colors.black,
          ),
          actions: <Widget>[

            if(widget.like != "0")
              IconButton(icon: FaIcon((widget.like == "1") ? FontAwesomeIcons.heart : FontAwesomeIcons.solidHeart, size: 16.0),
                color: (widget.like == "1") ? Colors.black : Colors.red,
                onPressed: (){
                  setState(() {
                    if(widget.like == "1") {
                      widget.like = "2";
                    } else if(widget.like == "2") {
                      widget.like = "1";
                    }
                  });

                  // JsonApi.likeFun(widget.boTable, widget.wrId, mbId).then((value){
                  //
                  //   ApiResponse apiResponse = value;
                  //
                  //   if((apiResponse.apiError).error == "9")
                  //   {
                  //
                  //   }
                  //   else
                  //   {
                  //     Fluttertoast.showToast(
                  //         msg: (apiResponse.apiError).msg ,
                  //         toastLength: Toast.LENGTH_LONG,
                  //         gravity: ToastGravity.BOTTOM,
                  //         timeInSecForIosWeb: 1,
                  //         backgroundColor: Colors.red,
                  //         textColor: Colors.white,
                  //         fontSize: 13.0
                  //     );
                  //   }
                  //
                  // });

                },),
            if(widget.share != "0")
              IconButton( icon: const FaIcon(FontAwesomeIcons.share, size: 16.0), color: Colors.black, onPressed: () => {
                JsonApi.shareFun(context, url, "기부")
              }, ),

          ]
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {

        if (!_initialized) {
          return Container(
            color: Colors.white,
            child:const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: SafeArea (
            child:WillPopScope(
              onWillPop: () async {
                Navigator.pop(context, '${widget.boTable}@@${widget.wrId}@@${widget.like}');
                return false;
              },
              child : SingleChildScrollView(
                controller: _scrollController,
                  child: Container(
                    color: const Color(0xFFFFFFFF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 이미지가 공간을 동일하게 나눠 가집니다.
                        children: [

                        ]
                      )
                    )

              )
            ),
          ),
          bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    (selected == "0")
                        ?
                    const SizedBox(height: 0,)
                        :
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
                                    onSendMessage(textEditingController.text, TypeMessage.text);
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
                    ),
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
          ),

        );
      }),
      )
    );
  }

  // 문자전송
  Future<void> sendSms() async {

    ApiResponse apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse('${appApiUrl}app_send_sms.php');

      final response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: <String, String>{
          'mb_id': mbId,
          'bo_table': widget.boTable,
          'wr_id': widget.wrId,
        },
      );

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;
          debugPrint(responseBody);
          // Map<String, dynamic> responseData = json.decode(responseBody);
          apiResponse.apiError = ApiError("9", "");
          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          break;
        default:
          apiResponse.apiError = ApiError("1", "http 상태 에러");
          break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "app_send_sms.php socket error");
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();

      debugPrint('${textEditingController.text} : $content');

      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
      putComment(content);

    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
    }
  }


  // 게시물 상세 정보 가져오기
  Future<ApiResponse> getDonationBoardViewData() async {

    ApiResponse apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse(
          '${appApiUrl}app_board_data.php?app_token$token&bo_table=${widget.boTable}&wr_id=${widget
              .wrId}}&mb_id=$mbId&r=${Random.secure()
              .nextInt(10000)
              .toString()}');
      final response = await http.get(url);

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;

          final responseData = json.decode(responseBody);

          DonationBoardViewData.items = List.from(responseData)
              .map<BoardModel>((item) => BoardModel.fromJson(item))
              .toList();


          if (DonationBoardViewData.items.isNotEmpty) {

            setState(() {
              document = htmlparser.parse(DonationBoardViewData.items[0].wr_content);
            });
          }

          apiResponse.apiError = ApiError("9", "");

          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          break;
        default:
          apiResponse.apiError = ApiError("1", "http 상태 에러");
          break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "app_get_member.php socket error");
    }

    return apiResponse;

  }

  // 사진첩 가져오기
  // Future<void> loadAssets() async {
  //   List<Asset> resultList = <Asset>[];
  //   // String error = '';
  //
  //   try {
  //     resultList = await MultiImagePicker.pickImages(
  //       maxImages: 10,
  //       enableCamera: true,
  //       selectedAssets: imageList,
  //       cupertinoOptions: const CupertinoOptions(
  //         takePhotoIcon: "chat",
  //         doneButtonTitle: "등록",
  //         // autoCloseOnSelectionLimit:false,  //선택 제한에 도달하는 즉시 이미지 선택기가 닫힙니다.
  //       ),
  //       materialOptions: const MaterialOptions(
  //         actionBarColor: "#000000",
  //         // actionBarTitleColor: "#FFFFFF",
  //         actionBarTitle: "사진 가져오기",
  //         allViewTitle: "전체",
  //         useDetailsView: false,
  //         selectCircleStrokeColor: "#000000",
  //       ),
  //     );
  //   } on Exception catch (e) {
  //     error = e.toString();
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //
  //   setState(() {
  //     if(resultList.isNotEmpty)
  //     {
  //       imageList = resultList;
  //     }
  //
  //     // _error = error;
  //     _count = imageList.length;
  //   });
  //
  //   if(_count > 0)
  //   {
  //     Uri url = Uri.parse('${appApiUrl}app_comment_action.php');
  //     var request = http.MultipartRequest('POST', url);
  //     // request.headers.content
  //
  //     request.fields["token"]    = token;
  //     request.fields["mb_id"]    = mbId;
  //     request.fields["bo_table"] = widget.boTable;
  //     request.fields["wr_parent"]    = widget.wrId;
  //
  //     // final dir = await path_provider.getTemporaryDirectory();
  //     // print('dir = $dir');
  //
  //     for (int i = 0; i < imageList.length; i++) {
  //
  //       final tempFile = await getFileFromAsset(imageList[i]);
  //
  //       var pic = await http.MultipartFile.fromPath("bf_file[]", tempFile.path);
  //       // var pic = await http.MultipartFile.fromBytes("bf_file", tempFile.readAsBytesSync());
  //       request.files.add(pic);
  //     }
  //
  //     var res = await request.send();
  //
  //     if (res.statusCode == 200) {
  //       var response = await http.Response.fromStream(res);
  //       final responseData = json.decode(response.body); // json 응답 값을 decode
  //       // print("responseData : $responseData");
  //       // print(responseData['wr_id']);
  //
  //       if(responseData['msg'] == "ok")
  //       {
  //         // connect(responseData['wr_id'].toString());
  //
  //         // ScaffoldMessenger.of(_context)
  //         //   ..removeCurrentSnackBar()
  //         //   ..showSnackBar(SnackBar(content: Text("등록되었습니다")));
  //
  //         // Navigator.pop(_context, responseData);
  //       }
  //       else
  //       {
  //         // ScaffoldMessenger.of(_context)
  //         //   ..removeCurrentSnackBar()
  //         //   ..showSnackBar(SnackBar(content: Text("등록시 문제가 발생되었습니다.")));
  //       }
  //
  //     }else {
  //       // print("status code ${res}");
  //     }
  //
  //
  //   }
  //   else
  //   {
  //     imageList = <Asset>[];
  //   }
  // }

  // Future<File> getFileFromAsset(Asset asset) async {
  //   ByteData byteData = await asset.getThumbByteData(asset.originalWidth!, asset.originalHeight!, quality: 100);
  //
  //   // String _name = TextMode.trimTextAfterLastSpecialCharacter(asset.name, '.');
  //
  //   String name = asset.name.toString();
  //
  //   // print('asset name is : ${asset.name}');
  //
  //   final tempFile = File('${(await getTemporaryDirectory()).path}/$name');
  //   await tempFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  //   await tempFile.create(recursive: true);
  //
  //   File file = tempFile;
  //
  //   return file;
  // }

  // 이용후기 등록
  Future<void> putComment(String wrContent) async {

    ApiResponse apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse(
          '${appApiUrl}app_comment_action.php?r=${Random.secure()
              .nextInt(10000)
              .toString()}');

      final request = http.MultipartRequest('POST', url);
      request.fields["token"]       = token;
      request.fields["mb_id"]       = mbId;
      request.fields["bo_table"]    = widget.boTable;
      request.fields["wr_parent"]   = widget.wrId;
      request.fields["wr_content"]  = wrContent;

      var response = await request.send();

      switch (response.statusCode) {
        case 200:

          var res = await http.Response.fromStream(response);
          var responseBody = res.body;

          Map<String, dynamic> responseData = json.decode(responseBody);

          if (responseData['msg'] == "ok") {
            apiResponse.apiError = ApiError("9", "");

            // const pubTopic = 'notice';
            // final builder = MqttClientPayloadBuilder();
            // builder.addString('new@@comment@@${widget.boTable}@@${responseData['wr_id']}@@${widget.wrId}');
            //
            // client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);
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
      apiResponse.apiError = ApiError("8", "app_comment_action.php socket error");
    }


    if((apiResponse.apiError).error == "9")
    {
      // dataComment(currentPage, true);
    }
    else
    {
      Fluttertoast.showToast(
          msg: "후기 등록시 에러가 발생했습니다. " ,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 13.0
      );
    }

  }

  Future<ApiResponse> dataComment(int page, bool init) async {
    ApiResponse apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse(
          '${appApiUrl}app_board_comment.php?app_token=$token&bo_table=${widget.boTable}&wr_id=${widget.wrId}&mb_id=$mbId'
              '&page=${page.toString()}&r=${Random.secure()
              .nextInt(10000)
              .toString()}');

      debugPrint(url.toString());

      final response = await http.get(url);

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;

          final responseData = json.decode(responseBody);
          // debugPrint('responseBody : $responseBody');

          if((responseData as List).isNotEmpty)
          {
            setState(() {

              if(init == true)
              {
                DonationCommentData.items.clear();

                DonationCommentData.items = List.from(responseData)
                    .map<CommentModel>((item) => CommentModel.fromJson(item))
                    .toList();
              }
              else
              {
                DonationCommentData.items += List.from(responseData)
                    .map<CommentModel>((item) => CommentModel.fromJson(item))
                    .toList();
              }
            });

          }

          // scBoard.animateTo(scBoard.position.maxScrollExtent + 110.0, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
          apiResponse.apiError = ApiError("9", "");
          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          break;
        default:
          apiResponse.apiError = ApiError("1", "http 상태 에러");
          break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "app_board_comment.php socket error");
    }

    return apiResponse;
  }


  // Future<MqttServerClient> connect() async {
  //   client =
  //       MqttServerClient.withPort('driver.cloudmqtt.com', 'app_${Random.secure().nextInt(10000) * 100}' , 18749);
  //
  //   client.logging(on: true);
  //   client.onConnected = onConnected;
  //   client.onDisconnected = onDisconnected;
  //
  //   try {
  //     await client.connect('ccsfssyj', '-UJ0-kP8Wr8h');
  //   } catch (e) {
  //     debugPrint('mqtt Exception: $e');
  //     client.disconnect();
  //   }
  //   // print('app_' + (random.nextInt(90) * 10).toString());
  //
  //   const pubTopic = 'notice';
  //   client.subscribe(pubTopic, MqttQos.exactlyOnce);
  //
  //   client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
  //     final recMess = c![0].payload as MqttPublishMessage;
  //     final pt =
  //     MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  //
  //     /// The above may seem a little convoluted for users only interested in the
  //     /// payload, some users however may be interested in the received publish message,
  //     /// lets not constrain ourselves yet until the package has been in the wild
  //     /// for a while.
  //     /// The payload is a byte buffer, this will be specific to the topic
  //     debugPrint(
  //         'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
  //
  //     final split = pt.split("@@");
  //
  //     if(split[0] == "del")
  //     {
  //       if(split[2] == widget.boTable &&  split[3] == widget.wrId)
  //       {
  //         dataComment(currentPage, true);
  //       }
  //     }
  //     else
  //     {
  //       if(split[2] == widget.boTable &&  split[4] == widget.wrId)
  //       {
  //         dataComment(currentPage, true);
  //       }
  //     }
  //
  //   });
  //
  //   return client;
  //
  // }

  void onConnected() {
    // print('Connected');
  }

  void onDisconnected()
  {
    // print('Disconnected');
  }


  @override
  void dispose() {
    // client.disconnect();
    scBoard.dispose();
    _scrollController.dispose();
    super.dispose();
  }


}


