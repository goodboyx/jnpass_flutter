import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';

/// 클래스가 시리얼라이저가 필요하다고 알려주는 어노테이션입니다.
@JsonSerializable(explicitToJson: true)
class Member with ChangeNotifier, DiagnosticableTreeMixin {
  Member(
      this.mb_id,
      this.mb_name,
      this.mb_auth,
      this.mb_nick,
      this.mb_email,
      this.mb_level,
      this.mb_sex,
      this.mb_birth,
      this.mb_tel,
      this.mb_hp,
      this.mb_fax,
      this.mb_zip,
      this.mb_addr1,
      this.mb_addr2,
      this.mb_addr3,
      this.mb_addr_jibeon,
      this.mb_point,
      this.mb_money,
      this.mb_today_login,
      this.mb_login_ip,
      this.mb_datetime,
      this.mb_ip,
      this.mb_leave_date,
      this.mb_intercept_date,
      this.mb_mailling,
      this.mb_sms,
      this.mb_open,
      this.mb_open_date,
      this.mb_img,
      this.mb_block,
      this.mb_singo,
      this.mb_app,
      this.gr_id,
      this.gr_subject,
      this.gr_type,
      this.gr_regis_use,
      this.gr_auth_use,
      this.me_loc,
      this.ar_gugun,
      this.total_money);

  String mb_id;
  String mb_name;
  String mb_auth;
  String mb_nick;
  String mb_email;
  String mb_level;
  String mb_sex;
  String mb_birth;
  String mb_tel;
  String mb_hp;
  String mb_fax;
  String mb_zip;
  String mb_addr1;
  String mb_addr2;
  String mb_addr3;
  String mb_addr_jibeon;
  String mb_point;
  String mb_money;
  String mb_today_login;
  String mb_login_ip;
  String mb_datetime;
  String mb_ip;
  String mb_leave_date;
  String mb_intercept_date;
  String mb_mailling;
  String mb_sms;
  String mb_open;
  String mb_open_date;
  String mb_img;
  String mb_block;
  String mb_singo;
  String mb_app;
  String gr_id;
  String gr_subject;
  String gr_type;
  String gr_regis_use;
  String gr_auth_use;
  String me_loc;
  String ar_gugun;
  int total_money;

  getGr_id(String gr_id)
  {
    this.gr_id = gr_id;

    notifyListeners();
  }

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  /// `toJson` 은 JSON으로 직렬화할 수 있도록 합니다.
  /// 자동으로 만들어진 member.g.dart에 구현이 있습니다.
  Map<String, dynamic> toJson() => _$MemberToJson(this);
}