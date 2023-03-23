import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import '../common.dart';
import '../constants.dart';
import '../models/notiEvent.dart';
import '../provider/locationProvider.dart';


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
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: const Text("지역설정", textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 15),),
                backgroundColor: Colors.white,
                // elevation: 0.0,
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left,
                    size: 35,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    meLoc = widget.meLoc.toString();

                    // GetIt.I.get<LocationProvider>().setLocation(meLoc);

                    // 회원 지역 업데이트 한 후 부모 지역 데이타 새로 고침
                    /*
                    Uri url = Uri.parse('${appApiUrl}app_update_location.php');
                    var request = http.MultipartRequest('POST', url);
                    // request.headers.content

                    // request.fields["mb_id"] = prefs.getString('mb_id')!;
                    request.fields["me_loc"] = value;

                    var res = await request.send();

                    if (res.statusCode == 200) {
                      if(meLoc != value)
                      {
                        debugPrint('location change');
                      }
                    }
                    */
                    Navigator.pop(context, widget.meLoc.toString());
                  },
                  color: Colors.black,
                ),
                // actions: <Widget>[
                // ]
            ),
            resizeToAvoidBottomInset: false, //정의된 스크린 키보드에 의해 스스로 크기를 재조정
            body: Builder(builder: (BuildContext context) {

              var screenWidth = MediaQuery.of(context).size.width;
              var screenHeight = MediaQuery.of(context).size.height;
              // var _crossAxisCount = ((_screenWidth - 32) / 160).floor(); //컬럼 갯수
              var crossAxisCount = 2; //컬럼 갯수
              var crossAxisSpacing = 15;
              var width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
                  crossAxisCount;
              var cellHeight = 50;
              var aspectRatio = width / cellHeight;

              var mainHeight = screenHeight - 160;

              if(Platform.isIOS){
                mainHeight = screenHeight - 190;
              }


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
                      Container(
                        height: mainHeight,
                        color: Colors.transparent,
                        child: GridView.builder(
                          shrinkWrap: false,
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
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  elevation: 5,
                                  color: (widget.meLoc == areaList[index]['id']) ? const Color(0xFFA586BC) : const Color(0xFFFFFFFF),
                                  margin: const EdgeInsets.all(5),
                                  // TODO: Adjust card heights (123)
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${areaList[index]['val']}',
                                              style: TextStyle(
                                                color: (widget.meLoc == areaList[index]['id']) ? const Color(0xFFFFFFFF) : const Color(0xFFA586BC),
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            WidgetSpan(
                                                child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(top:12),
                                                        child: Icon(
                                                          FontAwesomeIcons.check,
                                                          color: (widget.meLoc == areaList[index]['id']) ? const Color(0xFFFFFFFF) : const Color(0xFFA586BC),
                                                          size: 13,
                                                        ),
                                                      )
                                                    ]
                                                )
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                )
                              );
                            }
                          )
                        ),
                      const SizedBox(height: 20),
                    ]
                  )
                )
              );
            }
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

