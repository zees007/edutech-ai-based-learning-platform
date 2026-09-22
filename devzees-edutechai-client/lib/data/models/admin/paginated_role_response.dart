import 'package:freezed_annotation/freezed_annotation.dart';
import 'role_response.dart';

part 'paginated_role_response.freezed.dart';
part 'paginated_role_response.g.dart';

@freezed
abstract class PaginatedRoleResponse with _$PaginatedRoleResponse {
  const factory PaginatedRoleResponse({
    @Default([]) List<RoleResponse> items,
    required int total,
    required int page,
    required int size,
    @JsonKey(name: 'total_pages') required int totalPages,
  }) = _PaginatedRoleResponse;

  factory PaginatedRoleResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedRoleResponseFromJson(json);
}
