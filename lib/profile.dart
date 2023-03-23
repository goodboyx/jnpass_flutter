import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/member.dart';
import 'package:http/http.dart' as http;

late String likestate = "";
late Member user;

class Profile extends StatefulWidget {
  String userId;

  Profile({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  void initState () {
    super.initState();
    _init();
  }

  Future<void> _init () async {
    Uri url = Uri.parse('${appApiUrl}app_get_user.php?app_token=$token&user_id=${widget.userId}');

    var response = await http.get(url);
    var responseBody = response.body;
    final responseData = json.decode(responseBody); // json 응답 값을 decode

    user = Member.fromJson(responseData);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("사용자 프로필", textAlign: TextAlign.center,
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
        return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
        children: [

          SizedBox(
            height: 115,
            width: 115,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: const [
                CircleAvatar(
                backgroundImage: AssetImage("assets/images/profile.png"),
                backgroundColor: Colors.transparent,
                ),
              ]
            )
          ),
          const SizedBox(height: 5),
          user.mb_name.isEmpty ? Container() : Text(user.mb_name),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.fromLTRB(40.0, 8.0, 40.0, 0.0),
            child: Divider(
              color: Color(0xff78909c),
              height: 0.0,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                onPressed: () {
                  debugPrint("차단하기");
                },
                height: 40.0,
                minWidth: 140.0,
                color: Colors.blue,
                child: const Text(
                  "차단하기",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),),
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                onPressed: () {
                  debugPrint("신고하기");
                },
                height: 40.0,
                minWidth: 140.0,
                color: Colors.red,
                child: const Text(
                  "신고하기",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              )
            ],
          ),
          ]
          )
        );
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}


