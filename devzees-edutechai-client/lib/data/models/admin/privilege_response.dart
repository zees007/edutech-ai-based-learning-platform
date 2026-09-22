import 'package:freezed_annotation/freezed_annotation.dart';

part 'privilege_response.freezed.dart';
part 'privilege_response.g.dart';

@freezed
abstract class PrivilegeResponse with _$PrivilegeResponse {
  const factory PrivilegeResponse({
    required int id,
    required String name,
    required String code,
    @JsonKey(name: 'order_number') @Default(0) int orderNumber,
    @JsonKey(name: 'parent_id') int? parentId,
  }) = _PrivilegeResponse;

  factory PrivilegeResponse.fromJson(Map<String, dynamic> json) =>
      _$PrivilegeResponseFromJson(json);
}
