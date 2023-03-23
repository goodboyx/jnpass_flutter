// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bannermodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
      json['img_src'] as String,
      json['link'] as String,
      json['wr_content'] as String,
    );

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      'img_src': instance.img_src,
      'link': instance.link,
      'wr_content': instance.wr_content,
    };
