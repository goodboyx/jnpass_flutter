
// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class FlutterWebview extends StatefulWidget {
  String url;
  String title;

  FlutterWebview(
      {Key? key, required this.url, required this.title})
      : super(key: key);

  @override
  _FlutterWebviewState createState() => _FlutterWebviewState();
}

class _FlutterWebviewState extends State<FlutterWebview> with WidgetsBindingObserver {
  late WebViewController _myController;

  _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();

    // 화면이 다 그려진 다음에 실행
    WidgetsBinding.instance?.addPostFrameCallback((_) {


    });

    WidgetsBinding.instance?.addObserver(this);

  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
          debugPrint('webview close');
          // Navigator.of(context, rootNavigator: true).pop(context);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: Text(widget.title, textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 15),),
              backgroundColor: Colors.white,
              // elevation: 0.0,
              leading: IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(context);
                },
                color: Colors.black,
              ),
              actions: <Widget>[

              ]
          ),
          // We're using a Builder here so we have a context that is below the Scaffold
          // to allow calling Scaffold.of(context) so we can show a snackbar.
          body: Builder(builder: (BuildContext context) {
            // return Container();
            return WebView(
                initialUrl: widget.url,
                onWebViewCreated: (WebViewController webViewController) {
                  _myController = webViewController;
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

                    _launchURL(Uri.parse(request.url));
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
        )
    );
  }

  JavascriptChannel _appJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Print',
        onMessageReceived: (JavascriptMessage message) async {

          final split = message.message.split("@@");

          // print("js : " + message.message);

          if(split[0] == "app_msg_close")
          {

            // ignore: deprecated_member_use
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(split[1])),
            );

          }
        }
    );
  }

  @override
  void dispose() {

    debugPrint('dispose');

    // _FlutterWebviewState();
    super.dispose();
  }

}








