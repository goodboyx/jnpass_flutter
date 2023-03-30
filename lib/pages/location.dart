import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/jsonapi.dart';
import '../common.dart';
import '../constants.dart';
import '../models/apiResponse.dart';

// ignore: must_be_immutable
class Location extends StatefulWidget {
  String meLoc;

  Location({Key? key, required this.meLoc}) : super(key: key);

  @override
  LocationState createState() => LocationState();
}

class LocationState extends State<Location> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // _context = context;

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("지역설정", textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 15),),
            backgroundColor: Colors.white,
            // elevation: 0.0,
            leading: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 0, bottom: 10),
              child: MaterialButton(
                minWidth:30,
                color: kButtonColor,
                onPressed: () {
                  meLoc = widget.meLoc.toString();

                  final parameters = {"jwt_token": jwtToken, "area": meLoc};
                  JsonApi.postApi("rest/area/member", parameters).then((value) {
                    ApiResponse apiResponse = ApiResponse();

                    apiResponse = value;

                    if((apiResponse.apiError).error == "9") {

                      final responseData = json.decode(apiResponse.data.toString());

                      if(kDebug)
                      {
                        debugPrint('data ${apiResponse.data} ${responseData['code']}');
                      }

                      if(responseData['code'].toString() == "0")
                      {
                        if(responseData['message'] != '')
                        {
                          Fluttertoast.showToast(
                              msg: responseData['message'],
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 13.0
                          );
                        }

                      }
                      else
                      {
                        if(responseData['message'] != '')
                        {
                          Fluttertoast.showToast(
                              msg: responseData['message'],
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 13.0
                          );
                        }

                      }

                    }
                    else
                    {
                      Fluttertoast.showToast(
                          msg: (apiResponse.apiError).msg,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 13.0
                      );
                    }

                  });

                  Navigator.pop(context, meLoc);
                },
                child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
              ),
            ),
            leadingWidth: 70,

          // actions: <Widget>[
            // ]
        ),
        body: Builder(builder: (BuildContext context) {

          var screenWidth = MediaQuery.of(context).size.width;
          // var screenHeight = MediaQuery.of(context).size.height;
          // var _crossAxisCount = ((_screenWidth - 32) / 160).floor(); //컬럼 갯수
          var crossAxisCount = 2; //컬럼 갯수
          var crossAxisSpacing = 15;
          var width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
              crossAxisCount;
          var cellHeight = 50;
          var aspectRatio = width / cellHeight;

          return SafeArea(
            child : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 이미지가 공간을 동일하게 나눠 가집니다.
                children: [
                  Center(
                    child: Column(
                        children: const [
                          Padding(padding: EdgeInsets.only(top:20)),
                          Text("지역은 하나만 선택가능합니다.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black, fontSize: 15),
                          ),
                          // Padding(padding: const EdgeInsets.only(bottom:20)),
                        ]
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: areaList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio),
                    itemBuilder: (context, index) {

                      return GestureDetector(
                          onTap: (){
                            setState(() {
                              widget.meLoc = areaList[index]['id'];
                              debugPrint('${areaList[index]['id']} : ${areaList[index]['val']}');
                            });
                          },
                          child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Color(0xFFC1C1C1),
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              elevation: 0,
                              color: (widget.meLoc == areaList[index]['id']) ? kColor : const Color(0xFFFFFFFF),
                              margin: const EdgeInsets.all(5),
                              // TODO: Adjust card heights (123)
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    // height: 50,
                                    padding: const EdgeInsets.only(top: 15, left: 0, right: 0, bottom: 0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${areaList[index]['val']}',
                                            style: TextStyle(
                                              color: (widget.meLoc == areaList[index]['id']) ? const Color(0xFFFFFFFF) : const Color(0xFFC1C1C1),
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )

                                ],
                              )
                          )
                      );
                    }
                  ),
                  const SizedBox(height: 30),
                ]
              )
            )
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

