// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminUserResponse _$AdminUserResponseFromJson(Map<String, dynamic> json) =>
    _AdminUserResponse(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String?,
      country: json['country'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => RoleResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      subscription: json['subscription'] == null
          ? null
          : SubscriptionResponse.fromJson(
              json['subscription'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['created_at'] as String),
      retired: json['retired'] as bool? ?? false,
      retiredAt: json['retired_at'] == null
          ? null
          : DateTime.parse(json['retired_at'] as String),
      retiredBy: json['retired_by'] as String?,
    );

Map<String, dynamic> _$AdminUserResponseToJson(_AdminUserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'mobile': instance.mobile,
      'country': instance.country,
      'roles': instance.roles,
      'subscription': instance.subscription,
      'created_at': instance.createdAt.toIso8601String(),
      'retired': instance.retired,
      'retired_at': instance.retiredAt?.toIso8601String(),
      'retired_by': instance.retiredBy,
    };
