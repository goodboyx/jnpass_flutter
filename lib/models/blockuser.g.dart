// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blockuser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockUser _$BlockUserFromJson(Map<String, dynamic> json) => BlockUser(
      json['mb_id'] as String,
      json['mb_name'] as String,
      json['mb_nick'] as String,
      json['bl_datetime'] as String,
    );

Map<String, dynamic> _$BlockUserToJson(BlockUser instance) => <String, dynamic>{
      'mb_id': instance.mb_id,
      'mb_name': instance.mb_name,
      'mb_nick': instance.mb_nick,
      'bl_datetime': instance.bl_datetime,
    };
