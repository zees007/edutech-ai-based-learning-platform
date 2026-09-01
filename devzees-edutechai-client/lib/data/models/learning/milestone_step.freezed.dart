// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milestone_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MilestoneStep {

 int get index; String get title; String get description;@JsonKey(name: 'is_prerequisite') bool get isPrerequisite; String? get prerequisite; String get status;@JsonKey(name: 'estimated_minutes') int get estimatedMinutes;@JsonKey(name: 'tutor_explanation') String? get tutorExplanation;@JsonKey(name: 'socratic_questions') List<dynamic>? get socraticQuestions; List<dynamic>? get quiz;@JsonKey(name: 'quiz_score') double? get quizScore;@JsonKey(name: 'user_answers') Map<String, dynamic>? get userAnswers;@JsonKey(name: 'user_full_answers') Map<String, dynamic>? get userFullAnswers; List<dynamic>? get videos; List<dynamic>? get papers;
/// Create a copy of MilestoneStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MilestoneStepCopyWith<MilestoneStep> get copyWith => _$MilestoneStepCopyWithImpl<MilestoneStep>(this as MilestoneStep, _$identity);

  /// Serializes this MilestoneStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MilestoneStep&&(identical(other.index, index) || other.index == index)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrerequisite, isPrerequisite) || other.isPrerequisite == isPrerequisite)&&(identical(other.prerequisite, prerequisite) || other.prerequisite == prerequisite)&&(identical(other.status, status) || other.status == status)&&(identical(other.estimatedMinutes, estimatedMinutes) || other.estimatedMinutes == estimatedMinutes)&&(identical(other.tutorExplanation, tutorExplanation) || other.tutorExplanation == tutorExplanation)&&const DeepCollectionEquality().equals(other.socraticQuestions, socraticQuestions)&&const DeepCollectionEquality().equals(other.quiz, quiz)&&(identical(other.quizScore, quizScore) || other.quizScore == quizScore)&&const DeepCollectionEquality().equals(other.userAnswers, userAnswers)&&const DeepCollectionEquality().equals(other.userFullAnswers, userFullAnswers)&&const DeepCollectionEquality().equals(other.videos, videos)&&const DeepCollectionEquality().equals(other.papers, papers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,title,description,isPrerequisite,prerequisite,status,estimatedMinutes,tutorExplanation,const DeepCollectionEquality().hash(socraticQuestions),const DeepCollectionEquality().hash(quiz),quizScore,const DeepCollectionEquality().hash(userAnswers),const DeepCollectionEquality().hash(userFullAnswers),const DeepCollectionEquality().hash(videos),const DeepCollectionEquality().hash(papers));

@override
String toString() {
  return 'MilestoneStep(index: $index, title: $title, description: $description, isPrerequisite: $isPrerequisite, prerequisite: $prerequisite, status: $status, estimatedMinutes: $estimatedMinutes, tutorExplanation: $tutorExplanation, socraticQuestions: $socraticQuestions, quiz: $quiz, quizScore: $quizScore, userAnswers: $userAnswers, userFullAnswers: $userFullAnswers, videos: $videos, papers: $papers)';
}


}

/// @nodoc
abstract mixin class $MilestoneStepCopyWith<$Res>  {
  factory $MilestoneStepCopyWith(MilestoneStep value, $Res Function(MilestoneStep) _then) = _$MilestoneStepCopyWithImpl;
@useResult
$Res call({
 int index, String title, String description,@JsonKey(name: 'is_prerequisite') bool isPrerequisite, String? prerequisite, String status,@JsonKey(name: 'estimated_minutes') int estimatedMinutes,@JsonKey(name: 'tutor_explanation') String? tutorExplanation,@JsonKey(name: 'socratic_questions') List<dynamic>? socraticQuestions, List<dynamic>? quiz,@JsonKey(name: 'quiz_score') double? quizScore,@JsonKey(name: 'user_answers') Map<String, dynamic>? userAnswers,@JsonKey(name: 'user_full_answers') Map<String, dynamic>? userFullAnswers, List<dynamic>? videos, List<dynamic>? papers
});




}
/// @nodoc
class _$MilestoneStepCopyWithImpl<$Res>
    implements $MilestoneStepCopyWith<$Res> {
  _$MilestoneStepCopyWithImpl(this._self, this._then);

  final MilestoneStep _self;
  final $Res Function(MilestoneStep) _then;

/// Create a copy of MilestoneStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? title = null,Object? description = null,Object? isPrerequisite = null,Object? prerequisite = freezed,Object? status = null,Object? estimatedMinutes = null,Object? tutorExplanation = freezed,Object? socraticQuestions = freezed,Object? quiz = freezed,Object? quizScore = freezed,Object? userAnswers = freezed,Object? userFullAnswers = freezed,Object? videos = freezed,Object? papers = freezed,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPrerequisite: null == isPrerequisite ? _self.isPrerequisite : isPrerequisite // ignore: cast_nullable_to_non_nullable
as bool,prerequisite: freezed == prerequisite ? _self.prerequisite : prerequisite // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,tutorExplanation: freezed == tutorExplanation ? _self.tutorExplanation : tutorExplanation // ignore: cast_nullable_to_non_nullable
as String?,socraticQuestions: freezed == socraticQuestions ? _self.socraticQuestions : socraticQuestions // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,quiz: freezed == quiz ? _self.quiz : quiz // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,quizScore: freezed == quizScore ? _self.quizScore : quizScore // ignore: cast_nullable_to_non_nullable
as double?,userAnswers: freezed == userAnswers ? _self.userAnswers : userAnswers // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userFullAnswers: freezed == userFullAnswers ? _self.userFullAnswers : userFullAnswers // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,videos: freezed == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,papers: freezed == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MilestoneStep].
extension MilestoneStepPatterns on MilestoneStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MilestoneStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MilestoneStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MilestoneStep value)  $default,){
final _that = this;
switch (_that) {
case _MilestoneStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MilestoneStep value)?  $default,){
final _that = this;
switch (_that) {
case _MilestoneStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  String title,  String description, @JsonKey(name: 'is_prerequisite')  bool isPrerequisite,  String? prerequisite,  String status, @JsonKey(name: 'estimated_minutes')  int estimatedMinutes, @JsonKey(name: 'tutor_explanation')  String? tutorExplanation, @JsonKey(name: 'socratic_questions')  List<dynamic>? socraticQuestions,  List<dynamic>? quiz, @JsonKey(name: 'quiz_score')  double? quizScore, @JsonKey(name: 'user_answers')  Map<String, dynamic>? userAnswers, @JsonKey(name: 'user_full_answers')  Map<String, dynamic>? userFullAnswers,  List<dynamic>? videos,  List<dynamic>? papers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MilestoneStep() when $default != null:
return $default(_that.index,_that.title,_that.description,_that.isPrerequisite,_that.prerequisite,_that.status,_that.estimatedMinutes,_that.tutorExplanation,_that.socraticQuestions,_that.quiz,_that.quizScore,_that.userAnswers,_that.userFullAnswers,_that.videos,_that.papers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  String title,  String description, @JsonKey(name: 'is_prerequisite')  bool isPrerequisite,  String? prerequisite,  String status, @JsonKey(name: 'estimated_minutes')  int estimatedMinutes, @JsonKey(name: 'tutor_explanation')  String? tutorExplanation, @JsonKey(name: 'socratic_questions')  List<dynamic>? socraticQuestions,  List<dynamic>? quiz, @JsonKey(name: 'quiz_score')  double? quizScore, @JsonKey(name: 'user_answers')  Map<String, dynamic>? userAnswers, @JsonKey(name: 'user_full_answers')  Map<String, dynamic>? userFullAnswers,  List<dynamic>? videos,  List<dynamic>? papers)  $default,) {final _that = this;
switch (_that) {
case _MilestoneStep():
return $default(_that.index,_that.title,_that.description,_that.isPrerequisite,_that.prerequisite,_that.status,_that.estimatedMinutes,_that.tutorExplanation,_that.socraticQuestions,_that.quiz,_that.quizScore,_that.userAnswers,_that.userFullAnswers,_that.videos,_that.papers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  String title,  String description, @JsonKey(name: 'is_prerequisite')  bool isPrerequisite,  String? prerequisite,  String status, @JsonKey(name: 'estimated_minutes')  int estimatedMinutes, @JsonKey(name: 'tutor_explanation')  String? tutorExplanation, @JsonKey(name: 'socratic_questions')  List<dynamic>? socraticQuestions,  List<dynamic>? quiz, @JsonKey(name: 'quiz_score')  double? quizScore, @JsonKey(name: 'user_answers')  Map<String, dynamic>? userAnswers, @JsonKey(name: 'user_full_answers')  Map<String, dynamic>? userFullAnswers,  List<dynamic>? videos,  List<dynamic>? papers)?  $default,) {final _that = this;
switch (_that) {
case _MilestoneStep() when $default != null:
return $default(_that.index,_that.title,_that.description,_that.isPrerequisite,_that.prerequisite,_that.status,_that.estimatedMinutes,_that.tutorExplanation,_that.socraticQuestions,_that.quiz,_that.quizScore,_that.userAnswers,_that.userFullAnswers,_that.videos,_that.papers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MilestoneStep implements MilestoneStep {
  const _MilestoneStep({required this.index, required this.title, required this.description, @JsonKey(name: 'is_prerequisite') this.isPrerequisite = false, this.prerequisite, this.status = 'pending', @JsonKey(name: 'estimated_minutes') this.estimatedMinutes = 5, @JsonKey(name: 'tutor_explanation') this.tutorExplanation, @JsonKey(name: 'socratic_questions') final  List<dynamic>? socraticQuestions, final  List<dynamic>? quiz, @JsonKey(name: 'quiz_score') this.quizScore, @JsonKey(name: 'user_answers') final  Map<String, dynamic>? userAnswers, @JsonKey(name: 'user_full_answers') final  Map<String, dynamic>? userFullAnswers, final  List<dynamic>? videos, final  List<dynamic>? papers}): _socraticQuestions = socraticQuestions,_quiz = quiz,_userAnswers = userAnswers,_userFullAnswers = userFullAnswers,_videos = videos,_papers = papers;
  factory _MilestoneStep.fromJson(Map<String, dynamic> json) => _$MilestoneStepFromJson(json);

@override final  int index;
@override final  String title;
@override final  String description;
@override@JsonKey(name: 'is_prerequisite') final  bool isPrerequisite;
@override final  String? prerequisite;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'estimated_minutes') final  int estimatedMinutes;
@override@JsonKey(name: 'tutor_explanation') final  String? tutorExplanation;
 final  List<dynamic>? _socraticQuestions;
@override@JsonKey(name: 'socratic_questions') List<dynamic>? get socraticQuestions {
  final value = _socraticQuestions;
  if (value == null) return null;
  if (_socraticQuestions is EqualUnmodifiableListView) return _socraticQuestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<dynamic>? _quiz;
@override List<dynamic>? get quiz {
  final value = _quiz;
  if (value == null) return null;
  if (_quiz is EqualUnmodifiableListView) return _quiz;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'quiz_score') final  double? quizScore;
 final  Map<String, dynamic>? _userAnswers;
@override@JsonKey(name: 'user_answers') Map<String, dynamic>? get userAnswers {
  final value = _userAnswers;
  if (value == null) return null;
  if (_userAnswers is EqualUnmodifiableMapView) return _userAnswers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _userFullAnswers;
@override@JsonKey(name: 'user_full_answers') Map<String, dynamic>? get userFullAnswers {
  final value = _userFullAnswers;
  if (value == null) return null;
  if (_userFullAnswers is EqualUnmodifiableMapView) return _userFullAnswers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<dynamic>? _videos;
@override List<dynamic>? get videos {
  final value = _videos;
  if (value == null) return null;
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<dynamic>? _papers;
@override List<dynamic>? get papers {
  final value = _papers;
  if (value == null) return null;
  if (_papers is EqualUnmodifiableListView) return _papers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of MilestoneStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MilestoneStepCopyWith<_MilestoneStep> get copyWith => __$MilestoneStepCopyWithImpl<_MilestoneStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MilestoneStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MilestoneStep&&(identical(other.index, index) || other.index == index)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrerequisite, isPrerequisite) || other.isPrerequisite == isPrerequisite)&&(identical(other.prerequisite, prerequisite) || other.prerequisite == prerequisite)&&(identical(other.status, status) || other.status == status)&&(identical(other.estimatedMinutes, estimatedMinutes) || other.estimatedMinutes == estimatedMinutes)&&(identical(other.tutorExplanation, tutorExplanation) || other.tutorExplanation == tutorExplanation)&&const DeepCollectionEquality().equals(other._socraticQuestions, _socraticQuestions)&&const DeepCollectionEquality().equals(other._quiz, _quiz)&&(identical(other.quizScore, quizScore) || other.quizScore == quizScore)&&const DeepCollectionEquality().equals(other._userAnswers, _userAnswers)&&const DeepCollectionEquality().equals(other._userFullAnswers, _userFullAnswers)&&const DeepCollectionEquality().equals(other._videos, _videos)&&const DeepCollectionEquality().equals(other._papers, _papers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,title,description,isPrerequisite,prerequisite,status,estimatedMinutes,tutorExplanation,const DeepCollectionEquality().hash(_socraticQuestions),const DeepCollectionEquality().hash(_quiz),quizScore,const DeepCollectionEquality().hash(_userAnswers),const DeepCollectionEquality().hash(_userFullAnswers),const DeepCollectionEquality().hash(_videos),const DeepCollectionEquality().hash(_papers));

@override
String toString() {
  return 'MilestoneStep(index: $index, title: $title, description: $description, isPrerequisite: $isPrerequisite, prerequisite: $prerequisite, status: $status, estimatedMinutes: $estimatedMinutes, tutorExplanation: $tutorExplanation, socraticQuestions: $socraticQuestions, quiz: $quiz, quizScore: $quizScore, userAnswers: $userAnswers, userFullAnswers: $userFullAnswers, videos: $videos, papers: $papers)';
}


}

/// @nodoc
abstract mixin class _$MilestoneStepCopyWith<$Res> implements $MilestoneStepCopyWith<$Res> {
  factory _$MilestoneStepCopyWith(_MilestoneStep value, $Res Function(_MilestoneStep) _then) = __$MilestoneStepCopyWithImpl;
@override @useResult
$Res call({
 int index, String title, String description,@JsonKey(name: 'is_prerequisite') bool isPrerequisite, String? prerequisite, String status,@JsonKey(name: 'estimated_minutes') int estimatedMinutes,@JsonKey(name: 'tutor_explanation') String? tutorExplanation,@JsonKey(name: 'socratic_questions') List<dynamic>? socraticQuestions, List<dynamic>? quiz,@JsonKey(name: 'quiz_score') double? quizScore,@JsonKey(name: 'user_answers') Map<String, dynamic>? userAnswers,@JsonKey(name: 'user_full_answers') Map<String, dynamic>? userFullAnswers, List<dynamic>? videos, List<dynamic>? papers
});




}
/// @nodoc
class __$MilestoneStepCopyWithImpl<$Res>
    implements _$MilestoneStepCopyWith<$Res> {
  __$MilestoneStepCopyWithImpl(this._self, this._then);

  final _MilestoneStep _self;
  final $Res Function(_MilestoneStep) _then;

/// Create a copy of MilestoneStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? title = null,Object? description = null,Object? isPrerequisite = null,Object? prerequisite = freezed,Object? status = null,Object? estimatedMinutes = null,Object? tutorExplanation = freezed,Object? socraticQuestions = freezed,Object? quiz = freezed,Object? quizScore = freezed,Object? userAnswers = freezed,Object? userFullAnswers = freezed,Object? videos = freezed,Object? papers = freezed,}) {
  return _then(_MilestoneStep(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPrerequisite: null == isPrerequisite ? _self.isPrerequisite : isPrerequisite // ignore: cast_nullable_to_non_nullable
as bool,prerequisite: freezed == prerequisite ? _self.prerequisite : prerequisite // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,tutorExplanation: freezed == tutorExplanation ? _self.tutorExplanation : tutorExplanation // ignore: cast_nullable_to_non_nullable
as String?,socraticQuestions: freezed == socraticQuestions ? _self._socraticQuestions : socraticQuestions // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,quiz: freezed == quiz ? _self._quiz : quiz // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,quizScore: freezed == quizScore ? _self.quizScore : quizScore // ignore: cast_nullable_to_non_nullable
as double?,userAnswers: freezed == userAnswers ? _self._userAnswers : userAnswers // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userFullAnswers: freezed == userFullAnswers ? _self._userFullAnswers : userFullAnswers // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,videos: freezed == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,papers: freezed == papers ? _self._papers : papers // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,
  ));
}


}

// dart format on
