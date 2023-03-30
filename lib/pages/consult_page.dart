import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jnpass/pages/password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/jsonapi.dart';
import '../models/apiResponse.dart';
import '../models/csmodel.dart';

class ConsultPage extends StatefulWidget {

  const ConsultPage( {Key? key}) : super(key: key);

  @override
  ConsultPageState createState() => ConsultPageState();
}

class ConsultPageState extends State<ConsultPage> {
  late SharedPreferences prefs;
  final TextEditingController stxController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;
  int page = 1;
  int totalPage = 1;
  int limit = 8;

  @override
  void initState () {
    SharedPreferences.getInstance().then((value) async {
      prefs = value;
    });

    scrollController.addListener(() {
      if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
        // if (scBoard.position.pixels ==
        //     scBoard.position.maxScrollExtent) {

        debugPrint('$totalPage : $page ');

        setState(() {
          if(totalPage > page) {
            isLoading = true;
          }
          else
          {
            // isLoading = false;
          }

          if (isLoading) {
            // 화면 끝에 닿았을 때 이루어질 동작
            page = page + 1;

            if(totalPage < limit) {
              page = totalPage;
            }
            else
            {
              dataConsult(page, false);
            }

          }
        });

      }
    });

    dataConsult(page, false);
    super.initState();
  }

  void dataConsult(int page, bool init) {
    CsData.items.clear();

    final parameters = {"stx": stxController.text , "page": "1", "limit": limit.toString() };
    JsonApi.getApi("rest/cs/nomember", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        // if(kDebug)
        // {
          debugPrint('data ${apiResponse.data}');
        // }

        if(responseData['code'].toString() == "0")
        {
          CsData.items.clear();

          if(List.from(responseData['items']).toList().isNotEmpty)
          {
            CsData.items = List.from(responseData['items'])
                .map<CsModel>((item) => CsModel.fromJson(item))
                .toList();

            totalPage = responseData['total_page'];

            if(mounted)
            {
              setState(() {
              });
            }
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
  }

  Color getColor(String state) {
    //red is just a sample color
    Color color;
    if(state == "" || state == "1") {
      color = const Color(0xFF52A4DA);
    } else if(state == "2") {
      color = const Color(0xFFE97031);
    } else if(state == "3") {
      color = const Color(0xFF98BF54);
    }
    else {
      color = const Color(0xFF52A4DA);
    }

    return color;
  }


  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // var _crossAxisCount = ((_screenWidth - 32) / 160).floor(); //컬럼 갯수
    var crossAxisCount = 1; //컬럼 갯수
    var crossAxisSpacing = 8;
    var width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
        crossAxisCount;
    var cellHeight = 65;
    var aspectRatio = width / cellHeight;

    var mainHeight = screenHeight - 220;

    if(Platform.isIOS){
      mainHeight = screenHeight - 190;
    }

    return Scaffold (
      appBar: AppBar(
        centerTitle: true,
        title: const Text("상담내역", textAlign: TextAlign.center,
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
      body: SafeArea (
        child: SingleChildScrollView(
          controller: _scrollController,
          child: GestureDetector(
          // behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 15, bottom: 0),
                child: const Text('상담내역 최근 2개월만 제공되며', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF626363)),),
              ),
              const Text('지난 상담내역 카톡으로 통해서 문의 해주세요', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF626363)),),
              Container(
                margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 20, right: 15.0),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: const BorderSide(color: Color(0xFF98BF54), width: 2.0)),
                    contentPadding: const EdgeInsets.only(left:15, top: 5, bottom: 0, right: 5),
                  ),
                  child:
                  TextField(
                    controller: stxController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '이름을 검색해 주세요',
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFF98BF54),
                        ),
                        onPressed: () {
                          dataConsult(1, false);
                        },
                      )
                    ),

                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection:Axis.vertical,
                child: Container(
                  height: mainHeight,
                  color: Colors.transparent,
                  child: GridView.builder(
                      shrinkWrap: false,
                      controller: scrollController,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: CsData.items.length,
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio),
                      itemBuilder: (context, index) {
                        return Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(0),
                            // ),
                            elevation: 1,
                            margin: const EdgeInsets.only(left: 15, top: 3, right:15, bottom: 6),
                            // TODO: Adjust card heights (123)
                            child: Column(
                              // TODO: Center items on the card (123)
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.fromLTRB(0.0,0.0, 0.0, 0.0),
                                      child: Column(
                                            // TODO: Center items on the card (123)
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 16.0, 0.0),
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context,rootNavigator: true).push(

                                                              MaterialPageRoute(builder: (context) =>
                                                              PasswordPage(wrId:CsData.items[index].wr_id))).then((value) {
                                                            setState(() {

                                                            });
                                                          });
                                                        },
                                                        child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            // TODO: Change innermost Column (123)
                                                            children: <Widget>[
                                                              SizedBox (
                                                                  width: screenWidth - 140,
                                                                  child: Column(
                                                                      children: <Widget>[
                                                                        Align(alignment: Alignment.topLeft,
                                                                            child: RichText(
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                              text: TextSpan(
                                                                                  text: CsData.items[index].wr_content,
                                                                                  style: const TextStyle(
                                                                                      color: Colors.black,
                                                                                      height: 1.4,
                                                                                      fontSize: 14.0)),
                                                                            )
                                                                        ),
                                                                        const SizedBox(height: 5,),
                                                                        Align(alignment: Alignment.topLeft,
                                                                            child:
                                                                            Row(
                                                                              children: [
                                                                                const Icon(Icons.lock, color: Color(0xFF8E8E8E), size: 13 ),
                                                                                Text(" ${CsData.items[index].wr_name}    ${CsData.items[index].wr_date}", style: const TextStyle(color: Color(0xFF8E8E8E), fontSize: 13),)
                                                                              ],
                                                                            )
                                                                        ),
                                                                      ]
                                                                  )
                                                              ),
                                                                Flexible(
                                                                    child:
                                                                    Align(alignment: Alignment.topRight,
                                                                        child: Container (
                                                                            width: 90,
                                                                            padding: const EdgeInsets.only(left:0.0),
                                                                              child: MaterialButton(
                                                                                minWidth:40,
                                                                                height: 25,
                                                                                color: getColor(CsData.items[index].wr_6),
                                                                                onPressed: () {
                                                                                },
                                                                                child: Text(CsData.items[index].state, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                                                                              ),
                                                                            ),
                                                                    ))

                                                            ]
                                                        )
                                                    )
                                                )
                                              ]
                                          )

                                          // child: Column(
                                          //     crossAxisAlignment: CrossAxisAlignment.center,
                                          //     children: <Widget>[
                                          //       SizedBox (
                                          //           width: screenWidth,
                                          //           child: Row(
                                          //               children: [
                                          //                 Padding(
                                          //                   padding: const EdgeInsets.only(top: 0, left: 0, right: 5, bottom: 0),
                                          //                   child: MaterialButton(
                                          //                     minWidth:50,
                                          //                     height: 25,
                                          //                     color: const Color(0xFFE97031),
                                          //                     onPressed: () {
                                          //                     },
                                          //                     child: const Text('접수대기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                                          //                   ),
                                          //                 ),
                                          //                 SizedBox(
                                          //                   width: 100,
                                          //                   height: 25,
                                          //                   child: Align(alignment: Alignment.topLeft,
                                          //                       child: Text(CsData.items[index].wr_date)
                                          //                   ),
                                          //                 ),
                                          //                 // RichText(
                                          //                 //   overflow: TextOverflow.ellipsis,
                                          //                 //   // maxLines: 2,
                                          //                 //   text: TextSpan(
                                          //                 //       text: CsData.items[index].wr_content,
                                          //                 //       style: const TextStyle(
                                          //                 //           color: Colors.black,
                                          //                 //           height: 1.4,
                                          //                 //           fontSize: 16.0,
                                          //                 //           fontFamily: 'NanumSquareRegular')),
                                          //                 // ),
                                          //                 SizedBox(
                                          //                   width: 60,
                                          //                   child: Align(alignment: Alignment.topRight,
                                          //                       child: Text(CsData.items[index].wr_date)
                                          //                   ),
                                          //                 ),
                                          //               ]
                                          //           )
                                          //       ),
                                          //
                                          //       // AspectRatio(
                                          //       //   aspectRatio: 20 / 11,
                                          //       //   child: GestureDetector(
                                          //       //       child: Image.network(CsData.items[index].thum, fit:BoxFit.fitWidth, width: screenWidth),
                                          //       //
                                          //       //   )
                                          //       // )
                                          //     ]
                                          // )
                                      )
                                ]
                            )
                        );
                      }
                  )
              ),
              )
              ],
            )
          )
        )
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}