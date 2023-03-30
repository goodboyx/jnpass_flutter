import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/google_map.dart';
import '../api/jsonapi.dart';
import '../models/apiResponse.dart';
import '../models/bannermodel.dart';
import '../models/boardmodel.dart';

// ignore: must_be_immutable
class ShareView extends StatefulWidget {
  String wrId;

  ShareView(
      {Key? key, required this.wrId})
      : super(key: key);

  @override
  ShareViewState createState() => ShareViewState();
}

class ShareViewState extends State<ShareView> {
  late final prefs;
  String jwtToken = '';
  bool isLoading = false;
  late dynamic boardData;
  final ScrollController scrollController = ScrollController();

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late final _processes = [
    '접수대기',
    '접수중',
    '처리완료',
  ];

  final ScrollController _scrollController = ScrollController();
  int currentStep = 0;


  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      jwtToken = prefs.getString('jwt_token') ?? "";

      reloadData();
    });

    super.initState();
  }

  void reloadData() {
    boardViewData();
    // 상세페이지 이미지 출력
    boardViewImgData();
  }

  // 게시물 상세 정보 가져오기
  Future<void> boardViewData() async {

    final parameters = {"jwt_token": jwtToken};
    JsonApi.getApi("rest/board/share/${widget.wrId}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data}');
        boardData = responseData;

        if(boardData['code'].toString() == '0')
        {
          if(boardData['wr_6'] == "")
          {
            boardData['wr_6'] = "1";
          }

          setState(() {
            currentStep = int.parse(boardData['wr_6'])-1 ?? 0;
            isLoading = true;
          });

          debugPrint('currentStep ${currentStep}');

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

// 게시물 상세 정보 이미지 가져오기
  Future<void> boardViewImgData() async {
    DonationBannerData.items.clear();

    final parameters = {"jwt_token": jwtToken};
    JsonApi.getApi("rest/image/share/${widget.wrId}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());

        if(responseData['items'].toString() != "null")
        {
          if(List.from(responseData['items']).toList().isNotEmpty) {
            DonationBannerData.items = List.from(responseData['items'])
                .map<BannerModel>((item) => BannerModel.fromJson(item))
                .toList();
          }
        }

        if(mounted)
        {
          setState(() {

          });
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

  @override
  Widget build(BuildContext context) {
    var checkedCount = 1;
    var elements = List<bool>.generate(_processes.length, (i) => i < checkedCount);

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("온라인상담", textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 15),),
          backgroundColor: Colors.white,
          // elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
          ),
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: SafeArea (
            child: SingleChildScrollView(
                controller: _scrollController,
                child:
                  (!isLoading)
                      ?
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                  :
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,

                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 이미지가 공간을 동일하게 나눠 가집니다.
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:10, top:20, right: 10, bottom: 20),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 13,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 3,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: elements
                                  .asMap()
                                  .map((index, isCheked) => MapEntry(
                                index,
                                Column(
                                  children: <Widget>[
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.orange,
                                      ),
                                      alignment: Alignment.center,
                                      width: 30,
                                      height: 30,
                                      child: (index == currentStep)
                                          ? const FaIcon(
                                        FontAwesomeIcons.check,
                                        color: Colors.white,
                                        size: 15,
                                      )
                                          : null,
                                    ),
                                    const SizedBox(height: 8,),
                                    Text(_processes[index]),
                                    const SizedBox(height: 8,),
                                    // (_content.isNotEmpty)
                                    // ?
                                    // Text(_content[index], style: const TextStyle(fontSize: 12))
                                    // :
                                    // const Text(''),
                                  ],
                                ),
                              ))
                                  .values
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      (DonationBannerData.items.isNotEmpty)
                          ?
                      CarouselSlider(
                        options: CarouselOptions(height: 200),
                        items: DonationBannerData.items.toList().map((item) =>
                            Image.network(item.img_src, fit:BoxFit.fitWidth, width: 1000))
                            .toList(),
                      )
                          :
                      Container(),
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: const Color(0xFFC1C1C1),
                          ),
                        ),
                        child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                color: const Color(0xFFC1C1C1),
                                alignment: Alignment.topLeft,
                                child: const Text('접수내용', textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),),
                              ),
                              Container(
                                // padding: const EdgeInsets.all(10.0),
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.only(left: 10.0,
                                    bottom: 15.0,
                                    top: 10.0,
                                    right: 15.0),
                                child: Text(
                                  boardData['wr_content'].toString(), textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),),
                              ),
                              const SizedBox(height: 10,),
                              (boardData['wr_2'].toString() == "1")
                                  ?
                              Container(
                                margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 0, right: 15.0),
                                // Text('Gender:'),
                                child: InputDecorator(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                      contentPadding: const EdgeInsets.all(10),
                                    ),
                                    child: GoogleMapWidget(lat: boardData['wr_3'].toString(), lng: boardData['wr_4'].toString(), myLocationEnabled: false,)
                                ),
                              )
                                  :
                              const SizedBox(height: 20,),
                              (boardData['wr_6'].toString() == "3")
                              ?
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                color: const Color(0xFFC1C1C1),
                                alignment: Alignment.topLeft,
                                child: const Text('답변', textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),),
                              )
                              :
                              const SizedBox(height: 0,),
                              (boardData['wr_6'].toString() == "3")
                              ?
                              Container(
                                // padding: const EdgeInsets.all(10.0),
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.only(left: 10.0,
                                    bottom: 15.0,
                                    top: 10.0,
                                    right: 15.0),
                                child: Text(boardData['wr_8'].toString(), textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),),
                              )
                              :
                              const SizedBox(height: 0,),
                            ]
                        )
                        ,
                      ),

                    ]
                ),


            )
          // bottomNavigationBar: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         mainAxisSize: MainAxisSize.min,
          //         children: <Widget>[
          //           Container(
          //               padding: const EdgeInsets.symmetric(
          //                 horizontal: kDefaultPadding * 0.75,
          //               ),
          //               decoration: BoxDecoration(
          //                 color: kPrimaryColor.withOpacity(0.05),
          //                 borderRadius: BorderRadius.circular(40),
          //               ),
          //               child: Row(
          //                   children: [
          //                     // Icon(
          //                     //   Icons.sentiment_satisfied_alt_outlined,
          //                     //   color: Theme.of(context)
          //                     //       .textTheme
          //                     //       .bodyText1
          //                     //       ?.color
          //                     //       ?.withOpacity(0.64),
          //                     // ),
          //                     const SizedBox(width: kDefaultPadding / 4),
          //                     Expanded(
          //                       child: TextField(
          //                         onSubmitted: (value) {
          //                           debugPrint('${textEditingController.text} : $value');
          //                           // onSendMessage(textEditingController.text, TypeMessage.text);
          //                         },
          //                         controller: textEditingController,
          //                         decoration: const InputDecoration(
          //                           hintText: "메세지를 입력해주세요.",
          //                           // hintStyle: TextStyle(color: ColorConstants.greyColor),
          //                           border: InputBorder.none,
          //                         ),
          //                         focusNode: focusNode,
          //                       ),
          //                     ),
          //                     // Icon(
          //                     //   Icons.attach_file,
          //                     //   color: Theme.of(context)
          //                     //       .textTheme
          //                     //       .bodyText1
          //                     //       ?.color
          //                     //       ?.withOpacity(0.64),
          //                     // ),
          //                     const SizedBox(width: kDefaultPadding / 4),
          //                     // InkWell(
          //                     //     onTap: () async {
          //                     //       loadAssets();
          //                     //     },
          //                     //     child: Icon(
          //                     //       Icons.camera_alt_outlined,
          //                     //       color: Theme.of(context)
          //                     //           .textTheme
          //                     //           .bodyText1
          //                     //           ?.color
          //                     //           ?.withOpacity(0.64),
          //                     //     )
          //                     // ),
          //                   ]
          //               )
          //           ),
          //
          //           ElevatedButton(
          //               onPressed: () {
          //               },
          //               style: ElevatedButton.styleFrom(elevation: 10,
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(30.0),
          //                     side: BorderSide(color: kButtonColor),
          //                   ),
          //               ),
          //               child: Text(_text, style: const TextStyle(fontSize: 13))
          //           ),
          //         ]
          //     )
          // ),
      ),
    );
  }


  @override
  void dispose() {
    // client.disconnect();

    BoardViewImgData.items.clear();
    DonationBannerData.items.clear();
    ShareBoardViewData.items.clear();
    _scrollController.dispose();
    super.dispose();
  }

}


