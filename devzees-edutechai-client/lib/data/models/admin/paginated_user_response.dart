import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_response.dart';

part 'paginated_user_response.freezed.dart';
part 'paginated_user_response.g.dart';

@freezed
abstract class PaginatedUserResponse with _$PaginatedUserResponse {
  const factory PaginatedUserResponse({
    @Default([]) List<AdminUserResponse> items,
    required int total,
    required int page,
    required int size,
    @JsonKey(name: 'total_pages') required int totalPages,
  }) = _PaginatedUserResponse;

  factory PaginatedUserResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedUserResponseFromJson(json);
}
