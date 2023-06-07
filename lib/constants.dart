import 'package:flutter/material.dart';

enum BACKEND { Firebase }

/// change this to your own backend type, defaults to firebase
const CURRENT_BACKEND = BACKEND.Firebase;

const APP_STORE_ID = 'net.jnpass';
// const IOS_APP_STORE_ID ='org.jnpass';
const IOS_APP_STORE_ID ='1594171424';

const kPrimaryColor = Color(0xff292929);
const kButtonColor  = Color(0xFFE97031);
const kColor = Color(0xFF98BF54);
const kSecondaryColor = Color(0xFFFE9901);
const kContentColorLightTheme = Color(0xFF1D1D35);
const kContentColorDarkTheme = Color(0xFFF5FCF9);
const kWarninngColor = Color(0xFFF3BB1C);
const kErrorColor = Color(0xFFF03738);
const inProgressColor = Colors.black87;
const todoColor = Color(0xffd1d2d7);

const kDebug = false;

const kDefaultPadding = 20.0;
const kSpacingUnit = 10;

const siteUrl = "https://jnpass.org/";
const mbImgUrl = "https://jnpass.org/data/member_image";
const domainUrl = "jnpass.org";
const apiUrl = "${siteUrl}app/";
const appApiUrl = "${siteUrl}api/";
const token = "AAAAmFO6RTo:APA91bGVZFLakLBCwv7UtBnMOtFahpZ6iKkxZsHrHMSl0Kiqy2RHqib07zPgeR_u4cGAaXJD4_s-xz3GQDsJto-HqtI4fW8PKOrBuMSga6JRMKPhGB6c3mATuxsABqxQmRIzB7yzOuHs";

// 나눔실천 처리 프로세스
const List shareState = [
  {'id':'1','val':'접수대기'},
  {'id':'2','val':'접수완료'},
  {'id':'3','val':'방문완료'},
  {'id':'4','val':'처리대기'},
  {'id':'5','val':'처리완료'},
];

// 나눔실천 처리 프로세스
const List cateStep = [
  {'id':'0','name':'1주일'},
  {'id':'1','name':'1개월'},
  {'id':'2','name':'3개월'},
  {'id':'3','name':'6개월'},
];

enum stepStatus { done, doing, todo }

const List areaList = [
  {'id':'4611000000','val':'목포시'},
  {'id':'4613000000','val':'여수시'},
  {'id':'4615000000','val':'순천시'},
  {'id':'4617000000','val':'나주시'},
  {'id':'4623000000','val':'광양시'},
  {'id':'4671000000','val':'담양군'},
  {'id':'4672000000','val':'곡성군'},
  {'id':'4673000000','val':'구례군'},
  {'id':'4677000000','val':'고흥군'},
  {'id':'4678000000','val':'보성군'},
  {'id':'4679000000','val':'화순군'},
  {'id':'4680000000','val':'장흥군'},
  {'id':'4681000000','val':'강진군'},
  {'id':'4682000000','val':'해남군'},
  {'id':'4683000000','val':'영암군'},
  {'id':'4684000000','val':'무안군'},
  {'id':'4686000000','val':'함평군'},
  {'id':'4687000000','val':'영광군'},
  {'id':'4688000000','val':'장성군'},
  {'id':'4689000000','val':'완도군'},
  {'id':'4690000000','val':'진도군'},
  {'id':'4691000000','val':'신안군'},
];

const List msgList = [
  {'id':'0','val':'회원아이디나 비밀번호가 공백이면 안됩니다.'},
  {'id':'1','val':'가입된 회원아이디가 아니거나 비밀번호가 틀립니다. 비밀번호는 대소문자를 구분합니다.'},
  {'id':'2','val':'회원님의 아이디는 접근이 금지되어 있습니다.'},
  {'id':'3','val':'탈퇴한 아이디이므로 접근하실 수 없습니다.'},
  {'id':'4','val':'data 폴더에 쓰기권한이 없거나 또는 웹하드 용량이 없는 경우 로그인을 못할수도 있으니, 용량 체크 및 쓰기 권한을 확인해 주세요.'},
  {'id':'5','val':'비밀번호는 6자리 이상 입력해주세요.'},
  {'id':'6','val':'비밀번호가 같지 않습니다.'},
  {'id':'7','val':'이메일 양식이 안맞습니다.'},
];


const kTitleTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
);

extension extString on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    // 6자리이고 Vignesh123! : true
    // final passwordRegExp = RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}");
    // 6자리이고 vignesh123! : true
    final passwordRegExp = RegExp(r"^(?=.*?[a-z])(?=.*?[0-9]).{6,}");

    return passwordRegExp.hasMatch(this);
  }

}