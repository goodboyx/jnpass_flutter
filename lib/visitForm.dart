import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

// ignore: must_be_immutable
class VisitForm extends StatefulWidget {
  String title;
  String boTable;
  String wrId;

  VisitForm(
      {Key? key, required this.title, required this.boTable, required this.wrId})
      : super(key: key);

  @override
  VisitFormState createState() => VisitFormState();

}

class VisitFormState extends State<VisitForm> with WidgetsBindingObserver {
  List<Asset> imageList = <Asset>[];
  String error = 'No Error Dectected';
  int _count = 0;        // 이미지 갯수
  final TextEditingController _controller = TextEditingController();
  List<String> f = [];
  late String currentSelectedValue;  // 카테고리 구분
  late BuildContext _context;
  late SharedPreferences prefs;
  String mbId = "";

  @override
  void initState () {

    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      mbId  = prefs.getString('mb_id') ?? '';

      // if(mbId.isEmpty)
      // {
      //   loginCheck(mbId);
      // }
      // else
      // {
      //   reloadData();
      // }

    });

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
                title: Text(widget.title, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 15),),
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
                      uploadAction();
                    },
                    child: const Text('등록', style: TextStyle(color: Colors.black, fontSize: 15),),
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
                                  items: <String>['', '1', '2']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text({'1': '종료', '2': '전달'}[value] ?? '종료유형선택'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      currentSelectedValue = newValue!;
                                      // print(currentSelectedValue);
                                    });
                                  },
                                  hint: const Text("종료유형선택"),

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
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<bool> uploadAction() async {

    debugPrint('aaa');

    if(currentSelectedValue != "")
    {
      ScaffoldMessenger.of(_context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("종료유형을 선택해주세요")));

      return false;
    }

    Uri url = Uri.parse('${appApiUrl}ajax.sos_end_update.php');
    var request = http.MultipartRequest('POST', url);

    request.fields["token"]    = token;
    request.fields["mb_id"]    = mbId;
    request.fields["ed_type"]    = currentSelectedValue;
    request.fields["bo_table"]   = widget.boTable;
    request.fields["wr_id"]      = widget.wrId;

    request.fields["ed_reason"] = await json.decode(json.encode(_controller.text));

    // final dir = await path_provider.getTemporaryDirectory();
    // print('dir = $dir');


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

      var pic = await http.MultipartFile.fromPath("pf_file[]", tempFile.path);
      // var pic = await http.MultipartFile.fromBytes("bf_file", tempFile.readAsBytesSync());
      request.files.add(pic);
    }

    var res = await request.send();

    if (res.statusCode == 200) {
      var response = await http.Response.fromStream(res);
      // print(response.body);

      try
      {
        final responseData = json.decode(response.body); // json 응답 값을 decode

        if(responseData['msg'] == "ok")
        {
          Fluttertoast.showToast(
              msg: "등록되었습니다." ,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              fontSize: 13.0
          );

          // ignore: use_build_context_synchronously
          Navigator.pop(context, currentSelectedValue.toString());
        }
        else
        {
          Fluttertoast.showToast(
              msg: "등록시 문제가 발생되었습니다." ,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 13.0
          );

        }
      } catch(e) {
        // print("json Error: $e");
      }


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

      debugPrint('err : $error');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if(resultList.isNotEmpty)
      {
        imageList = resultList;
      }

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

  @override
  void dispose() {
    super.dispose();
  }

}