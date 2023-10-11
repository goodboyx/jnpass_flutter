
import 'package:flutter/material.dart';
import 'package:jnpass/pages/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common.dart';
import '../constants.dart';
import '../provider/notiEvent.dart';
import '../pages/consult_page.dart';
import '../pages/share.dart';

class SosAppBar extends StatefulWidget implements PreferredSizeWidget {

  const SosAppBar({Key? key}) : preferredSize = const Size.fromHeight(kToolbarHeight), super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  SosAppBarState createState() => SosAppBarState();
}

class SosAppBarState extends State<SosAppBar> {
  late SharedPreferences prefs;
  late NotiEvent notiEvent;

  @override
  void initState() {
    notiEvent = NotiEvent();

    SharedPreferences.getInstance().then((value) async {
      prefs    = value;

      if(meLoc != "0")
      {
        areaPositon = areaList.indexWhere((element) => element["id"] == meLoc);
        debugPrint("areaPositon : $areaPositon");

        setState(() {
          if(areaPositon != -1)
          {
            location = areaList[areaPositon]['val'];
          }
        });
      }

    });

    super.initState();
  }

  Future<void> getLocation() async {

    // 지역설정 한후 새로고침 해야 함
    prefs.reload();
    meLoc  = prefs.getString('me_loc') ?? '0';

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Location(meLoc: meLoc,)),
    ).then((value) async {

      if(value != null)
      {
        areaPositon = areaList.indexWhere((element) => element["id"] == value);
        debugPrint("areaPositon : $areaPositon");

        setState(() {
          if(areaPositon != -1)
          {
            location = areaList[areaPositon]['val'];
          }
        });

        prefs.setString('me_loc', value);
        debugPrint('지역설정 : $value');
        meLoc = value;
        notiEvent.notify(meLoc);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text("우리동네 SOS", textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'SCDream', color: Colors.black, fontSize: 15),),
      backgroundColor: Colors.white,
      shape: const Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: 1,
        ),
      ),
      elevation: 0.0,
      leadingWidth:   110,
      leading: InkWell(
        onTap: () async {
          getLocation();
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  side: const BorderSide(width: 2, color:Color(0xffF7F7F7)),
                  backgroundColor:const Color(0xffF7F7F7),
                ),
                onPressed: () {
                  getLocation();
                },

                child:  Row(
                    children: <Widget>[
                      // const Icon(Icons.location_on_outlined, color: Colors.black),
                      Text(location,
                          style: const TextStyle(fontFamily: 'SCDream', color: Colors.black, fontSize: 12)),
                      const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.black),
                    ]
                ),
              )
              )
            ]
        )
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Row(
            children: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  side: const BorderSide(width: 2, color:Color(0xffF7F7F7)),
                  backgroundColor:const Color(0xffF7F7F7),
                ),
                onPressed: () {
                  if(jwtToken == "")
                  {
                    Navigator.of(context,rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) =>
                      const ConsultPage()),).then((value){
                    });
                  }
                  else
                  {
                    Navigator.of(context,rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) =>
                      const SharePage()),).then((value){
                    });
                  }

                  // Navigator.pushNamed(context, '/notice');
                  },
                child: const Text('상담내역',style: TextStyle(fontFamily: 'SCDream', color: kPrimaryColor, fontSize: 13, )),
              )
            ],
          ),
        )
      ],
     );
  }

}