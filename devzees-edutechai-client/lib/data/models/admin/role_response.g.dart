// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoleResponse _$RoleResponseFromJson(Map<String, dynamic> json) =>
    _RoleResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      privileges:
          (json['privileges'] as List<dynamic>?)
              ?.map(
                (e) => PrivilegeResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      retired: json['retired'] as bool? ?? false,
      retiredAt: json['retired_at'] == null
          ? null
          : DateTime.parse(json['retired_at'] as String),
      retiredBy: json['retired_by'] as String?,
    );

Map<String, dynamic> _$RoleResponseToJson(_RoleResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'privileges': instance.privileges,
      'created_at': instance.createdAt.toIso8601String(),
      'retired': instance.retired,
      'retired_at': instance.retiredAt?.toIso8601String(),
      'retired_by': instance.retiredBy,
    };
