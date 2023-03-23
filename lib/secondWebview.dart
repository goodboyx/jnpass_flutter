import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jnpass/pages/newsForm.dart';
import 'package:jnpass/resultForm.dart';
import 'package:jnpass/pages/userprofile.dart';
import 'package:jnpass/visitForm.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'constants.dart';

late WebViewController _myController;
late String likestate = "";

// final Completer<WebViewController> _controller = Completer<WebViewController>();

// ignore: must_be_immutable
class SecondWebview extends StatefulWidget {
  String url;
  String agent;
  String title;
  String bo_table;
  String wr_id;
  String like;
  String share;
  String singo;
  String modify;

  SecondWebview(
      {Key? key, required this.url, required this.agent, required this.title, required this.bo_table, required this.wr_id, required this.like, required this.share, required this.singo, required this.modify})
      : super(key: key);

  @override
  _SecondWebviewState createState() => _SecondWebviewState();
}

class _SecondWebviewState extends State<SecondWebview> {
  List<Asset> imageList = <Asset>[];
  String _error = 'No Error Dectected';
  int _count = 0;        // 이미지 갯수

  @override
  Widget build(BuildContext context) {

    String _bo_table = widget.bo_table;
    String _wr_id = widget.wr_id;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title, textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 15),),
          backgroundColor: Colors.white,
          // elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () =>
                Navigator.pop(context, widget.bo_table + '@@' + widget.wr_id + '@@' + widget.like),
            color: Colors.black,
          ),
          actions: <Widget>[

            if(widget.like != "0")
                IconButton(icon: FaIcon((widget.like == "1") ? FontAwesomeIcons.heart : FontAwesomeIcons.solidHeart, size: 16.0),
                  color: (widget.like == "1") ? Colors.black : Colors.red,
                  onPressed: () => {
                    like_fun(widget.bo_table, widget.wr_id)
                  },),
            if(widget.share != "0")
              IconButton( icon: FaIcon(FontAwesomeIcons.share, size: 16.0), color: Colors.black, onPressed: () => {
                share_fun(context, widget.url, widget.title)
              }, ),

            if(widget.singo != "0")
              IconButton( icon: FaIcon(FontAwesomeIcons.bullhorn, size: 16.0), color: Colors.black, onPressed: () => {
              _myController.runJavascript('window.app_singo("${widget.bo_table}","${widget.wr_id}", "board")')
              }, ),

            if(widget.modify != "0")
              IconButton( icon: FaIcon(FontAwesomeIcons.edit, size: 16.0), color: Colors.black, onPressed: () => {
                if(widget.bo_table == 'news')
                  news(widget.bo_table, widget.wr_id)
                // _myController.evaluateJavascript('window.app_modify("$_bo_table","$_wr_id")')
              }, ),

          ]
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.url,
          userAgent: widget.agent,
          onWebViewCreated: (WebViewController webViewController) {
            _myController = webViewController;
            // _controller.complete(webViewController);
          },
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>{
            _appJavascriptChannel(context),
          },
          navigationDelegate: (NavigationRequest request) {

            if(request.url.contains("mailto:")) {
              launchUrl(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            else if (request.url.contains("tel:")) {
              launchUrl(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            else if (request.url.startsWith('https://jnpass.org/') || request.url.startsWith('https://safe.ok-name.co.kr/')) {
              // print('blocking navigation to $request}');
              return NavigationDecision.navigate;
            }
            else
            {
              // print('외부 브라우저 to $request.url}');

              launchUrl(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
          },
          onPageStarted: (String url) {
            // print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            // print('Page finished loading: $url');
          },
          gestureNavigationEnabled: false
        );
      }),
    );
  }

  JavascriptChannel _appJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Print',
        onMessageReceived: (JavascriptMessage message) async {

          final split = message.message.split("@@");

          // print("js : " + message.message);

          //휴대폰인증최종 데이타
          if(split[0] == "send_hp_auth") {
            // ignore: deprecated_member_use
            // Scaffold.of(context).showSnackBar(
            //   SnackBar(content: Text(split[1])),
            // );

            Navigator.pop(context, split[1]);
          }
          else if(split[0] == "app_singo_close") {
            String _bo_table = split[1];
            String _wr_id = split[2];

            Navigator.pop(context, "singo@@$_bo_table@@$_wr_id");
          }
          else if(split[0] == "app_msg_close")
          {

            // ignore: deprecated_member_use
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(split[1])),
            );

            bool data = await fetchData();

            if(split[2] == "singo")
            {
              String _bo_table = split[3];
              String _wr_id = split[4];

              Navigator.pop(context, "singo@@$_bo_table@@$_wr_id");
            }
            else
            {
              Navigator.pop(context);
            }
          }
          // 방문결과 호출
          else if(split[0] == "app_visit_form") {

            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  VisitForm(title:'방문결과등록', boTable:'share', wrId:split[1])),
            );

            if(result != "")
            {
              // print("새로고침");
              _myController.runJavascript('window.location.reload()');
            }
          }
          // 처리결과 호출
          else if(split[0] == "app_profile") {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  UserProfile(user_id:split[1])
              )
            );

            if(result == "Y")
            {
              Navigator.pop(context, 'reload');
            }
          }
          // 처리결과 호출
          else if(split[0] == "app_result_form") {

            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  ResultForm(title:'처리결과등록', bo_table:'share', wr_id:split[1])),
            );

            if(result != "")
            {
              // print("새로고침");
              _myController.runJavascript('window.location.reload()');
            }
          }
          // 카메라 호출
          else if(split[0] == "cm_camera") {
            loadAssets();
          }
        }
    );
  }

  Future<void> news(String boTable, String wrId)
  async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          NewsForm(wrId: wrId)),
    );

    if(result != "")
    {
      // print("새로고침");
      _myController.runJavascript('window.location.reload()');
    }
  }

  // 사진첩 가져오기
  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = '';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: imageList,
        cupertinoOptions: const CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "등록",
          // autoCloseOnSelectionLimit:false,  //선택 제한에 도달하는 즉시 이미지 선택기가 닫힙니다.
        ),
        materialOptions: const MaterialOptions(
          actionBarColor: "#000000",
          // actionBarTitleColor: "#FFFFFF",
          actionBarTitle: "사진 가져오기",
          allViewTitle: "전체",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if(resultList.isNotEmpty) {
        imageList = resultList;
      }

      _error = error;
      _count = imageList.length;
    });

    if(_count > 0)
    {
      Uri url = Uri.parse(appApiUrl + 'app_comment_action.php');
      var request = http.MultipartRequest('POST', url);
      // request.headers.content
      final prefs = await SharedPreferences.getInstance();
      String mb_id = prefs.getString('mb_id')  ?? '';

      request.fields["token"]    = token;
      request.fields["mb_id"]    = mb_id;
      request.fields["bo_table"] = widget.bo_table;
      request.fields["wr_parent"]    = widget.wr_id;

      // final dir = await path_provider.getTemporaryDirectory();
      // print('dir = $dir');

      for (int i = 0; i < imageList.length; i++) {

        final tempFile = await getFileFromAsset(imageList[i]);

        var pic = await http.MultipartFile.fromPath("bf_file[]", tempFile.path);
        // var pic = await http.MultipartFile.fromBytes("bf_file", tempFile.readAsBytesSync());
        request.files.add(pic);
      }

      var res = await request.send();

      if (res.statusCode == 200) {
        var response = await http.Response.fromStream(res);
        final responseData = json.decode(response.body); // json 응답 값을 decode
        // print("responseData : $responseData");
        // print(responseData['wr_id']);

        if(responseData['msg'] == "ok")
        {
          put_comment(responseData['wr_id'].toString());

          // ScaffoldMessenger.of(_context)
          //   ..removeCurrentSnackBar()
          //   ..showSnackBar(SnackBar(content: Text("등록되었습니다")));

          // Navigator.pop(_context, responseData);
        }
        else
        {
          // ScaffoldMessenger.of(_context)
          //   ..removeCurrentSnackBar()
          //   ..showSnackBar(SnackBar(content: Text("등록시 문제가 발생되었습니다.")));
        }

      }else {
        // print("status code ${res}");
      }


    }
    else
    {
      imageList = <Asset>[];
    }
  }

  Future<File> getFileFromAsset(Asset asset) async {
    ByteData _byteData = await asset.getThumbByteData(asset.originalWidth!, asset.originalHeight!, quality: 100);

    // String _name = TextMode.trimTextAfterLastSpecialCharacter(asset.name, '.');

    String _name = asset.name.toString();

    // print('asset name is : ${asset.name}');

    final _tempFile = File('${(await getTemporaryDirectory()).path}/${_name}');
    await _tempFile.writeAsBytes(_byteData.buffer.asUint8List(_byteData.offsetInBytes, _byteData.lengthInBytes));
    await _tempFile.create(recursive: true);

    File _file = _tempFile;

    return _file;
  }


  // 좋아요 클릭시
  Future<void> like_fun(String bo_table, String wr_id)
  async {

    setState(() {
      if(widget.like == "1") {
        widget.like = "2";
      } else if(widget.like == "2") {
        widget.like = "1";
      }

    });

    _myController.runJavascript('window.app_like("$bo_table","$wr_id","bbs")');
  }

  Future<MqttServerClient> put_comment(String wr_id) async {
    Random random = Random();

    // print('app_' + (random.nextInt(90) * 10).toString());

    MqttServerClient client =
    MqttServerClient.withPort('driver.cloudmqtt.com', 'app_' + (random.nextInt(10000) * 100).toString() , 18749);

    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    try {
      await client.connect('ccsfssyj', '-UJ0-kP8Wr8h');
    } catch (e) {
      // print('mqtt Exception: $e');
      client.disconnect();
    }

    const pubTopic = 'notice';
    final builder = MqttClientPayloadBuilder();
    builder.addString('new@@comment@@'+ widget.bo_table +'@@' + wr_id);

    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);

    client.disconnect();
    return client;
  }

  void onConnected() {
    // print('Connected');
  }

  void onDisconnected()
  {
    // print('Disconnected');
  }


  Future<void> share_fun(BuildContext context, String url, String title)
  async {

    final box = context.findRenderObject() as RenderBox?;

    await Share.share(url,
        subject: title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  Future<bool> fetchData() async {
    bool data = false;

    // Change to API call
    await Future.delayed(Duration(seconds : 1), () {
      data = true;
    });

    return data;
  }

  @override
  void dispose() {
    super.dispose();
  }

}


