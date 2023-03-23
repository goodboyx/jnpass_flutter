// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csmodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CsModel _$CsModelFromJson(Map<String, dynamic> json) => CsModel(
  json['wr_id'] as String,
  json['ca_name'] as String,
  json['ca_name_text'] as String,
  json['wr_subject'] as String,
  json['wr_content'] as String,
  json['wr_name'] as String,
  json['mb_id'] as String,
  json['thum'] as String,
  // (json['file'] as List<dynamic>)
  //     .map((e) => BoardFileModel.fromJson(e as Map<String, dynamic>))
  //     .toList(),
  // json['wr_link1'] as String,
  // json['wr_area'] as String,
  json['wr_mb_img'] as String,
  json['wr_comment'] as String,
  json['wr_like'] as int,
  json['wr_is_like'] as int,
  json['is_me'] as int,
  json['wr_singo'] as int,
  // json['wr_modify'] as int,
  json['total_count'] as int,
  json['total_page'] as int,
  json['wr_datetime'] as String,
  json['wr_datetime2'] as String,
  json['wr_date'] as String,
  json['wr_6'] as String,
  json['state'] as String,
  json['color'] as String,
);

Map<String, dynamic> _$CsModelToJson(CsModel instance) =>
    <String, dynamic>{
      'wr_id': instance.wr_id,
      'ca_name': instance.ca_name,
      'ca_name_text': instance.ca_name_text,
      'wr_subject': instance.wr_subject,
      'wr_content': instance.wr_content,
      'wr_name': instance.wr_name,
      'mb_id': instance.mb_id,
      'thum': instance.thum,
      // 'file': instance.file.map((e) => e.toJson()).toList(),
      // 'wr_link1': instance.wr_link1,
      // 'wr_area': instance.wr_area,
      'wr_mb_img': instance.wr_mb_img,
      'wr_comment': instance.wr_comment,
      'wr_like': instance.wr_like,
      'wr_is_like': instance.wr_is_like,
      'is_me': instance.is_me,
      'wr_singo': instance.wr_singo,
      // 'wr_modify': instance.wr_modify,
      'total_count': instance.total_count,
      'total_page': instance.total_page,
      'wr_datetime': instance.wr_datetime,
      'wr_datetime2': instance.wr_datetime2,
      'wr_date': instance.wr_date,
      'wr_6': instance.wr_6,
      'state': instance.state,
      'color': instance.color,
    };
