import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hex/hex.dart';
import 'package:jnpass/constants.dart';
import 'package:jnpass/hpauth.dart';
import 'package:pointycastle/digests/md5.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ua_client_hints/ua_client_hints.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

late WebViewController _myController;

class RegisPage extends StatefulWidget {

  const RegisPage({Key? key}) : super(key: key);

  @override
  RegisPageState createState() => RegisPageState();
}

class RegisPageState extends State<RegisPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  late SharedPreferences prefs;
  String _userAgent = '';
  String webViewUserAgent = '';

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) {

      prefs = value;

    });

    final Future<String> ua = userAgent();

    ua.then((val) {
      setState(() {
        _userAgent = val;

        if (Platform.isAndroid) {
          webViewUserAgent = '$_userAgent ANDROID_APP';
        } else if (Platform.isIOS) {
          webViewUserAgent = '$_userAgent IOS_APP';
        }

      });
      // int가 나오면 해당 값을 출력
      // print('val: $val');
    }).catchError((error) {
      // error가 해당 에러를 출력
      // print('error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {

    // debugPrint('steps :  ${steps.getStep()} ');

    return WillPopScope(    // <-  WillPopScope로 감싼다.
      onWillPop: () {
        Navigator.pop(context);
        return Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("회원가입", textAlign: TextAlign.center,
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
        body: Builder(builder: (BuildContext context) {
          return SafeArea (
            child: WebView(
                initialUrl: '$apiUrl/app_regis.php',
                userAgent: webViewUserAgent,
                onWebViewCreated: (WebViewController webViewController) {
                  _myController = webViewController;
                },
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: <JavascriptChannel>{
                  _appJavascriptChannel(context),
                },
                navigationDelegate: (NavigationRequest request) async {

                  if (Uri.parse(request.url).scheme == "intent") {
                    String dataIntent = request.url;
                    String packgaeName = request.url.toString().substring(request.url.toString().indexOf('com.skt'), request.url.toString().indexOf(';end'));
                    debugPrint("isAppLink : $dataIntent : $packgaeName");
                    // debugPrint(request.url.toString().substring(request.url.toString().indexOf('com.skt'), request.url.toString().indexOf(';end')));

                    if(Platform.isAndroid)
                    {

                      bool isInstalled = await DeviceApps.isAppInstalled(packgaeName);

                      if(isInstalled)
                      {
                        List link = dataIntent.split('#Intent');
                        debugPrint('dataIntentv : ${link[0]}');

                        // intent://sktauth?agentTID=CB220919110842999827&appToken=20220919jG4jFn1dYpq7
                        // #Intent;
                        // scheme=tauthlink;
                        // action=android.intent.action.VIEW;
                        // category=android.intent.category.BROWSABLE;
                        // package=com.sktelecom.tauth
                        // ;end

                        if (Platform.isAndroid) {

                          final intent = AndroidIntent(
                              data: Uri.encodeFull(link[0]),
                              // scheme: 'tauthlink',
                              action: 'android.intent.action.VIEW',
                              category: 'android.intent.category.BROWSABLE',
                              package: 'com.sktelecom.tauth');
                          intent.launch();
                        }
                      }
                      else
                      {
                        launchUrl(Uri.parse("market://details?id=$packgaeName"));
                      }

                      // https://safe.ok-name.co.kr/CommonSvl
                      return NavigationDecision.prevent;
                    }
                    else
                    {
                      launchUrl(Uri.parse(request.url));
                      return NavigationDecision.navigate;
                    }
                  }
                  else if(request.url.contains("mailto:")) {
                    launchUrl(Uri.parse(request.url));
                    return NavigationDecision.prevent;
                  }
                  else if (request.url.startsWith('https://jnpass.org/')
                      || request.url.startsWith('https://safe.ok-name.co.kr/')
                      || request.url.startsWith('https://www.sktpass.com/')
                      || request.url.startsWith('https://lightwidget.com/')) {
                    // print('blocking navigation to $request}');
                    return NavigationDecision.navigate;
                  }
                  else
                  {
                    debugPrint('외부 브라우저 to $request.url}');

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
            )
          );
        }),
      )
    );
  }

  JavascriptChannel _appJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Print',
        onMessageReceived: (JavascriptMessage message) async {

          final split = message.message.split("@@");

          debugPrint(" js : ${message.message}");

          // 경고창 출력
          if(split[0] == "toaster") {
            // ignore: deprecated_member_use
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(split[1])),
            );
          }
          else if(split[0] == "app_exit") {
            // SystemNavigator.pop();
          }
          else if(split[0] == "win_hp_auth")  // 외부 브라우저로 링크
          {
            // split[1] : 링크주소
            Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) =>
                    const HpAuth())
            ).then((value){
              if(value != null)
              {
                _myController.runJavascript('window.app_hp_auth("$value")');
              }
            });
          }
          else if(split[0] == "regis_ok")  // 회원가입완료
          {
            Codec<String, String> stringToBase64 = utf8.fuse(base64);
            String encoded = stringToBase64.encode(split[1]);

            debugPrint('md5  ${md5(split[1])} : ${split[1]}: $encoded ');

            prefs.setString('org_mb_id', split[1]);
            prefs.setString('mb_id', encoded);

            Fluttertoast.showToast(
                msg: "회원가입 되었습니다.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.orange,
                textColor: Colors.white,
                fontSize: 13.0
            ).then((value){

              Future.delayed(const Duration(milliseconds: 1000), () {
                Navigator.of(context, rootNavigator: true).pop(context);
              });

            });

          }
          //
        }
    );
  }

  static const platform = MethodChannel('이름아무거나');

  Future<String> getAppUrl(String url) async {
    if (Platform.isAndroid) {
      return await platform
          .invokeMethod('getAppUrl', <String, Object>{'url': url});
    } else {
      return url;
    }
  }

  bool isAppLink(String url) {
    final appScheme = Uri.parse(url).scheme;

    return appScheme != 'http' &&
        appScheme != 'https' &&
        appScheme != 'about:blank' &&
        appScheme != 'data';
  }


  md5(String data) {
    var digestObject = MD5Digest();
    var bytes = digestObject.process(convertStringToUint8List(data));
    String digest = HEX.encode(bytes);

    return digest;
  }

  Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  @override
  void dispose() {
    super.dispose();
  }


}