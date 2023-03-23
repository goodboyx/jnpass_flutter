import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'constants.dart';

// 스키마 및 주소
// [PASS-SKT] tauthlink://
// [PASS-KTF] ktauthexternalcall://
// [PASS-LGT] upluscorporation://

class HpAuth extends StatefulWidget {

  const HpAuth({Key? key}) : super(key: key);

  @override
  HpAuthState createState() => HpAuthState();
}

class HpAuthState extends State<HpAuth> {
  bool initialized = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("휴대폰본인인증", textAlign: TextAlign.center,
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
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return WebView(
            initialUrl: '${siteUrl}plugin/okname/hpcert1.php',
            onWebViewCreated: (WebViewController webViewController) {
              // _controller.complete(webViewController);
            },
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: <JavascriptChannel>{
              _appJavascriptChannel(context),
            },
            navigationDelegate: (NavigationRequest request) async {
              if (Uri.parse(request.url).scheme == "intent") {

                String dataIntent = request.url;

                String packgaeName = dataIntent.substring(dataIntent.indexOf('package='), dataIntent.indexOf(';end'));
                List<String>? urlName = packgaeName.split('package=');
                packgaeName = urlName[1];

                String scheme = dataIntent.substring(dataIntent.indexOf('scheme='), dataIntent.indexOf(';action'));
                urlName = scheme.split('scheme=');
                scheme = urlName[1];

                debugPrint('packgaeName $packgaeName scheme $scheme');

                if(Platform.isAndroid)
                {
                  bool isInstalled = await DeviceApps.isAppInstalled(packgaeName);
                  // 설치되어 있다면 android intent 으로 앱 실행
                  if(isInstalled)
                  {
                    debugPrint('설치 $dataIntent');

                    List link = dataIntent.split('#Intent');
                    List dataUrl = link[0].split('intent://');

                    if (Platform.isAndroid) {

                      final intent = AndroidIntent(
                        data: '$scheme://${dataUrl[1]}',
                          action: 'action_view',
                          category: 'android.intent.category.BROWSABLE',
                          package: packgaeName
                      );

                      intent.launch();
                    }
                  }
                  else
                  {
                    debugPrint('마켓으로 이동');
                    // 마켓에서 인증하면 다시 본인인증을 해야 함..
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);

                    if(Platform.isAndroid) {
                      Uri url = Uri.parse("market://details?id=$packgaeName");

                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        Fluttertoast.showToast(
                            msg: "연결 실패 관리자에게 문의 부탁드립니다.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.orange,
                            textColor: Colors.white,
                            fontSize: 13.0
                        );
                      }

                    }
                  }

                  return NavigationDecision.prevent;
                }
                else
                {
                  // _launchURL(request.url);
                  return NavigationDecision.navigate;
                }
              }
              else if (Uri.parse(request.url).scheme == "itms-appss") {
                launchUrl(Uri.parse(request.url));
              }

              // print('blocking navigation to $request}');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              // print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Page finished loading: $url');
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

          debugPrint("js2 : ${message.message}");

          //휴대폰인증최종 데이타
          if(split[0] == "send_hp_auth") {
            Navigator.pop(context, split[1]);
          }
          else if(split[0] == "close") {
            Navigator.pop(context);
          }
        }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }


}


