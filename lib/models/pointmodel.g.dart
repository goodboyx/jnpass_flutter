// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pointmodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointModel _$PointModelFromJson(Map<String, dynamic> json) => PointModel(
      json['mb_id'] as String,
      json['mo_datetime'] as String,
      json['mo_content'] as String,
      json['mo_money'] as String,
      json['mo_use_money'] as String,
      json['mo_expired'] as String,
      json['mo_mb_money'] as String,
      json['mo_rel_table'] as String,
      json['mo_rel_id'] as String,
      json['mo_rel_action'] as String,
    );

Map<String, dynamic> _$PointModelToJson(PointModel instance) =>
    <String, dynamic>{
      'mb_id': instance.mb_id,
      'mo_datetime': instance.mo_datetime,
      'mo_content': instance.mo_content,
      'mo_money': instance.mo_money,
      'mo_use_money': instance.mo_use_money,
      'mo_expired': instance.mo_expired,
      'mo_mb_money': instance.mo_mb_money,
      'mo_rel_table': instance.mo_rel_table,
      'mo_rel_id': instance.mo_rel_id,
      'mo_rel_action': instance.mo_rel_action,
    };
