import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/jsonapi.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import '../widgets/google_map.dart';

class ConsultWrite extends StatefulWidget {

  const ConsultWrite({Key? key})
      : super(key: key);

  @override
  ConsultWriteState createState() => ConsultWriteState();

}

class ConsultWriteState extends State<ConsultWrite> {
  late SharedPreferences prefs;
  String jwtToken = '';

  LocationData? _location;
  String? _error;
  int _count = 0;        // 이미지 갯수
  int _locChk = 0;       // 장소제공 허용여부
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hpCcontroller = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  List<String> f = [];
  String currentSelectedValue = "0";
  late BuildContext _context;
  bool writeState = false;
  String? lat = '';
  String? log = '';

  List<XFile> imageList = [];
  final ImagePicker _picker = ImagePicker();


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
          debugPrint('data ${apiResponse.data} ${responseData['code']}');

          if(responseData['code'].toString() == "0")
          {
            // mbData = responseData['data'];
            // mb_nick = mbData['data']['mb_nick'];
            // textEditingController.text = mb_nick;
            //
            // reloadData();
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

    });

    getLocation();
    super.initState ();

  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        // Size size = MediaQuery.of(context).size;

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: const Text('온라인 상담', textAlign: TextAlign.center,
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
                          if(writeState == false) {
                            uploadAction();
                          }
                        },
                        child: const Text('등록', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                      ),
                    ),
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
                                        _showBottomSheet()
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

                                            return Card(
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5)),
                                                child: Stack(
                                                    children: [
                                                      Container(
                                                        width: 70.0,
                                                        height: 90.0,
                                                        padding: const EdgeInsets.only(top: 5),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(0.0),
                                                          child: FadeInImage(
                                                            placeholder: const AssetImage("assets/images/profile.png"),
                                                            image: FileImage(File(imageList[index].path)),
                                                            imageErrorBuilder:
                                                                (context, error, stackTrace) {
                                                              return Image.asset(
                                                                  'assets/images/profile.png',
                                                                  fit: BoxFit.fitWidth);
                                                            },
                                                          ),
                                                        ),
                                                      ),
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

                        (jwtToken.isEmpty)
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
                                TextField(
                                  controller: nameController,
                                  // minLines: 6,
                                  // maxLines: 8,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration.collapsed(hintText: "이름을 입력해주세요."),
                                ),
                              ),
                            ),
                          ],
                        )
                        :
                        const SizedBox(height: 0,),
                        (jwtToken.isEmpty)
                        ?
                        // 전화번호
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
                                  controller: hpCcontroller,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration.collapsed(hintText: "전화번호를 입력해주세요."),
                                ),
                              ),
                            ),
                          ],
                        )
                        :
                        const SizedBox(height: 0,),
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
            )
        );
      }),
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

  _showBottomSheet() {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              child: TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  _getCameraImage();
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    elevation: 2,
                    backgroundColor: const Color(0XFF98BF54)),
                label: const Text(
                  '사진찍기',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              child: TextButton.icon(
                icon: const Icon(Icons.photo_library),
                onPressed: () {
                  _getPhotoLibraryImage();
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    elevation: 2,
                    backgroundColor: const Color(0XFF52A4DA)),
                label: const Text('사진 불러오기',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  // 사진 찍기
  _getCameraImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File rotatedImage = await FlutterExifRotation.rotateAndSaveImage(path: pickedFile!.path);

      setState(() {
        imageList.add(XFile(rotatedImage.path));
        _count = imageList.length;
      });

    } else {
      debugPrint('이미지 선택안함');
    }
  }

  // 사진 라이브러리 가져오기
  _getPhotoLibraryImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        imageList += images;
        _count = imageList.length;
      });
    }
  }

  // 등록완료
  Future<bool> uploadAction() async {

    if(jwtToken.isEmpty)
    {
      if(nameController.text == "")
      {
        Fluttertoast.showToast(
            msg: "이름을 등록해주세요" ,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 13.0
        );

        return false;
      }

      if(hpCcontroller.text == "")
      {
        Fluttertoast.showToast(
            msg: "전화번호을 등록해주세요" ,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 13.0
        );

        return false;
      }
    }

    setState(() {
      writeState = true;
    });

    prefs.reload();
    String wr_1 = prefs.getString('me_loc') ?? "";

    var uri = Uri.https(domainUrl, "/rest/board/share");
    var request = http.MultipartRequest('POST', uri);

    request.fields["jwt_token"]  = jwtToken;
    request.fields["wr_1"]       = wr_1;
    request.fields["wr_2"]       = _locChk.toString();
    request.fields["wr_3"]       = lat.toString();
    request.fields["wr_4"]       = log.toString();
    request.fields["wr_name"]    = nameController.text;
    request.fields["wr_5"]       = hpCcontroller.text;
    request.fields["wr_content"] = await json.decode(json.encode(_controller.text));

    for (int i = 0; i < imageList.length; i++) {
      var pic = await http.MultipartFile.fromPath("bf_file[]", imageList[i].path);
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


  @override
  void dispose() {

    super.dispose();
  }
}