import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_role_assign_request.freezed.dart';
part 'user_role_assign_request.g.dart';

@freezed
abstract class UserRoleAssignRequest with _$UserRoleAssignRequest {
  const factory UserRoleAssignRequest({
    @JsonKey(name: 'role_ids') required List<String> roleIds,
  }) = _UserRoleAssignRequest;

  factory UserRoleAssignRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRoleAssignRequestFromJson(json);
}
