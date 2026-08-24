// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserCreateRequest _$UserCreateRequestFromJson(Map<String, dynamic> json) =>
    _UserCreateRequest(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      mobile: json['mobile'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$UserCreateRequestToJson(_UserCreateRequest instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'password': instance.password,
      'mobile': instance.mobile,
      'country': instance.country,
    };
