import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blockuser.g.dart';

class BlockUserData {
  static List<BlockUser> items = [];
}

/// 클래스가 시리얼라이저가 필요하다고 알려주는 어노테이션입니다.
@JsonSerializable(explicitToJson: true)
class BlockUser with ChangeNotifier, DiagnosticableTreeMixin {
  BlockUser(this.mb_id,
      this.mb_name,
      this.mb_nick,
      this.bl_datetime);

  String mb_id;
  String mb_name;
  String mb_nick;
  String bl_datetime;

  factory BlockUser.fromJson(Map<String, dynamic> json) => _$BlockUserFromJson(json);

  /// `toJson` 은 JSON으로 직렬화할 수 있도록 합니다.
  /// 자동으로 만들어진 member.g.dart에 구현이 있습니다.
  Map<String, dynamic> toJson() => _$BlockUserToJson(this);
}