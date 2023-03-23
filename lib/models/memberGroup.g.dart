// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memberGroup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberGroup _$MemberGroupFromJson(Map<String, dynamic> json) => MemberGroup(
      json['gr_id'] as String,
      json['gr_subject'] as String,
      json['gr_type'] as String,
      json['gr_order'] as String,
    );

Map<String, dynamic> _$MemberGroupToJson(MemberGroup instance) =>
    <String, dynamic>{
      'gr_id': instance.gr_id,
      'gr_subject': instance.gr_subject,
      'gr_type': instance.gr_type,
      'gr_order': instance.gr_order,
    };
