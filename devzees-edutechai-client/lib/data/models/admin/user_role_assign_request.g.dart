// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_assign_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserRoleAssignRequest _$UserRoleAssignRequestFromJson(
  Map<String, dynamic> json,
) => _UserRoleAssignRequest(
  roleIds: (json['role_ids'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$UserRoleAssignRequestToJson(
  _UserRoleAssignRequest instance,
) => <String, dynamic>{'role_ids': instance.roleIds};
