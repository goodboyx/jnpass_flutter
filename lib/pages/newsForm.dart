
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jnpass/common.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import '../DataUtility.dart';
import '../api/jsonapi.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import '../models/bannermodel.dart';
import '../models/boardcategory.dart';


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

  bool isLoading = false;
  bool isLoading2 = false;
  late dynamic mbData;
  late dynamic boardData;
  String selected = "0";

  String w = "";
  List<Uint8List> imageListTemp = <Uint8List>[]; // 신규 이미지 파일 정보 담은 변수
  List<String> _imageListTemp = <String>[];      // 기존 이미지 파일 정보 담은 변수
  List<String> removeListTemp = <String>[];      // 삭제 이미지 파일 정보 담은 변수

  String error = 'No Error Dectected';
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<String> f = [];
  String currentSelectedValue = "1";  // 카테고리 구분

  List<DropdownMenuItem<String>> menuItems = [];

  bool writeState = false;

  int _count = 0;        // 이미지 갯수
  List<XFile> imageList = [];
  final ImagePicker _picker = ImagePicker();


  @override
  void initState () {

    SharedPreferences.getInstance().then((value) async {
      prefs = value;

      reloadData();
    });

    imageListTemp = <Uint8List>[];
    _imageListTemp = <String>[];
    removeListTemp = <String>[];

    if(widget.wrId.isNotEmpty)
    {
      w = "u";
      boardViewData();
      boardViewImgData();
    }
    else
    {
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
          else if(responseData['code'].toString() == "101")
          {
            if(responseData['message'].toString() != "")
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

            Navigator.pop(context);
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

    if (w == "u" && !isLoading && !isLoading2) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                                            Image.memory(asset, width: 100, height: 300, fit: BoxFit.fitWidth),
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
    JsonApi.getApi("rest/board/news/${widget.wrId}", parameters).then((value) async {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data}');
        boardData = responseData;

        if(boardData['code'].toString() == '0')
        {
          isLoading = true;
          subjectController.text = boardData['wr_subject'].toString();
          contentController.text = boardData['wr_content'].toString();
          currentSelectedValue = boardData['ca_name'].toString();

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

  Future<void> boardViewImgData() async {

    final parameters = {"jwt_token": jwtToken};
    JsonApi.getApi("rest/image/news/${widget.wrId}", parameters).then((value) async {
      ApiResponse apiResponse = ApiResponse();

      apiResponse = value;
      DonationBannerData.items.clear();

      if((apiResponse.apiError).error == "9") {

        final responseData = json.decode(apiResponse.data.toString());
        debugPrint('data ${apiResponse.data}');

        if(responseData['code'].toString() == '0')
        {

          DataUtility utility = DataUtility();

          if(responseData['items'].toString() != "null") {
            DonationBannerData.items = List.from(responseData['items'])
                .map<BannerModel>((item) => BannerModel.fromJson(item))
                .toList();

            for(var i =0; i < DonationBannerData.items.length; i++)
            {
              String _url = DonationBannerData.items[i].img_src;

              ByteData bytes = await NetworkAssetBundle(Uri.parse(_url)).load(_url);
              Uint8List image2 = utility.getImageFromByteData(bytes);
              imageListTemp.add(image2);
              _imageListTemp.add(_url);
            }

            isLoading2 = true;
          }

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
      request.fields["w"] = w;
      request.fields["wr_id"]     = widget.wrId;
      request.fields["ca_name"]   = currentSelectedValue;
      request.fields['del_file']  = removeListTemp.toString();
      request.fields["wr_1"]     = meLoc;
      request.fields["wr_subject"] = subjectController.text;
      request.fields["wr_content"] = contentController.text;

      for (int i = 0; i < imageList.length; i++) {
        var pic = await http.MultipartFile.fromPath("bf_file[]", imageList[i].path);
        request.files.add(pic);
      }

      var res = await request.send();

      if (res.statusCode == 200) {
        var response = await http.Response.fromStream(res);

        final responseData = json.decode(response.body); // json 응답 값을 decode

        debugPrint(response.body);

        if(kDebug)
        {
          debugPrint("responseData : $responseData");
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

          Navigator.pop(context, "reload");
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


  @override
  void dispose() {

    super.dispose();
  }



}