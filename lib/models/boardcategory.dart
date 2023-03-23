import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'boardcategory.g.dart';

class BoardCategoryData {
  static List<BoardCategory> items = [];
}

class NewsBoardCategoryData {
  static List<BoardCategory> items = [];
}

class NoticeBoardCategoryData {
  static List<BoardCategory> items = [];
}

/// 클래스가 시리얼라이저가 필요하다고 알려주는 어노테이션입니다.
@JsonSerializable(explicitToJson: true)
class BoardCategory with ChangeNotifier, DiagnosticableTreeMixin {
  BoardCategory(this.id,
      this.name);

  String id;
  String name;

  factory BoardCategory.fromJson(Map<String, dynamic> json) => _$BoardCategoryFromJson(json);

  /// `toJson` 은 JSON으로 직렬화할 수 있도록 합니다.
  /// 자동으로 만들어진 member.g.dart에 구현이 있습니다.
  Map<String, dynamic> toJson() => _$BoardCategoryToJson(this);
}