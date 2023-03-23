
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jnpass/pages/location.dart';
import 'package:jnpass/provider/locationProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common.dart';
import '../constants.dart';
import '../models/notiEvent.dart';
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

      debugPrint('meLoc $meLoc');
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

        // GetIt.I.get<LocationProvider>().setLocation(meLoc);

        notiEvent.notify(meLoc);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text("우리동네 SOS", textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontSize: 15),),
      backgroundColor: Colors.white,
      // elevation: 0.0,
      leadingWidth:   95,
      leading: InkWell(
        onTap: () async {
          getLocation();
        },
        child: Container(
          width: 90.0,
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(location,
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
              const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.black),
            ]
          )
        )
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            children: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  side: const BorderSide(width: 2, color:Color(0xffDDDDDD)),
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
                child: const Text('상담내역',style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        )
      ],
     );
  }

}