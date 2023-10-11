import 'package:jnpass/models/BoardFileModel.dart';
import 'package:json_annotation/json_annotation.dart';

part 'boardmodel.g.dart';

class BoardData {
  static List<BoardModel> items = [];
}

class CSBoardData {
  static List<BoardModel> items = [];
}

class NoticeBoardData {
  static List<BoardModel> items = [];
}

class NewsBoardData {
  static List<BoardModel> items = [];
}

class ShareBoardData {
  static List<BoardModel> items = [];
}

class ShareBoardViewData {
  static List<BoardModel> items = [];
}

class DonationBoardViewData {
  static List<BoardModel> items = [];
}

class NewsBoardViewData {
  static List<BoardModel> items = [];
}

class BoardNonateData {
  static List<BoardModel> items = [];
}

class BoardNewsData {
  static List<BoardModel> items = [];
}

/// 클래스가 시리얼라이저가 필요하다고 알려주는 어노테이션입니다.
@JsonSerializable(explicitToJson: true)
class BoardModel {
  BoardModel(
      this.wr_id,
      this.ca_name,
      this.ca_name_text,
      this.wr_subject,
      this.wr_content,
      this.wr_name,
      this.mb_id,
      this.thum,
      // this.file,
      this.wr_area,
      this.wr_mb_img,
      this.wr_comment,
      this.wr_like,
      this.wr_is_like,
      this.is_me,
      this.wr_singo,
      this.wr_link1,
      // this.wr_modify,
      this.total_count,
      this.total_page,
      this.wr_datetime,
      this.wr_datetime2,
      this.wr_date,
      this.wr_hit
      );

  String wr_id;
  String ca_name;
  String ca_name_text;
  String wr_subject;
  String wr_content;
  String wr_name;
  String mb_id;
  String thum;
  // List<BoardFileModel> file;
  // String wr_facebook_user;
  // String wr_twitter_user;
  String wr_link1;
  String wr_area;
  String wr_mb_img;
  String wr_comment;
  int wr_like;
  int wr_is_like;
  int is_me;
  int wr_singo;
  // int wr_modify;
  int total_count;
  int total_page;
  String wr_datetime;
  String wr_datetime2;
  String wr_date;
  String wr_hit;

  factory BoardModel.fromJson(Map<String, dynamic> json) => _$BoardModelFromJson(json);

  /// `toJson` 은 JSON으로 직렬화할 수 있도록 합니다.
  /// 자동으로 만들어진 adbanner.g.dart에 구현이 있습니다.
  Map<String, dynamic> toJson() => _$BoardModelToJson(this);

}
