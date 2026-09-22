// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginatedUserResponse _$PaginatedUserResponseFromJson(
  Map<String, dynamic> json,
) => _PaginatedUserResponse(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => AdminUserResponse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
);

Map<String, dynamic> _$PaginatedUserResponseToJson(
  _PaginatedUserResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'page': instance.page,
  'size': instance.size,
  'total_pages': instance.totalPages,
};
