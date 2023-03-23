
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jnpass/common.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DataUtility.dart';
import '../api/jsonapi.dart';
import '../constants.dart';
import '../models/apiError.dart';
import '../models/apiResponse.dart';
import '../models/boardcategory.dart';
import '../models/boardmodel.dart';
import '../models/member.dart';
import '../util.dart';
import 'login_page.dart';

// ignore: must_be_immutable
class NewsForm extends StatefulWidget {
  String wrId;

  NewsForm(
      {Key? key, required this.wrId})
      : super(key: key);

  @override
  NewsFormState createState() => NewsFormState();

}

class NewsFormState extends State<NewsForm> {
  late SharedPreferences prefs;
  String jwtToken = '';

  bool isLoading = false;
  late dynamic mbData;
  late dynamic boardData;
  String selected = "0";
  bool _initialized = false;

  String w = "new";
  List<Asset> imageList = <Asset>[];
  List<Uint8List> imageListTemp = <Uint8List>[]; // 신규 이미지 파일 정보 담은 변수
  List<String> _imageListTemp = <String>[];      // 기존 이미지 파일 정보 담은 변수
  List<String> removeListTemp = <String>[];      // 삭제 이미지 파일 정보 담은 변수

  String error = 'No Error Dectected';
  int _count = 0;        // 이미지 갯수
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<String> f = [];
  String currentSelectedValue = "1";  // 카테고리 구분

  List<DropdownMenuItem<String>> menuItems = [];

  bool writeState = false;

  @override
  void initState () {

    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      jwtToken = prefs.getString('jwt_token') ?? "";

      final parameters = {"jwt_token": jwtToken};
      JsonApi.getApi("rest/jwt_token", parameters).then((value) {
        ApiResponse apiResponse = ApiResponse();

        apiResponse = value;

        if((apiResponse.apiError).error == "9") {

          final responseData = json.decode(apiResponse.data.toString());
          debugPrint('data ${apiResponse.data}');

          if(responseData['code'].toString() == "0")
          {
            mbData = responseData;
            debugPrint('data ${mbData['data']['mb_id']}');

          }


          setState(() {

          });

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

      reloadData();
    });


    imageListTemp = <Uint8List>[];
    _imageListTemp = <String>[];
    removeListTemp = <String>[];

    super.initState ();
  }

  void reloadData() {
    dataBoardCate();
  }

  Future<void> dataBoardCate() async {

    final parameters = {"": ""};
    JsonApi.getApi("rest/board_cate/news", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        if(kDebug)
        {
          debugPrint('data ${apiResponse.data}');
        }

        if(List.from(responseData['items']).toList().isNotEmpty)
        {

          NewsBoardCategoryData.items = List.from(responseData['items'])
              .map<BoardCategory>((item) => BoardCategory.fromJson(item))
              .toList();

          for(var item in NewsBoardCategoryData.items)
          {
            if(item.id.isNotEmpty)
            {
              if(kDebug) {
                debugPrint('${item.name} : ${item.id} ');
              }

              menuItems.add(DropdownMenuItem(
                value: item.id,
                child: Text(item.name),
              ));
            }
          }

          if(mounted)
          {
            setState(() {

            });
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



  @override
  Widget build(BuildContext context) {

    // if (!_initialized) {
    //   return Container(
    //     color: Colors.white,
    //     child: const Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

    return Scaffold(
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        // Size size = MediaQuery.of(context).size;

        return Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: const Text("동네소식", textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 15),),
                backgroundColor: Colors.white,
                // elevation: 0.0,
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      Navigator.pop(context),
                  color: Colors.black,
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 0, right: 10, bottom: 10),
                    child: MaterialButton(
                      minWidth:50,
                      color: const Color(0xFF98BF54),
                      onPressed: () {
                        uploadAction();
                      },
                      child: Text((widget.wrId == "") ? (writeState == false) ? '등록' : '등록중' : (writeState == false) ? '수정' : '수정중',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                    ),
                  )

                ]
            ),
            resizeToAvoidBottomInset: false,  //정의된 스크린 키보드에 의해 스스로 크기를 재조정
            body:GestureDetector(
              // behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,

                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 이미지가 공간을 동일하게 나눠 가집니다.
                  children: [
                    Column(
                      children: [
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            // padding: new EdgeInsets.only(top: 20.0, left: 15),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: TextButton.icon(
                                  onPressed: () => {
                                    loadAssets()
                                  },
                                  icon: Column(
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.camera,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      Text(
                                        "사진등록\n$_count / 10",
                                        style: const TextStyle(fontSize: 12, height: 1.8, color: Colors.black,),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  label: const Text(
                                    '', //'Label',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
                                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              side: const BorderSide(color: Colors.black12)
                                          )
                                      )
                                  ),

                                ),
                              ),
                              Expanded( child:
                              imageList.isEmpty
                                  ? Container()
                                  : SizedBox(
                                height: 104,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    padding: const EdgeInsets.only(top: 2),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imageList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      Asset asset = imageList[index];

                                      return Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15)),
                                          child: Stack(
                                              children: [
                                                AssetThumb(asset: asset, width: 300, height: 300),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      _showMyDialog(index);
                                                    },
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                              ]
                                          )
                                      );
                                    }),

                              ),
                              ),
                            ]
                        ),

                      ],
                    ),
                    Column(
                      children: [
                        imageListTemp.isEmpty
                        ? Container()
                        : Container(
                            padding: const EdgeInsets.only(top: 0, left: 10, bottom: 10),
                            height: 104,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                                padding: const EdgeInsets.only(top: 2),
                                scrollDirection: Axis.horizontal,
                                itemCount: imageListTemp.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Uint8List asset = imageListTemp[index];

                                  return Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)),
                                      child: Stack(
                                          children: [
                                            Image.memory(asset),
                                            // AssetThumb(asset: asset, width: 300, height: 300),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: (){
                                                  _showMyDialog2(index);
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                          ]
                                      )
                                  );
                                }
                            )

                        ),
                      ]
                    ),

                    (NewsBoardCategoryData.items.isNotEmpty)
                    ?
                    Column(
                        crossAxisAlignment : CrossAxisAlignment.start,
                        children: <Widget> [
                          Container(
                            margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 0, right: 15.0),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                contentPadding: const EdgeInsets.all(10),
                              ),
                              child:
                              (NewsBoardCategoryData.items.isNotEmpty)
                              ?
                              DropdownButton(
                                  value: currentSelectedValue.toString(),
                                  isDense: true,
                                  isExpanded: true,
                                  items: menuItems,
                                  onChanged: (newValue) {
                                    if(newValue != null)
                                    {
                                      setState(() {
                                        currentSelectedValue = newValue.toString();
                                      });
                                    }
                                  },
                                  hint: const Text("카테고리 선택"),
                              )
                              :
                              const SizedBox(),
                            ),
                          ),
                        ]
                    )
                    :
                    Container(),
                    Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children: <Widget> [
                        Container(
                          margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 0, right: 15.0),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                              contentPadding: const EdgeInsets.all(10),
                            ),
                            child:
                            TextField(
                              controller: subjectController,
                              // minLines: 6,
                              // maxLines: 8,
                              // keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration.collapsed(hintText: "제목을 입력해주세요."),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children: <Widget> [
                        Container(
                          margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 0, right: 15.0),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                              contentPadding: const EdgeInsets.all(10),
                            ),
                            child:
                            TextField(
                              controller: contentController,
                              minLines: 6,
                              maxLines: 8,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration.collapsed(hintText: "내용을 입력해주세요."),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        );
      }),
    );
  }

  Future<void> boardViewData() async {

    final parameters = {"jwt_token": jwtToken};
    JsonApi.getApi("rest/board/news/${widget.wrId}", parameters).then((value) {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data}');
        boardData = responseData;

        if(boardData['code'].toString() == '0')
        {
          isLoading = true;
        }

        setState(() {

        });

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

  // Future<bool> getBoardData() async {
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   String mbId = prefs.getString('mb_id')  ?? '';
  //   Uri url = Uri.parse('${appApiUrl}app_board_data.php?bo_table=${widget.boTable}&wr_id=${widget.wrId}&mb_id=$mbId');
  //   var response = await http.get(url);
  //   var responseBody = response.body;
  //   final responseData = json.decode(responseBody); // json 응답 값을 decode
  //
  //   debugPrint('----------');
  //   debugPrint(responseBody);
  //   debugPrint('----------');
  //
  //
  //   debugPrint(responseData['wr_subject']);
  //   debugPrint(responseData['wr_content']);
  //   debugPrint(responseData['ca_name']);
  //
  //
  //   return false;
  // }

  // 등록완료
  Future<void> uploadAction() async {

    if(currentSelectedValue == "0")
    {
      Fluttertoast.showToast(
          msg: " 카테고리를 선택해주세요. " ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 13.0
      );
    }
    else {
      setState(() {
        writeState = true;
      });

      var uri = Uri.https(domainUrl, "/rest/board/news");
      var request = http.MultipartRequest('POST', uri);

      request.fields["jwt_token"] = jwtToken;
      request.fields["w"] = "";
      request.fields["ca_name"]   = currentSelectedValue;
      request.fields["wr_id"]     = widget.wrId;
      request.fields['del_file']  = removeListTemp.toString();
      request.fields["wr_1"]     = meLoc;
      request.fields["wr_subject"] = await json.decode(json.encode(subjectController.text));
      request.fields["wr_content"] = await json.decode(json.encode(contentController.text));

      for (int i = 0; i < imageList.length; i++) {
        final tempFile = await getFileFromAsset(imageList[i]);

        var pic = await http.MultipartFile.fromPath("bf_file[]", tempFile.path);
        // var pic = await http.MultipartFile.fromBytes("bf_file", tempFile.readAsBytesSync());
        request.files.add(pic);
      }

      var res = await request.send();

      if (res.statusCode == 200) {
        var response = await http.Response.fromStream(res);

        final responseData = json.decode(response.body); // json 응답 값을 decode

        if(kDebug)
        {
          debugPrint("responseData : $responseData");
        }

        if(responseData['code'].toString() == "0")
        {
          // connect(responseData['wr_id'].toString());
          Navigator.pop(context, responseData);
        }
        else
        {
          Fluttertoast.showToast(
              msg: "등록시 문제가 발생되었습니다." ,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 13.0
          );
        }

        setState(() {
          writeState = false;
        });

      }else {
        // print("status code ${res}");
      }

    }

  }


  Future<ByteData> readNetworkImage(String imageUrl) async {
    final ByteData data =
    await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
    return data;
    // final Uint8List bytes = data.buffer.asUint8List();
    // return bytes;
  }

  Uint8List getImageFromByteData(ByteData data){
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }


  // 사진첩 가져오기
  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = '';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: imageList,
        cupertinoOptions: const CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "등록",
          // autoCloseOnSelectionLimit:false,  //선택 제한에 도달하는 즉시 이미지 선택기가 닫힙니다.
        ),
        materialOptions: const MaterialOptions(
          actionBarColor: "#000000",
          // actionBarTitleColor: "#FFFFFF",
          actionBarTitle: "사진 가져오기",
          allViewTitle: "전체",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      imageList = resultList;

      error = error;
      _count = imageList.length;
    });
  }

  Future<File> getFileFromAsset(Asset asset) async {
    ByteData byteData = await asset.getThumbByteData(asset.originalWidth!, asset.originalHeight!, quality: 100);

    // String _name = TextMode.trimTextAfterLastSpecialCharacter(asset.name, '.');

    String name = asset.name.toString();

    // print('asset name is : ${asset.name}');

    final tempFile = File('${(await getTemporaryDirectory()).path}/$name');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    await tempFile.create(recursive: true);

    File file = tempFile;

    return file;
  }

  // 이미지 삭제 경고창
  Future<void> _showMyDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Text('이미지를 삭제하시겠습니까?'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {

                setState(() {
                  imageList.removeAt(index);
                  _count = imageList.length;
                });

                // print('이미지삭제');

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialog2(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Text('이미지를 삭제하시겠습니까 ?'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {

                setState(() {
                  imageListTemp.removeAt(index);

                  debugPrint('vvvvv ${_imageListTemp[index]} ');

                  removeListTemp.add(_imageListTemp[index]);
                  _imageListTemp.removeAt(index);
                });

                // print('이미지삭제');

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<MqttServerClient> connect(String wrId, String w) async {
    // print('app_' + (random.nextInt(90) * 10).toString());

    MqttServerClient client =
    MqttServerClient.withPort('driver.cloudmqtt.com', 'app_${Random.secure().nextInt(10000) * 100}' , 18749);

    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    try {
      await client.connect('ccsfssyj', '-UJ0-kP8Wr8h');
    } catch (e) {
      // print('mqtt Exception: $e');
      client.disconnect();
    }

    const pubTopic = 'notice';
    final builder = MqttClientPayloadBuilder();
    // builder.addString('$w@@write@@${widget.boTable}@@$wrId');

    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);

    client.disconnect();
    return client;
  }

  void onConnected() {
    // print('Connected');
  }

  void onDisconnected()
  {
    // print('Disconnected');
  }

  @override
  void dispose() {

    super.dispose();
  }



}