// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_role_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginatedRoleResponse {

 List<RoleResponse> get items; int get total; int get page; int get size;@JsonKey(name: 'total_pages') int get totalPages;
/// Create a copy of PaginatedRoleResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedRoleResponseCopyWith<PaginatedRoleResponse> get copyWith => _$PaginatedRoleResponseCopyWithImpl<PaginatedRoleResponse>(this as PaginatedRoleResponse, _$identity);

  /// Serializes this PaginatedRoleResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedRoleResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,size,totalPages);

@override
String toString() {
  return 'PaginatedRoleResponse(items: $items, total: $total, page: $page, size: $size, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $PaginatedRoleResponseCopyWith<$Res>  {
  factory $PaginatedRoleResponseCopyWith(PaginatedRoleResponse value, $Res Function(PaginatedRoleResponse) _then) = _$PaginatedRoleResponseCopyWithImpl;
@useResult
$Res call({
 List<RoleResponse> items, int total, int page, int size,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class _$PaginatedRoleResponseCopyWithImpl<$Res>
    implements $PaginatedRoleResponseCopyWith<$Res> {
  _$PaginatedRoleResponseCopyWithImpl(this._self, this._then);

  final PaginatedRoleResponse _self;
  final $Res Function(PaginatedRoleResponse) _then;

/// Create a copy of PaginatedRoleResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? size = null,Object? totalPages = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RoleResponse>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedRoleResponse].
extension PaginatedRoleResponsePatterns on PaginatedRoleResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedRoleResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedRoleResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedRoleResponse value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedRoleResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedRoleResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedRoleResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RoleResponse> items,  int total,  int page,  int size, @JsonKey(name: 'total_pages')  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedRoleResponse() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.size,_that.totalPages);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RoleResponse> items,  int total,  int page,  int size, @JsonKey(name: 'total_pages')  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _PaginatedRoleResponse():
return $default(_that.items,_that.total,_that.page,_that.size,_that.totalPages);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RoleResponse> items,  int total,  int page,  int size, @JsonKey(name: 'total_pages')  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedRoleResponse() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.size,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedRoleResponse implements PaginatedRoleResponse {
  const _PaginatedRoleResponse({final  List<RoleResponse> items = const [], required this.total, required this.page, required this.size, @JsonKey(name: 'total_pages') required this.totalPages}): _items = items;
  factory _PaginatedRoleResponse.fromJson(Map<String, dynamic> json) => _$PaginatedRoleResponseFromJson(json);

 final  List<RoleResponse> _items;
@override@JsonKey() List<RoleResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;
@override final  int size;
@override@JsonKey(name: 'total_pages') final  int totalPages;

/// Create a copy of PaginatedRoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedRoleResponseCopyWith<_PaginatedRoleResponse> get copyWith => __$PaginatedRoleResponseCopyWithImpl<_PaginatedRoleResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedRoleResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedRoleResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,size,totalPages);

@override
String toString() {
  return 'PaginatedRoleResponse(items: $items, total: $total, page: $page, size: $size, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$PaginatedRoleResponseCopyWith<$Res> implements $PaginatedRoleResponseCopyWith<$Res> {
  factory _$PaginatedRoleResponseCopyWith(_PaginatedRoleResponse value, $Res Function(_PaginatedRoleResponse) _then) = __$PaginatedRoleResponseCopyWithImpl;
@override @useResult
$Res call({
 List<RoleResponse> items, int total, int page, int size,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class __$PaginatedRoleResponseCopyWithImpl<$Res>
    implements _$PaginatedRoleResponseCopyWith<$Res> {
  __$PaginatedRoleResponseCopyWithImpl(this._self, this._then);

  final _PaginatedRoleResponse _self;
  final $Res Function(_PaginatedRoleResponse) _then;

/// Create a copy of PaginatedRoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? size = null,Object? totalPages = null,}) {
  return _then(_PaginatedRoleResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RoleResponse>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
