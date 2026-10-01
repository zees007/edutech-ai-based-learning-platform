import 'package:freezed_annotation/freezed_annotation.dart';

part 'role_edit_request.freezed.dart';
part 'role_edit_request.g.dart';

@freezed
abstract class RoleEditRequest with _$RoleEditRequest {
  const factory RoleEditRequest({
    String? name,
    @JsonKey(name: 'privilege_ids') List<int>? privilegeIds,
  }) = _RoleEditRequest;

  factory RoleEditRequest.fromJson(Map<String, dynamic> json) =>
      _$RoleEditRequestFromJson(json);
}
