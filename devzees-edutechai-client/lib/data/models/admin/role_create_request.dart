import 'package:freezed_annotation/freezed_annotation.dart';

part 'role_create_request.freezed.dart';
part 'role_create_request.g.dart';

@freezed
abstract class RoleCreateRequest with _$RoleCreateRequest {
  const factory RoleCreateRequest({
    required String name,
    @JsonKey(name: 'privilege_ids') @Default([]) List<int> privilegeIds,
  }) = _RoleCreateRequest;

  factory RoleCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$RoleCreateRequestFromJson(json);
}
