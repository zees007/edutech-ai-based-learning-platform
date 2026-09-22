import 'package:freezed_annotation/freezed_annotation.dart';
import 'privilege_response.dart';

part 'role_response.freezed.dart';
part 'role_response.g.dart';

@freezed
abstract class RoleResponse with _$RoleResponse {
  const factory RoleResponse({
    required String id,
    required String name,
    @Default([]) List<PrivilegeResponse> privileges,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default(false) bool retired,
    @JsonKey(name: 'retired_at') DateTime? retiredAt,
    @JsonKey(name: 'retired_by') String? retiredBy,
  }) = _RoleResponse;

  factory RoleResponse.fromJson(Map<String, dynamic> json) =>
      _$RoleResponseFromJson(json);
}
