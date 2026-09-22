// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_user_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginatedUserResponse {

 List<AdminUserResponse> get items; int get total; int get page; int get size;@JsonKey(name: 'total_pages') int get totalPages;
/// Create a copy of PaginatedUserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedUserResponseCopyWith<PaginatedUserResponse> get copyWith => _$PaginatedUserResponseCopyWithImpl<PaginatedUserResponse>(this as PaginatedUserResponse, _$identity);

  /// Serializes this PaginatedUserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedUserResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,size,totalPages);

@override
String toString() {
  return 'PaginatedUserResponse(items: $items, total: $total, page: $page, size: $size, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $PaginatedUserResponseCopyWith<$Res>  {
  factory $PaginatedUserResponseCopyWith(PaginatedUserResponse value, $Res Function(PaginatedUserResponse) _then) = _$PaginatedUserResponseCopyWithImpl;
@useResult
$Res call({
 List<AdminUserResponse> items, int total, int page, int size,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class _$PaginatedUserResponseCopyWithImpl<$Res>
    implements $PaginatedUserResponseCopyWith<$Res> {
  _$PaginatedUserResponseCopyWithImpl(this._self, this._then);

  final PaginatedUserResponse _self;
  final $Res Function(PaginatedUserResponse) _then;

/// Create a copy of PaginatedUserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? size = null,Object? totalPages = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AdminUserResponse>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedUserResponse].
extension PaginatedUserResponsePatterns on PaginatedUserResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedUserResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedUserResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedUserResponse value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedUserResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedUserResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedUserResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AdminUserResponse> items,  int total,  int page,  int size, @JsonKey(name: 'total_pages')  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedUserResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AdminUserResponse> items,  int total,  int page,  int size, @JsonKey(name: 'total_pages')  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _PaginatedUserResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AdminUserResponse> items,  int total,  int page,  int size, @JsonKey(name: 'total_pages')  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedUserResponse() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.size,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedUserResponse implements PaginatedUserResponse {
  const _PaginatedUserResponse({final  List<AdminUserResponse> items = const [], required this.total, required this.page, required this.size, @JsonKey(name: 'total_pages') required this.totalPages}): _items = items;
  factory _PaginatedUserResponse.fromJson(Map<String, dynamic> json) => _$PaginatedUserResponseFromJson(json);

 final  List<AdminUserResponse> _items;
@override@JsonKey() List<AdminUserResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;
@override final  int size;
@override@JsonKey(name: 'total_pages') final  int totalPages;

/// Create a copy of PaginatedUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedUserResponseCopyWith<_PaginatedUserResponse> get copyWith => __$PaginatedUserResponseCopyWithImpl<_PaginatedUserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedUserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedUserResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,size,totalPages);

@override
String toString() {
  return 'PaginatedUserResponse(items: $items, total: $total, page: $page, size: $size, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$PaginatedUserResponseCopyWith<$Res> implements $PaginatedUserResponseCopyWith<$Res> {
  factory _$PaginatedUserResponseCopyWith(_PaginatedUserResponse value, $Res Function(_PaginatedUserResponse) _then) = __$PaginatedUserResponseCopyWithImpl;
@override @useResult
$Res call({
 List<AdminUserResponse> items, int total, int page, int size,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class __$PaginatedUserResponseCopyWithImpl<$Res>
    implements _$PaginatedUserResponseCopyWith<$Res> {
  __$PaginatedUserResponseCopyWithImpl(this._self, this._then);

  final _PaginatedUserResponse _self;
  final $Res Function(_PaginatedUserResponse) _then;

/// Create a copy of PaginatedUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? size = null,Object? totalPages = null,}) {
  return _then(_PaginatedUserResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AdminUserResponse>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
