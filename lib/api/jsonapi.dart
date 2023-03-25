import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../models/apiError.dart';
import '../models/apiResponse.dart';
import '../constants.dart';

class JsonApi {

  // get API
  static Future<ApiResponse> getApi(String link, Map<String, dynamic>? parameters) async {

    ApiResponse apiResponse = ApiResponse();

    try {

      var uri = Uri.https(domainUrl, "/$link", parameters);

      debugPrint('get api ${uri.toString()}');

      final response = await http.get(uri);

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;
          apiResponse.state = true;
          apiResponse.data = responseBody;
          apiResponse.apiError = ApiError("9", "");
          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          apiResponse.state = true;
          break;
        default:
          apiResponse.apiError = ApiError(response.statusCode.toString(), "http 상태 에러");
          apiResponse.state = true;
          break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "$link socket error");
      apiResponse.state = true;
    }

    return apiResponse;
  }

  // post API
  static Future<ApiResponse> postApi(String link, Map<String, dynamic>? parameters) async {

    ApiResponse apiResponse = ApiResponse();

    try {

      var uri = Uri.https(domainUrl, "/$link");

      debugPrint('post api ${uri.toString()}');

      final response = await http.post(
          uri,
          headers: <String, String> {
            // "Accept": "application/json",
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: parameters,
          // body: json.encode(parameters),
          encoding:Encoding.getByName('utf-8')
      );


      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;
          apiResponse.data = responseBody;
          apiResponse.apiError = ApiError("9", "");
          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          break;
        default:
          apiResponse.apiError = ApiError("1", "${response.statusCode} http 상태 에러");
        break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "$link socket error");
    }

    return apiResponse;
  }

  // delete API
  static Future<ApiResponse> deleteApi(String link, Map<String, dynamic>? parameters) async {

    ApiResponse apiResponse = ApiResponse();

    try {

      var uri = Uri.https(domainUrl, "/$link");

      debugPrint('delete api ${uri.toString()}');

      final response = await http.delete(
          uri,
          headers: <String, String> {
            // "Accept": "application/json",
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: parameters,
          // body: json.encode(parameters),
          encoding:Encoding.getByName('utf-8')
      );


      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;
          apiResponse.data = responseBody;
          apiResponse.apiError = ApiError("9", "");
          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          break;
        default:
          apiResponse.apiError = ApiError("1", "http 상태 에러");
          break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "$link socket error");
    }

    return apiResponse;
  }

  // 회원그룹 카테고리 가져오기
  static Future<ApiResponse> getMemberGroupCategory() async {

    ApiResponse apiResponse = ApiResponse();

    try {
      Uri url = Uri.parse(
          '${appApiUrl}app_member_group_cate.php?app_token$token&r=${Random.secure()
              .nextInt(10000)
              .toString()}');
      final response = await http.get(url);

      switch (response.statusCode) {
        case 200:
          var responseBody = response.body;

          Map<String, dynamic> responseData = json.decode(responseBody);
          debugPrint('responseBody : $responseBody');

          apiResponse.data = responseData['data'];
          // Map<String, dynamic> decodedData = json.decode(response.body);
          apiResponse.apiError = ApiError("9", "");
          break;
        case 401:
          apiResponse.apiError = ApiError("4", "401");
          break;
        default:
          apiResponse.apiError = ApiError("1", "http 상태 에러");
          break;
      }
    } on SocketException {
      apiResponse.apiError = ApiError("8", "app_member_group_cate.php socket error");
    }

    return apiResponse;
  }


  // 공유하기 클릭시
  static void shareFun(BuildContext context, String url, String title)
  async {

    final box = context.findRenderObject() as RenderBox?;

    await Share.share(url,
        subject: title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  Future<bool> fetchData() async {
    bool data = false;

    // Change to API call
    await Future.delayed(const Duration(seconds : 1), () {
      data = true;
    });

    return data;
  }

}