// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commentmodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      json['del_mode'] as int,
      json['mb_id'] as String,
      json['singo_mode'] as int,
      json['like_mode'] as int,
      json['c_time'] as String,
      json['wr_id'] as String,
      json['wr_datetime'] as String,
      json['wr_content'] as String,
      json['wr_10'] as String,
      json['cm_img'] as String,
      json['mb_nick'] as String,
      json['is_me'] as int,
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'del_mode': instance.del_mode,
      'mb_id': instance.mb_id,
      'singo_mode': instance.singo_mode,
      'like_mode': instance.like_mode,
      'c_time': instance.c_time,
      'wr_id': instance.wr_id,
      'wr_datetime': instance.wr_datetime,
      'wr_content': instance.wr_content,
      'wr_10': instance.wr_10,
      'cm_img': instance.cm_img,
      'mb_nick': instance.mb_nick,
      'is_me': instance.is_me,
    };
