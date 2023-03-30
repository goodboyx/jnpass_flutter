
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jnpass/models/member.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'models/apiError.dart';
import 'models/apiResponse.dart';

class Util {

  // static String currencyFormat(int price) {
  //   final formatCurrency = NumberFormat.simpleCurrency(locale: "ko_KR", name: "", decimalDigits: 0);
  //   return formatCurrency.format(price);
  // }

  // String -> Map<String, dynamic> 으로 컨버터
  // {link: /v01/1, click_action: FLUTTER_CLICK_ACTION}
  static Map<String,dynamic> jsonStringToMap(String data){
    List<String> str = data.replaceAll("{","").replaceAll("}","").replaceAll("\"","").replaceAll("'","").split(",");
    Map<String,dynamic> result = {};
    for(int i=0;i<str.length;i++){
      List<String> s = str[i].split(":");
      result.putIfAbsent(s[0].trim(), () => s[1].trim());
    }
    return result;
  }

  static String convertStringToUnicode(String content) {
    String regex = "\\u";
    int offset = content.indexOf(regex) + regex.length;
    while(offset > 1){
      int limit = offset + 4;
      String str = content.substring(offset, limit);
//     print(str);
      if(str!=null && str.isNotEmpty){
        String uni = String.fromCharCode(int.parse(str,radix:16));


        content = content.replaceFirst(regex+str,uni);
//       print(content);

      }
      offset = content.indexOf(regex) + regex.length;
//     print(offset);
    }
    return content;

  }

  static launchKaKaoChannel() async {

    // intent://plusfriend/talk/chat/338155965#Intent;scheme=kakaoplus;package=com.kakao.talk;end

    if (Platform.isAndroid) {
      var intent = const AndroidIntent(
          data: 'kakaoplus://plusfriend/talk/chat/338155965',
          action: 'action_view',
          package: 'com.kakao.talk'
      );

      intent.launch();
    }
    else
    {
      Uri url = Uri.parse("http://pf.kakao.com/_yaylK/chat");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Fluttertoast.showToast(
            msg: "연결 실패 관리자에게 문의 부탁드립니다.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 13.0
        );
      }
    }
  }

  static Future<ApiResponse> loginCheck(String mbId) async {
    late SharedPreferences prefs;

    ApiResponse apiResponse = ApiResponse();

      SharedPreferences.getInstance().then((value) {
        prefs = value;
      });

      if(mbId == "")
      {
        apiResponse.apiError = ApiError("1", "회원아이디가 없습니다.");
        return apiResponse;
      }

      try {
        Uri url = Uri.parse(
            '${appApiUrl}app_get_member.php?mb_id=$mbId&r=${Random.secure()
                .nextInt(10000)
                .toString()}');
        final response = await http.get(url);

        switch (response.statusCode) {
          case 200:
            var responseBody = response.body;

            if(responseBody != null)
            {
              final responseData = json.decode(responseBody);
              // debugPrint('responseBody : $responseBody');

              if(responseData['gr_id'] == null)
              {
                apiResponse.apiError = ApiError("2", "회원이 존재하지 않습니다.");
              }
              else if(responseData['mb_id'] != "")
              {
                prefs.setString('mb_id', responseData['mb_id']);
                prefs.setString('me_loc', responseData['me_loc']);
                apiResponse.data = Member.fromJson(responseData);
                apiResponse.apiError = ApiError("9", "회원인증완료");
              }
              else
              {
                apiResponse.apiError = ApiError("2", "회원이 존재하지 않습니다.");
              }
            }
            break;
          case 401:
            apiResponse.apiError = ApiError("4", "401");
            break;
          default:
            apiResponse.apiError = ApiError("1", "http 상태 에러");
            break;
        }
      } on SocketException {
        apiResponse.apiError = ApiError("8", "app_get_member.php socket error");
      }

      return apiResponse;
    /*
      if(mbId == "")
      {
        msg = '1';
        return msg;
      }
      else {
        Uri url = Uri.parse(
            '${apiUrl}app_get_member.php?mb_id=$mbId&r=${Random.secure()
                .nextInt(10000)
                .toString()}');
        var response = await http.get(url);

        if (response.statusCode == 200) {
          //decode_JSON_data
          var responseBody = response.body;

          if (responseBody != "") {
            final responseData = json.decode(responseBody);
            debugPrint(responseData['mb_id']);

            if(responseData['mb_id'] == "")
            {
              msg = '3';
            }
            else
            {
              msg = '9';
            }
          }
        }
        else {
          msg = '2';
          return msg;
        }
      }
    });

    while(true)
    {
      if(msg != '')
      {
        return msg;
      }
    }
    */
  }
}