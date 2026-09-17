// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_current_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserCurrentProfileResponse _$UserCurrentProfileResponseFromJson(
  Map<String, dynamic> json,
) => _UserCurrentProfileResponse(
  id: json['id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  mobile: json['mobile'] as String?,
  country: json['country'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  roles:
      (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  subscription: json['subscription'] == null
      ? null
      : SubscriptionResponse.fromJson(
          json['subscription'] as Map<String, dynamic>,
        ),
  privilegeCodes:
      (json['privilege_codes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserCurrentProfileResponseToJson(
  _UserCurrentProfileResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'mobile': instance.mobile,
  'country': instance.country,
  'created_at': instance.createdAt.toIso8601String(),
  'roles': instance.roles,
  'subscription': instance.subscription,
  'privilege_codes': instance.privilegeCodes,
};
