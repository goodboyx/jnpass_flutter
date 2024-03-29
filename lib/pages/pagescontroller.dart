import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jnpass/pages/sosform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get_it/get_it.dart';
import 'package:jnpass/pages/home.dart';
import 'package:jnpass/pages/news.dart';
import 'package:jnpass/pages/profile_page.dart';
import 'package:jnpass/pages/shareview.dart';

import 'notice_page.dart';

GetIt getIt = GetIt.instance;
late AndroidNotificationChannel channel;
/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

int _selectedIndex = 0;
late String mbId = "";


class PagesController extends StatefulWidget {
  const PagesController({Key? key}) : super(key: key);

  @override
  _PagesControllerState createState() => _PagesControllerState();
}

class _PagesControllerState extends State<PagesController> {

  static final GlobalKey<ScaffoldState> globalKey = GlobalKey();
  late final prefs;
  late String bo_table;
  late String appToken;
  late bool typeState = false;

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );


  Widget buildPageView() => PageView(
    controller: pageController,
    physics:const NeverScrollableScrollPhysics(),  // 슬라이드 기능 false
    onPageChanged: (index) {
      pageChanged(index);
    },
    children: const <Widget>[
      HomePage(),
      NoticePage(),
      NoticePage(),
      NewsPage(),
      ProfilePage(),
    ],
  );

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) {
      prefs = value;
      mbId = prefs.getString('mb_id') ?? '';
    });

    bottomTapped(0);
  }

  void pageChanged(int index) {

    setState(() {
      _selectedIndex = index;
    });
  }

  void bottomTapped(int index) {

    if(index != 2)
    {
      setState(() {
        _selectedIndex = index;
      });
      // pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
      pageController.jumpToPage(index);
    }
    else
    {

    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: () {
          // 키보드 백그라운드 클릭시 사라지게 하기
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          key: globalKey,
          body:buildPageView(),
          bottomNavigationBar : BottomNavigationBar(
            //1f1f1f
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,          //Bar의 배경색
            selectedItemColor: const Color(0xff51a5db),   //선택된 아이템의 색상
            unselectedItemColor: const Color(0xff949494), //선택 안된 아이템의 색상
            selectedFontSize: 12,   //선택된 아이템의 폰트사이즈
            unselectedFontSize: 12, //선택 안된 아이템의 폰트사이즈
            currentIndex: _selectedIndex, //현재 선택된 Index
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });

              bottomTapped(index);
              // _myController.loadUrl('$apiUrl/config.php');
            },
            items: [
              const BottomNavigationBarItem(
                label: '홈',
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                label:
                (typeState == true)
                    ? '나눔실천'
                    : '기부'
                ,
                icon: const Icon(FontAwesomeIcons.heart),
              ),
              const BottomNavigationBarItem(
                label: 'SOS 호출',
                icon: Icon(null),
              ),
              const BottomNavigationBarItem(
                label: '동네소식',
                icon: Icon(Icons.library_books),
              ),
              const BottomNavigationBarItem(
                label: '나의활동',
                icon: Icon(Icons.account_circle),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: () {
                // Add your onPressed code here!
                // debugPrint("_selectedIndex : ${_selectedIndex}");
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Wrap(
                      children: [
                        GestureDetector(
                            onTap: () async {
                              // push 할때 클래스에 데이터를 실어서 보냄 arguments:Arguments(arg: "i'm argument")
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    SosForm(wrId:'')),
                              ).then((value) {
                                if(value != null)
                                {
                                  debugPrint('sos : ${value['msg']} : ${value['wr_id']} ' );

                                  // 등록되면 현재 페이지 닫고 상세페이지로 이동
                                  if(value['msg'] == "ok") {

                                    Navigator.pop(context);

                                    Navigator.of(context,rootNavigator: true).push(
                                        MaterialPageRoute(builder: (context) =>
                                            ShareView(wrId:value['wr_id'].toString())));

                                  }
                                }

                                // debugPrint('msg : ${value['msg']}');
                              });

                            },
                            child:
                            (typeState == true)
                                ?
                            const ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('직접등록 - 접수요청하기'),
                            )
                                : Container()
                        ),
                        GestureDetector(
                          onTap: (){
                            launchUrl(Uri.parse('tel: 061-287-8150'));
                          },
                          child: const ListTile(
                            leading: Icon(Icons.call),
                            title: Text('긴급돌봄 061-287-8150'),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            launchUrl(Uri.parse('tel: 061-287-8151'));
                          },
                          child: const ListTile(
                            leading: Icon(Icons.call),
                            title: Text('틈새돌봄 061-287-8151'),
                          ),
                        ),
                      ],
                    );
                  },
                );

              },
              child: Image.asset("assets/images/icon_sos.png", fit:BoxFit.fitWidth, colorBlendMode: BlendMode.darken)
            // color: Color(0xFFFFFFFF),
            // backgroundColor: Colors.green,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        )
    );

  }

}

Future<dynamic> backgroundMessageHandler(RemoteMessage remoteMessage) async {

  debugPrint('Handling a background message ${remoteMessage.messageId}');

  Map<dynamic, dynamic> message = remoteMessage.data;
  if (message.containsKey('data')) {
    // Handle data message
    debugPrint('backgroundMessageHandler message.containsKey(data)');
    // final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    // final dynamic notification = message['notification'];
  }
}
