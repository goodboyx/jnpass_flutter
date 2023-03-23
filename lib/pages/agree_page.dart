
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/apiError.dart';
import '../models/apiResponse.dart';
import 'package:flutter_html/flutter_html.dart';

class AgreePage extends StatefulWidget {

  const AgreePage({Key? key}) : super(key: key);

  @override
  AgreePageState createState() => AgreePageState();
}

class AgreePageState extends State<AgreePage> with TickerProviderStateMixin {
  late TabController tabController;
  late String privacy;
  late String stipulation;
  bool initialized = false;

  @override
  void initState() {
    tabController = TabController(
      length: 2,
      vsync: this,  //vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
    );

    reloadData();

    super.initState();
  }

  Future<void> reloadData() async {

    ApiResponse apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse(
          '${appApiUrl}app_private.php');
      final response = await http.get(url);

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;
          Map<String, dynamic> responseData = json.decode(responseBody);

          if(mounted) {
            setState(() {
              privacy = responseData['privacy'];
              stipulation = responseData['stipulation'];
              initialized = true;
            });
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
      apiResponse.apiError = ApiError("8", "app_member_group_cate.php socket error");
    }

  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('steps :  ${steps.getStep()} ');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("이용약관", textAlign: TextAlign.center,
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
        body:
          (!initialized)
          ?
          Container(
            color: Colors.white,
            child:const Center(
              child: CircularProgressIndicator(),
            ),
          )
          :
          Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide( // POINT
                      color: Color(0xFFDDDDDD),
                      width: 1.0,
                    ),
                  ),
                ),
                child: TabBar(
                  tabs: [
                    Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: const Text(
                      '이용약관',
                    ),
                  ),
                    Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: const Text(
                      '개인정보 수집 및 이용',
                    ),
                  ),
                  ],
                  indicator: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide( // POINT
                        color: Colors.black54,
                        width: 3.0,
                      ),
                    ),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black,
                  controller: tabController,
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Html(
                          data: stipulation),
                      )
                    ),
                    SingleChildScrollView(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Html(
                            data: privacy),
                      )
                    )
                  ],
                ),
              ),
            ]
          ),
        )
    );


  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}