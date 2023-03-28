import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManage{
  /// 카메라 권한 요청
  Future<bool> requestCameraPermission(BuildContext context) async {
    // 권한 요청
    PermissionStatus status = await Permission.camera.request();
    // 결과 확인
    if(!status.isGranted) { // 허용이 안된 경우
      showDialog(
          context: context,
          builder: (BuildContext context) {
            // 권한없음을 다이얼로그로 알림
            return AlertDialog(
              content: Text("권한 설정을 확인해주세요."),
              actions: [
                TextButton(
                    onPressed: () {
                      openAppSettings(); // 앱 설정으로 이동
                    },
                    child: const Text('설정하기')),
              ],
            );
          });
      return false;
    }
    return true;
  }

}