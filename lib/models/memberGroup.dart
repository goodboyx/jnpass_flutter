import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'memberGroup.g.dart';

class MemberGroupData {
  static List<MemberGroup> items = [];
}

/// 클래스가 시리얼라이저가 필요하다고 알려주는 어노테이션입니다.
@JsonSerializable(explicitToJson: true)
class MemberGroup with ChangeNotifier, DiagnosticableTreeMixin {
  MemberGroup(
      this.gr_id,
      this.gr_subject,
      this.gr_type,
      this.gr_order);

  String gr_id;
  String gr_subject;
  String gr_type;
  String gr_order;

  factory MemberGroup.fromJson(Map<String, dynamic> json) => _$MemberGroupFromJson(json);

  /// `toJson` 은 JSON으로 직렬화할 수 있도록 합니다.
  /// 자동으로 만들어진 membergroup.g.dart에 구현이 있습니다.
  Map<String, dynamic> toJson() => _$MemberGroupToJson(this);
}
