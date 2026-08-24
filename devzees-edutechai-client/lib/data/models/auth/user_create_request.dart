import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_create_request.freezed.dart';
part 'user_create_request.g.dart';

@freezed
abstract class UserCreateRequest with _$UserCreateRequest {
  const factory UserCreateRequest({
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String email,
    required String password,
    String? mobile,
    String? country,
  }) = _UserCreateRequest;

  factory UserCreateRequest.fromJson(Map<String, dynamic> json) => _$UserCreateRequestFromJson(json);
}
