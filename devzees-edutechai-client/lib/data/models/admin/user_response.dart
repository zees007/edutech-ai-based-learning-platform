import 'package:freezed_annotation/freezed_annotation.dart';
import 'role_response.dart';
import '../auth/subscription_response.dart';

part 'user_response.freezed.dart';
part 'user_response.g.dart';

/// Full admin-facing UserResponse with roles, subscription, and retired status.
/// This mirrors the server's UserResponse from models/user_schemas.py.
@freezed
abstract class AdminUserResponse with _$AdminUserResponse {
  const factory AdminUserResponse({
    required String id,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String email,
    String? mobile,
    String? country,
    @Default([]) List<RoleResponse> roles,
    SubscriptionResponse? subscription,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default(false) bool retired,
    @JsonKey(name: 'retired_at') DateTime? retiredAt,
    @JsonKey(name: 'retired_by') String? retiredBy,
  }) = _AdminUserResponse;

  factory AdminUserResponse.fromJson(Map<String, dynamic> json) =>
      _$AdminUserResponseFromJson(json);
}
