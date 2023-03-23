// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ResultForm extends StatefulWidget {
  String title;
  String bo_table;
  String wr_id;

  ResultForm(
      {Key? key, required this.title, required this.bo_table, required this.wr_id})
      : super(key: key);

  @override
  _resultFormState createState() => _resultFormState();

}



class _resultFormState extends State<ResultForm> with WidgetsBindingObserver {
  List<Asset> imageList = <Asset>[];
  String _error = 'No Error Dectected';
  int _count = 0;        // 이미지 갯수
  final TextEditingController _controller = TextEditingController();
  List<String> f = [];
  var currentSelectedValue;  // 카테고리 구분
  late BuildContext _context;

  @override
  void initState () {
    super.initState ();

    WidgetsFlutterBinding.ensureInitialized();

    WidgetsBinding.instance.addObserver(this);

  }


  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: Text(widget.title, textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 15),),
                backgroundColor: Colors.white,
                // elevation: 0.0,
                leading: IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () =>
                      Navigator.pop(context),
                  color: Colors.black,
                ),
                actions: <Widget>[

                  TextButton(
                    onPressed: () {
                      UploadAction();
                    },
                    child: Text('등록', style: TextStyle(color: Colors.black, fontSize: 15),),
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
                                      Icon(
                                        FontAwesomeIcons.camera,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      Text(
                                        "사진등록\n$_count / 10",
                                        style: TextStyle(fontSize: 12, height: 1.8, color: Colors.black,),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  label: Text(
                                    '', //'Label',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              side: BorderSide(color: Colors.black12)
                                          )
                                      )
                                  ),

                                ),
                              ),
                              Expanded( child:
                              imageList.isEmpty
                                  ? Container()
                                  : Container(
                                height: 104,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    padding: EdgeInsets.only(top: 2),
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
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
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
                                contentPadding: EdgeInsets.all(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: currentSelectedValue,
                                  isDense: true,
                                  isExpanded: true,
                                  items: <String>['', '2', '3']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text({'2': '종료', '3': '모금'}[value] ?? '종료유형선택'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      currentSelectedValue = newValue!;
                                      // print(currentSelectedValue);
                                    });
                                  },
                                  hint: Container(
                                    child: Text("종료유형선택"),
                                  ),

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
                              contentPadding: EdgeInsets.all(10),
                            ),
                            child:
                            TextField(
                              controller: _controller,
                              minLines: 6,
                              maxLines: 8,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration.collapsed(hintText: "내용을 입력해주세요."),
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

  Future<bool> UploadAction() async {

    if(currentSelectedValue == null)
    {
      ScaffoldMessenger.of(_context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("종료유형을 선택해주세요")));

      return false;
    }

    Uri url = Uri.parse(appApiUrl + 'ajax.sos_end_update.php');
    var request = http.MultipartRequest('POST', url);
    // request.headers.content
    final prefs = await SharedPreferences.getInstance();
    String mb_id = prefs.getString('mb_id')  ?? '';

    request.fields["token"]    = token;
    request.fields["mb_id"]    = mb_id;
    request.fields["ed_type"]    = currentSelectedValue;
    request.fields["bo_table"]   = widget.bo_table;
    request.fields["wr_id"]      = widget.wr_id;

    request.fields["ed_reason"] = await json.decode(json.encode(_controller.text));

    final dir = await path_provider.getTemporaryDirectory();
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
          ScaffoldMessenger.of(_context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text("등록되었습니다.")));

          Navigator.pop(context, responseData);
        }
        else
        {
          ScaffoldMessenger.of(_context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text("등록시 문제가 발생되었습니다.")));
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
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "Fatto",
          // autoCloseOnSelectionLimit:false,  //선택 제한에 도달하는 즉시 이미지 선택기가 닫힙니다.
        ),
        materialOptions: MaterialOptions(
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

      _error = error;
      _count = imageList.length;
    });
  }

  Future<File> getFileFromAsset(Asset asset) async {
    ByteData _byteData = await asset.getThumbByteData(asset.originalWidth!, asset.originalHeight!, quality: 100);

    // String _name = TextMode.trimTextAfterLastSpecialCharacter(asset.name, '.');

    String _name = asset.name.toString();

    // print('asset name is : ${asset.name}');

    final _tempFile = File('${(await getTemporaryDirectory()).path}/${_name}');
    await _tempFile.writeAsBytes(_byteData.buffer.asUint8List(_byteData.offsetInBytes, _byteData.lengthInBytes));
    await _tempFile.create(recursive: true);

    File _file = _tempFile;

    return _file;
  }

  // 이미지 삭제 경고창
  Future<void> _showMyDialog(int _index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('경고'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('이미지를 삭제하시겠습니까?'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {

                setState(() {
                  imageList.removeAt(_index);
                  _count = imageList.length;
                });

                // print('이미지삭제');

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('아니오'),
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