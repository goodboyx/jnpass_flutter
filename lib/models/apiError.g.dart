// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiError.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
      json['error'] as String,
      json['msg'] as String,
    );

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
      'error': instance.error,
      'msg': instance.msg,
    };
