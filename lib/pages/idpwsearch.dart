import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:jnpass/constants.dart';
import 'package:pointycastle/digests/md5.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IdpwPage extends StatefulWidget {

  const IdpwPage({Key? key}) : super(key: key);

  @override
  IdpwPageState createState() => IdpwPageState();
}

class IdpwPageState extends State<IdpwPage> {

  @override
  void initState() {
    super.initState();
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
                  title: const Text("아이디 / 비번 찾기", textAlign: TextAlign.center,
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
                        initialUrl: '$apiUrl/app_idpw.php',
                        onWebViewCreated: (WebViewController webViewController) {
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
}