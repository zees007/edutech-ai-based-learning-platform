// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privilege_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrivilegeResponse _$PrivilegeResponseFromJson(Map<String, dynamic> json) =>
    _PrivilegeResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String,
      orderNumber: (json['order_number'] as num?)?.toInt() ?? 0,
      parentId: (json['parent_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PrivilegeResponseToJson(_PrivilegeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'order_number': instance.orderNumber,
      'parent_id': instance.parentId,
    };
