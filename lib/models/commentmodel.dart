import 'package:json_annotation/json_annotation.dart';

part 'commentmodel.g.dart';

class DonationCommentData {
  static List<CommentModel> items = [];
}

class ShareCommentData {
  static List<CommentModel> items = [];
}

class NewsCommentData {
  static List<CommentModel> items = [];
}

/// 클래스가 시리얼라이저가 필요하다고 알려주는 어노테이션입니다.
@JsonSerializable(explicitToJson: true)
class CommentModel {
  CommentModel(this.del_mode,
      this.mb_id,
      this.singo_mode,
      this.like_mode,
      this.c_time,
      this.wr_id,
      this.wr_datetime,
      this.wr_content,
      this.wr_10,
      this.cm_img,
      this.mb_nick,
      this.is_me);

  int del_mode;
  String mb_id;
  int singo_mode;
  int like_mode;
  String c_time;
  String wr_id;
  String wr_datetime;
  String wr_content;
  String wr_10;
  String cm_img;
  String mb_nick;
  int is_me;

  factory CommentModel.fromJson(Map<String, dynamic> json) => _$CommentModelFromJson(json);

  /// `toJson` 은 JSON으로 직렬화할 수 있도록 합니다.
  /// 자동으로 만들어진 adbanner.g.dart에 구현이 있습니다.
  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

}