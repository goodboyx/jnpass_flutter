import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jnpass/pages/block_page.dart';
import 'package:jnpass/pages/location.dart';
import 'package:jnpass/pages/notice_page.dart';
import 'package:jnpass/pages/userpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/jsonapi.dart';
import '../common.dart';
import '../constants.dart';
import '../models/apiResponse.dart';
import '../util.dart';
import '../widgets/profile_list_item.dart';
import 'cert_page.dart';
import 'login_page.dart';
import 'share.dart';

GetIt getIt = GetIt.instance;
final TextEditingController textEditingController = TextEditingController();
final FocusNode focusNode = FocusNode();

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();

}

class ProfilePageState extends State<ProfilePage> {
  late SharedPreferences prefs;

  late dynamic mbData;
  bool isLoading = false;
  String mb_nick = '';

  late String meLoc;
  late String location = "지역 선택";
  late int areaPositon =  0;

  late bool _isChecked = true;
  XFile? _pickedFile;
  String mbImg = "";

  late bool profileUpdate = false;

  @override
  void initState() {
    super.initState();

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
            isLoading = true;
            mbData = responseData['data'];

            if(mbData['mb_id'] == null || mbData['mb_nick'] == null)
            {
              prefs.remove('jwt_token');

              Navigator.of(context,rootNavigator: true).push(
                MaterialPageRoute(builder: (context) =>
                const LoginPage()),).then((value){

              });
            }
            else
            {
              mb_nick = mbData['mb_nick'];
              textEditingController.text = mb_nick;
              mbImg = '$mbImgUrl/${mbData['mb_id']}/${mbData['mb_img']}';

              reloadData();
            }
          }
          else
          {
            prefs.remove('jwt_token');

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

    });

  }

  reloadData() async {

    setState(() {
        meLoc  = prefs.getString('me_loc') ?? '0';

        if(meLoc != "0")
        {
          areaPositon = areaList.indexWhere((element) => element["id"] == meLoc);
          debugPrint("areaPositon : $areaPositon");

          setState(() {
            if(areaPositon != -1)
            {
              location = areaList[areaPositon]['val'];
            }
          });
        }
    });

  }

  @override
  Widget build(BuildContext context) {

    if (!isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
        onWillPop: () async {
          debugPrint('profile close');
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: const Text("설정", textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'SCDream', color: Colors.black, fontSize: 15),),
              backgroundColor: Colors.white,
              elevation: 0.0,
              shape: const Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              leadingWidth: 70,
              leading: (profileUpdate == true)
                  ?
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 0, bottom: 10),
                child: MaterialButton(
                  minWidth:50,
                  color: const Color(0xFFE97031),
                  onPressed: () {
                    setState(() {
                      profileUpdate = false;
                    });
                  },
                  child: const Text('취소', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                ),
              )
                  :
              TextButton(
                onPressed: () {
                },
                child: const Text('',
                  style: TextStyle(color: Colors.black, fontSize: 13),),
              )
              ,
              actions: <Widget>[
                (profileUpdate == true)
                ?
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 0, right: 10, bottom: 10),
                  child: MaterialButton(
                    minWidth:50,
                    color: const Color(0xFF98BF54),
                    onPressed: () {
                      uploadAction();
                    },
                    child: const Text('수정완료', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                  ),
                )
                :
                const SizedBox(),
              ]
          ),
          body: Builder(builder: (BuildContext context) {
            return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          SizedBox(
                              height: 85,
                              width: 85,
                              child: Stack(
                                  fit: StackFit.expand,
                                  clipBehavior: Clip.none,
                                  children: [
                                    if (_pickedFile != null)
                                      CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: FileImage(File(_pickedFile!.path))
                                      )
                                    else if(mbData['mb_img'] != "")
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: NetworkImage(mbImg),
                                      )
                                    else
                                      const CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage("assets/images/profile.png")
                                      )
                                    ,

                                    Positioned(
                                      right: -30,
                                      top: -20,
                                      child: SizedBox(
                                        height: 70,
                                        width: 70,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context, rootNavigator: true).push(
                                                MaterialPageRoute(builder: (context) => const CertPage())
                                            );

                                          },
                                          child: Image.asset("assets/images/cert.png", fit:BoxFit.fitWidth, colorBlendMode: BlendMode.darken),
                                        ),
                                      ),
                                    ),

                                    (profileUpdate == true)
                                        ?
                                    Positioned(
                                      right: -16,
                                      bottom: 0,
                                      child: SizedBox(
                                        height: 46,
                                        width: 46,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                              side: const BorderSide(color: Colors.white),
                                            ),
                                            backgroundColor: const Color(0xFFF5F6F9),
                                          ),
                                          onPressed: () {
                                            _showBottomSheet();
                                          },
                                          child: SvgPicture.asset("assets/images/icon_camera.svg"),
                                        ),
                                      ),
                                    )
                                        :
                                    Container(),
                                  ]
                              )
                          ),
                          const SizedBox(width: 30),
                          Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  (profileUpdate == false)
                                    ?
                                    // mb_nick.isEmpty ? Container() : Text('${mb_nick} (${mb.gr_subject})')
                                    mb_nick.isEmpty
                                      ?
                                      Container()
                                      :
                                      Row(
                                        children: [
                                          Text(mb_nick,
                                              style: const TextStyle(
                                                color: Color(0xFF191919),
                                                fontFamily: 'SCDream',
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              )
                                          ),
                                          const SizedBox(width: 10),
                                          MaterialButton(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                                            onPressed: () {
                                            },
                                            height: 20.0,
                                            minWidth: 40.0,
                                            color: const Color(0xFFE2EFD5),
                                            child: Text(
                                              mbData['gr_subject'],
                                              style: const TextStyle(
                                                color: Color(0xFF446C1B),
                                                fontFamily: 'SCDream',
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                      :
                                    Container(
                                      margin: const EdgeInsets.only(top:5),
                                      width: 200.0,
                                      height: 35.0,
                                      // padding: const EdgeInsets.only(left: 10),
                                      alignment: Alignment.center,
                                      child: TextField(
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          // height: 3.5,
                                        ),
                                        onSubmitted: (value) {

                                        },
                                        controller: textEditingController,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          hintText: "",
                                          // hintStyle: TextStyle(color: ColorConstants.greyColor),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                            borderSide: BorderSide(width: 1.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black54),
                                          ),
                                        ),
                                        focusNode: focusNode,
                                      )
                                  )
                                  ,

                                  (profileUpdate == true)
                                      ?
                                  const SizedBox()
                                      :
                                  Row(
                                    children: [
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                                        minWidth:40,
                                        onPressed: () {
                                          setState(() {
                                            profileUpdate = true;
                                          });
                                          debugPrint("프로필수정");
                                        },
                                        height: 25.0,
                                        color: kColor,
                                        child: const Text(
                                          "프로필수정",
                                          style: TextStyle(color: Colors.white, fontSize: 13.0, fontFamily: 'SCDream', fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10,),
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                                        minWidth:40,
                                        height: 25.0,
                                        color: const Color(0xFFCBCBCB),
                                        onPressed: () {
                                          prefs.remove('jwt_token');

                                          Navigator.of(context,rootNavigator: true).push(
                                            MaterialPageRoute(builder: (context) =>
                                            const LoginPage()),).then((value){

                                          });
                                        },
                                        child: const Text('로그아웃', style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'SCDream', fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  )
                                ]
                              )
                            ],
                          )
                        ],
                      ),
                      // Text(mbData['mb_id']),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 10, left: 20, right: 20),
                        child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Divider(
                                    thickness: 1,
                                    color: Color(0x80CBCACA),
                                  ),
                                  const SizedBox(height: 15,),
                                  const Text("나의 SOS",
                                      style: TextStyle(
                                        color: kColor,
                                        fontFamily: 'SCDream',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      )
                                  ),
                                  const SizedBox(height: 10,),
                                  InkWell(
                                    onTap: () async {
                                      getLocation();
                                    },
                                    child: Text("지역선택 (${location})",
                                      style: const TextStyle(
                                        // color: kColor,
                                        fontFamily: 'SCDream',
                                        fontSize: 13.0,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ),
                                  const SizedBox(height: 10,),
                                  InkWell(
                                      onTap: () async {
                                        Navigator.of(context,rootNavigator: true).push(
                                          MaterialPageRoute(builder: (context) =>
                                          const SharePage()),).then((value){
                                        });
                                      },
                                      child: const Text("나의 상담내역",
                                        style: TextStyle(
                                          // color: kColor,
                                          fontFamily: 'SCDream',
                                          fontSize: 13.0,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      )
                                  ),
                                  const SizedBox(height: 15,),
                                  const Divider(
                                    thickness: 1,
                                    color: Color(0x80CBCACA),
                                  ),
                                  const Text("정보변경",
                                      style: TextStyle(
                                        color: kColor,
                                        fontFamily: 'SCDream',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      )
                                  ),
                                  const SizedBox(height: 10,),
                                  InkWell(
                                      onTap: () async {
                                        Navigator.of(context,rootNavigator: true).push(
                                          MaterialPageRoute(builder: (context) =>
                                          const UserPage()),);
                                      },
                                      child: const Text("개인정보변경",
                                        style: TextStyle(
                                          // color: kColor,
                                          fontFamily: 'SCDream',
                                          fontSize: 13.0,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      )
                                  ),
                                  const SizedBox(height: 15,),
                                  const Divider(
                                    thickness: 1,
                                    color: Color(0x80CBCACA),
                                  ),
                                  const Text("기타",
                                      style: TextStyle(
                                        color: kColor,
                                        fontFamily: 'SCDream',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      )
                                  ),
                                  const SizedBox(height: 10,),
                                  Text("어플버전 ${mbData['mb_app_ver']}",
                                        style: const TextStyle(
                                          // color: kColor,
                                          fontFamily: 'SCDream',
                                          fontSize: 13.0,
                                          // fontWeight: FontWeight.bold,
                                        )
                                  ),
                                  const SizedBox(height: 10,),
                                  InkWell(
                                      onTap: () async {
                                        Util.launchKaKaoChannel();
                                      },
                                      child: const Text("고객센터",
                                        style: TextStyle(
                                          // color: kColor,
                                          fontFamily: 'SCDream',
                                          fontSize: 13.0,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      )
                                  ),
                                  const SizedBox(height: 10,),
                                  InkWell(
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const BlockPage()),
                                        );
                                      },
                                      child: const Text("치딘사용자목록",
                                        style: TextStyle(
                                          // color: kColor,
                                          fontFamily: 'SCDream',
                                          fontSize: 13.0,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      )
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: <Widget>[
                                      // const Icon(FontAwesomeIcons.bell,
                                      //   size: 14,
                                      // ),
                                      const Text("알림설정",
                                        style: TextStyle(
                                          // color: kColor,
                                          fontFamily: 'SCDream',
                                          fontSize: 13.0,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Switch(
                                        value: _isChecked,
                                        onChanged: (value) async {

                                          setState(() {
                                            _isChecked = value;
                                          });

                                          Uri url = Uri.parse('${appApiUrl}app_push_state.php');
                                          var request = http.MultipartRequest('POST', url);
                                          // request.headers.content

                                          request.fields["token"] = token;
                                          request.fields["mb_id"] = mbData['mb_id'];
                                          if(_isChecked == true)
                                          {
                                            request.fields["mb_app"] = 'Y';
                                          }
                                          else
                                          {
                                            request.fields["mb_app"] = 'N';
                                          }

                                          var res = await request.send();

                                          if (res.statusCode == 200) {
                                            var response = await http.Response.fromStream(res);
                                            final responseData = json.decode(response.body); // json 응답 값을 decode
                                            debugPrint("responseData : $responseData");
                                          }

                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10,),
                                  InkWell(
                                      onTap: () async {
                                        _showDialog();
                                      },
                                      child: const Text("회원탈퇴",
                                        style: TextStyle(
                                          // color: kColor,
                                          fontFamily: 'SCDream',
                                          fontSize: 13.0,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      )
                                  ),
                                ]
                              )
                      ),
                    ]
                )
            );
          }),
        )
    );
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

  _getCameraImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File rotatedImage = await FlutterExifRotation.rotateAndSaveImage(path: pickedFile!.path);

      setState(() {
        _pickedFile = XFile(rotatedImage.path);
      });

    } else {
      debugPrint('이미지 선택안함');
    }
  }

  _getPhotoLibraryImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {

      File rotatedImage = await FlutterExifRotation.rotateAndSaveImage(path: pickedFile!.path);

      setState(() {
        _pickedFile = XFile(rotatedImage.path);
      });

    } else {
      debugPrint('이미지 선택안함');
    }
  }

  Future<bool> uploadAction() async {

    var uri = Uri.https(domainUrl, "/rest/member_profile");
    var request = http.MultipartRequest('POST', uri);

    debugPrint('mb_img_path : ${_pickedFile!.path}');
    var pic  = await http.MultipartFile.fromPath("mb_img", _pickedFile!.path);
    // var pic = await http.MultipartFile.fromBytes("bf_file", tempFile.readAsBytesSync());
    request.files.add(pic);

    request.fields["jwt_token"]  = jwtToken;
    request.fields["mb_nick"]    = textEditingController.text;

    var res = await request.send();

    if (res.statusCode == 200) {
      var response = await http.Response.fromStream(res);

      final responseData = json.decode(response.body); // json 응답 값을 decode

      // if(kDebug)
      // {
        debugPrint("responseData : $responseData");
      // }

      if(responseData['code'].toString() == "0")
      {
        setState(() {
          jwtToken = responseData['jwt_token'];
          prefs.setString('jwt_token', jwtToken);
          mb_nick = textEditingController.text;
          profileUpdate = false;
        });
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

    }else {
      // print("status code ${res}");
    }

    return true;
  }



  // 이미지 삭제 경고창
  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Text('탈퇴를 하시겠습니까? 탈퇴시 회원포인트은 삭제가 됩니다.'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () async {

                final parameters = {"jwt_token": jwtToken};
                JsonApi.postApi("rest/delete/member", parameters).then((value) {
                  ApiResponse apiResponse = ApiResponse();

                  apiResponse = value;

                  if((apiResponse.apiError).error == "9") {

                    final responseData = json.decode(apiResponse.data.toString());
                    debugPrint('data ${apiResponse.data}');


                    if(responseData['code'].toString() == "0") {
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

                      Navigator.pop(context);
                      prefs.remove('jwt_token');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
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

  Future<void> getLocation() async {

    // 지역설정 한후 새로고침 해야 함
    prefs.reload();
    meLoc  = prefs.getString('me_loc') ?? '0';

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Location(meLoc: meLoc,)),
    ).then((value) async {

      if(value != null)
      {
        areaPositon = areaList.indexWhere((element) => element["id"] == value);
        debugPrint("areaPositon : $areaPositon");

        setState(() {
          if(areaPositon != -1)
          {
            location = areaList[areaPositon]['val'];
          }
        });

        prefs.setString('me_loc', value);

        // 회원 지역 업데이트 한 후 부모 지역 데이타 새로 고침
        Uri url = Uri.parse('${appApiUrl}app_update_location.php');
        var request = http.MultipartRequest('POST', url);
        // request.headers.content

        request.fields["mb_id"] = prefs.getString('mb_id')!;
        request.fields["me_loc"] = value;

        debugPrint("${prefs.getString('mb_id')!} : $value");

        var res = await request.send();

        if (res.statusCode == 200) {
          if(meLoc != value)
          {
            // debugPrint('location change');
          }

        }
      }

    });
  }


  @override
  void dispose() {

    super.dispose();
  }

}