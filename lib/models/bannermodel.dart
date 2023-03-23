import 'package:json_annotation/json_annotation.dart';

part 'bannermodel.g.dart';

class BannerData {
  static List<BannerModel> items = [];
}

class MainBannerData {
  static List<BannerModel> items = [];
}

class DonationBannerData {
  static List<BannerModel> items = [];
}

class ResultBannerData {
  static List<BannerModel> items = [];
}

class BoardViewImgData {
  static List<BannerModel> items = [];
}

/// 클래스가 시리얼라이저가 필요하다고 알려주는 어노테이션입니다.
@JsonSerializable(explicitToJson: true)
class BannerModel {
  BannerModel(
    this.img_src,
    this.link,
    this.wr_content);


  String img_src;
  String link;
  String wr_content;

  factory BannerModel.fromJson(Map<String, dynamic> json) => _$BannerModelFromJson(json);

  /// `toJson` 은 JSON으로 직렬화할 수 있도록 합니다.
  /// 자동으로 만들어진 adbanner.g.dart에 구현이 있습니다.
  Map<String, dynamic> toJson() => _$BannerModelToJson(this);

}
