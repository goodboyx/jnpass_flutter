import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../widgets/google_map.dart';

class SosForm extends StatefulWidget {
  String wrId;

  SosForm({Key? key, required this.wrId})
      : super(key: key);

  @override
  SosFormState createState() => SosFormState();

}

class SosFormState extends State<SosForm> {
  List<Asset> imageList = <Asset>[];

  LocationData? _location;
  String? _error;

  late SharedPreferences prefs;
  late String mbId;
  int _count = 0;        // 이미지 갯수
  int _locChk = 1;       // 장소제공 허용여부
  final TextEditingController _controller = TextEditingController();
  List<String> f = [];
  String currentSelectedValue = "0";
  late BuildContext _context;
  bool writeState = false;
  String? lat = '';
  String? log = '';

  @override
  void initState () {

    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      mbId = prefs.getString('mb_id') ?? '';

      if(mbId == "")
      {
        Fluttertoast.showToast(
            msg: "회원정보가 잘못되었습니다." ,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 13.0
        );

        Navigator.pop(_context);
      }

    });

    getLocation();

    super.initState ();

  }

  @override
    Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: const Text('SOS 호출', textAlign: TextAlign.center,
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

                    TextButton(
                      onPressed: () {
                        if(writeState == false) {
                          uploadAction();
                        }
                      },
                      child: Text((widget.wrId == "") ? (writeState == false) ? '등록' : '등록중' : (writeState == false) ? '수정' : '등록중',
                        style: const TextStyle(color: Colors.black, fontSize: 15),),
                    )

                  ]
              ),
              resizeToAvoidBottomInset: false,  //정의된 스크린 키보드에 의해 스스로 크기를 재조정
              body: SafeArea (
                child : GestureDetector(
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
                        crossAxisAlignment : CrossAxisAlignment.start,
                        children: <Widget> [
                          Container(
                            margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 0, right: 15.0),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                contentPadding: const EdgeInsets.all(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: currentSelectedValue,
                                  isDense: true,
                                  isExpanded: true,
                                  items: <String>['0', '1', '2']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text({'0': '카테고리선택','1': '생활불편', '2': '위기사항'}[value] ?? '카테고리 선택'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      currentSelectedValue = newValue!;
                                      // print(currentSelectedValue);
                                    });
                                  },
                                  hint: const Text("카테고리 선택"),

                                ),
                              ),
                            ),
                          ),
                        ]
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
                                controller: _controller,
                                minLines: 6,
                                maxLines: 8,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration.collapsed(hintText: "내용을 입력해주세요."),
                              ),
                          ),
                        ),
                      ],
                    ),

                    (lat != "" && log != "")
                    ?
                    Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children: <Widget> [
                        Container(
                          margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 0, right: 15.0),
                          child: Row(
                            children: <Widget>[
                              InkWell(
                                onTap: () {

                                  setState(() {
                                    if (_locChk == 0) {
                                      _locChk = 1;
                                    } else {
                                      _locChk = 0;
                                    }
                                  });
                                },
                                child: Icon(_locChk == 1 ? Icons.check_circle : Icons.check_circle_outline),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (_locChk == 0) {
                                      _locChk = 1;
                                    } else {
                                      _locChk = 0;
                                    }
                                  });

                                  // print("click");
                                },
                                child:const Text('장소정보를 허용하시겠습니까?',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    letterSpacing: 1.0
                                  ),
                                ),
                              )

                              ,
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 0, right: 15.0),
                          // Text('Gender:'),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                              contentPadding: const EdgeInsets.all(10),
                            ),
                            child: GoogleMapWidget(lat: lat.toString(), lng: log.toString(), myLocationEnabled: false,)
                          ),
                        ),
                      ],
                    )
                    :
                    Container(),
                  ],
                ),
            ),
          ),
        ),
      );
    }

  Future<void> getLocation() async {
    LocationData? currentLocation;
    final Location location = Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    if(mounted)
    {
      setState(() {
        lat = currentLocation?.latitude.toString();
        log = currentLocation?.longitude.toString();

        debugPrint(' lat : $lat log : $log');
      });
    }

  }

  // 등록완료
  Future<bool> uploadAction() async {

    // ignore: unnecessary_null_comparison
    if(currentSelectedValue == null)
    {
      Fluttertoast.showToast(
          msg: "카테고리를 선택해주세요" ,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 13.0
      );

      return false;
    }

    setState(() {
      writeState = true;
    });

    Uri url = Uri.parse('${appApiUrl}app_board_action.php');
    var request = http.MultipartRequest('POST', url);
    // request.headers.content

    request.fields["token"]    = token;
    request.fields["mb_id"]    = mbId;
    request.fields["ca_name"]    = currentSelectedValue;
    request.fields["wr_2"]       = _locChk.toString();
    request.fields["wr_3"]       = lat.toString();
    request.fields["wr_4"]       = log.toString();
    request.fields["bo_table"]   = "notice";

    request.fields["wr_content"] = await json.decode(json.encode(_controller.text));

    for (int i = 0; i < imageList.length; i++) {

      final tempFile = await getFileFromAsset(imageList[i]);

      /*
      final byteData = await imageList[i].getByteData();
      Directory? motherDirectory = await getExternalStorageDirectory();
      Directory dummyDirectory
      await Directory('${motherDirectory?.path}/dummy')
          .create(recursive: true);

      File convertedFile = File(
        '${dummyDirectory.path}/${DateTime.now()}',
      );

      var bytes = await imageList[i].getByteData();
      await convertedFile.writeAsBytes(bytes.buffer.asUint8List());
      */

      // final _filePath = (await getTemporaryDirectory()).path + '/' + imageList[i].name;
      // print('${dir.absolute.path}/${imageList[i].name}');

      var pic = await http.MultipartFile.fromPath("bf_file[]", tempFile.path);
      // var pic = await http.MultipartFile.fromBytes("bf_file", tempFile.readAsBytesSync());
      request.files.add(pic);
    }

    var res = await request.send();

    if (res.statusCode == 200) {
      var response = await http.Response.fromStream(res);

      final responseData = json.decode(response.body); // json 응답 값을 decode
      // print("responseData : $responseData");
      // print(responseData['wr_id']);

      if(responseData['msg'] == "ok")
      {
        // connect(responseData['wr_id'].toString());

        // ignore: use_build_context_synchronously
        Navigator.pop(_context, responseData);
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

    return true;
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
      if(resultList.isNotEmpty) {
        imageList = resultList;
      }

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
          content: const SingleChildScrollView(
            child: Column(
              children: <Widget>[
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

  // Future<MqttServerClient> connect(String wrId) async {
  //   Random random = Random();
  //
  //   // print('app_' + (random.nextInt(90) * 10).toString());
  //
  //   MqttServerClient client =
  //   MqttServerClient.withPort('driver.cloudmqtt.com', 'app_${random.nextInt(10000) * 100}' , 18749);
  //
  //   client.logging(on: true);
  //   client.onConnected = onConnected;
  //   client.onDisconnected = onDisconnected;
  //
  //   try {
  //     await client.connect('ccsfssyj', '-UJ0-kP8Wr8h');
  //   } catch (e) {
  //     // print('mqtt Exception: $e');
  //     client.disconnect();
  //   }
  //
  //   const pubTopic = 'notice';
  //   final builder = MqttClientPayloadBuilder();
  //   builder.addString('new@@write@@$wrId');
  //
  //   client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);
  //
  //   client.disconnect();
  //   return client;
  // }

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