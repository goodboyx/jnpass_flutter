import 'package:json_annotation/json_annotation.dart';

part 'apiError.g.dart';

/// 클래스가 시리얼라이저가 필요하다고 알려주는 어노테이션입니다.
@JsonSerializable(explicitToJson: true)
class ApiError {
  ApiError(this.error, this.msg);

  String error;
  String msg;

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);

  /// `toJson` 은 JSON으로 직렬화할 수 있도록 합니다.
  /// 자동으로 만들어진 adbanner.g.dart에 구현이 있습니다.
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

}