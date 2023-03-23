import 'package:json_annotation/json_annotation.dart';

part 'pointmodel.g.dart';

class PointListData {
  static List<PointModel> items = [];
}

/// 클래스가 시리얼라이저가 필요하다고 알려주는 어노테이션입니다.
@JsonSerializable(explicitToJson: true)
class PointModel {
  PointModel(this.mb_id,
        this.mo_datetime,
        this.mo_content,
        this.mo_money,
        this.mo_use_money,
        this.mo_expired,
        this.mo_mb_money,
        this.mo_rel_table,
        this.mo_rel_id,
        this.mo_rel_action,
        this.total_count,
        this.total_page);

  String mb_id;
  String mo_datetime;
  String mo_content;
  String mo_money;
  String mo_use_money;
  String mo_expired;
  String mo_mb_money;
  String mo_rel_table;
  String mo_rel_id;
  String mo_rel_action;
  int total_count;
  int total_page;

  factory PointModel.fromJson(Map<String, dynamic> json) => _$PointModelFromJson(json);

  /// `toJson` 은 JSON으로 직렬화할 수 있도록 합니다.
  /// 자동으로 만들어진 member.g.dart에 구현이 있습니다.
  Map<String, dynamic> toJson() => _$PointModelToJson(this);

}
