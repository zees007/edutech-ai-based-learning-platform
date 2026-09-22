// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoleCreateRequest _$RoleCreateRequestFromJson(Map<String, dynamic> json) =>
    _RoleCreateRequest(
      name: json['name'] as String,
      privilegeIds:
          (json['privilege_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RoleCreateRequestToJson(_RoleCreateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'privilege_ids': instance.privilegeIds,
    };
