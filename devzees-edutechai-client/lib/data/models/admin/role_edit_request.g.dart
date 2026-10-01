// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_edit_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoleEditRequest _$RoleEditRequestFromJson(Map<String, dynamic> json) =>
    _RoleEditRequest(
      name: json['name'] as String?,
      privilegeIds: (json['privilege_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$RoleEditRequestToJson(_RoleEditRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'privilege_ids': instance.privilegeIds,
    };
