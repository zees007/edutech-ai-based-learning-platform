// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuizResult {

 int get stepIndex; int get totalQuestions; int get correctCount; double get score; int get xpEarned; List<QuestionFeedback> get feedback;
/// Create a copy of QuizResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizResultCopyWith<QuizResult> get copyWith => _$QuizResultCopyWithImpl<QuizResult>(this as QuizResult, _$identity);

  /// Serializes this QuizResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizResult&&(identical(other.stepIndex, stepIndex) || other.stepIndex == stepIndex)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.score, score) || other.score == score)&&(identical(other.xpEarned, xpEarned) || other.xpEarned == xpEarned)&&const DeepCollectionEquality().equals(other.feedback, feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stepIndex,totalQuestions,correctCount,score,xpEarned,const DeepCollectionEquality().hash(feedback));

@override
String toString() {
  return 'QuizResult(stepIndex: $stepIndex, totalQuestions: $totalQuestions, correctCount: $correctCount, score: $score, xpEarned: $xpEarned, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class $QuizResultCopyWith<$Res>  {
  factory $QuizResultCopyWith(QuizResult value, $Res Function(QuizResult) _then) = _$QuizResultCopyWithImpl;
@useResult
$Res call({
 int stepIndex, int totalQuestions, int correctCount, double score, int xpEarned, List<QuestionFeedback> feedback
});




}
/// @nodoc
class _$QuizResultCopyWithImpl<$Res>
    implements $QuizResultCopyWith<$Res> {
  _$QuizResultCopyWithImpl(this._self, this._then);

  final QuizResult _self;
  final $Res Function(QuizResult) _then;

/// Create a copy of QuizResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stepIndex = null,Object? totalQuestions = null,Object? correctCount = null,Object? score = null,Object? xpEarned = null,Object? feedback = null,}) {
  return _then(_self.copyWith(
stepIndex: null == stepIndex ? _self.stepIndex : stepIndex // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,xpEarned: null == xpEarned ? _self.xpEarned : xpEarned // ignore: cast_nullable_to_non_nullable
as int,feedback: null == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as List<QuestionFeedback>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuizResult].
extension QuizResultPatterns on QuizResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuizResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuizResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuizResult value)  $default,){
final _that = this;
switch (_that) {
case _QuizResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuizResult value)?  $default,){
final _that = this;
switch (_that) {
case _QuizResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stepIndex,  int totalQuestions,  int correctCount,  double score,  int xpEarned,  List<QuestionFeedback> feedback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuizResult() when $default != null:
return $default(_that.stepIndex,_that.totalQuestions,_that.correctCount,_that.score,_that.xpEarned,_that.feedback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stepIndex,  int totalQuestions,  int correctCount,  double score,  int xpEarned,  List<QuestionFeedback> feedback)  $default,) {final _that = this;
switch (_that) {
case _QuizResult():
return $default(_that.stepIndex,_that.totalQuestions,_that.correctCount,_that.score,_that.xpEarned,_that.feedback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stepIndex,  int totalQuestions,  int correctCount,  double score,  int xpEarned,  List<QuestionFeedback> feedback)?  $default,) {final _that = this;
switch (_that) {
case _QuizResult() when $default != null:
return $default(_that.stepIndex,_that.totalQuestions,_that.correctCount,_that.score,_that.xpEarned,_that.feedback);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuizResult implements QuizResult {
  const _QuizResult({required this.stepIndex, required this.totalQuestions, required this.correctCount, required this.score, required this.xpEarned, required final  List<QuestionFeedback> feedback}): _feedback = feedback;
  factory _QuizResult.fromJson(Map<String, dynamic> json) => _$QuizResultFromJson(json);

@override final  int stepIndex;
@override final  int totalQuestions;
@override final  int correctCount;
@override final  double score;
@override final  int xpEarned;
 final  List<QuestionFeedback> _feedback;
@override List<QuestionFeedback> get feedback {
  if (_feedback is EqualUnmodifiableListView) return _feedback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_feedback);
}


/// Create a copy of QuizResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizResultCopyWith<_QuizResult> get copyWith => __$QuizResultCopyWithImpl<_QuizResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuizResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuizResult&&(identical(other.stepIndex, stepIndex) || other.stepIndex == stepIndex)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.score, score) || other.score == score)&&(identical(other.xpEarned, xpEarned) || other.xpEarned == xpEarned)&&const DeepCollectionEquality().equals(other._feedback, _feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stepIndex,totalQuestions,correctCount,score,xpEarned,const DeepCollectionEquality().hash(_feedback));

@override
String toString() {
  return 'QuizResult(stepIndex: $stepIndex, totalQuestions: $totalQuestions, correctCount: $correctCount, score: $score, xpEarned: $xpEarned, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class _$QuizResultCopyWith<$Res> implements $QuizResultCopyWith<$Res> {
  factory _$QuizResultCopyWith(_QuizResult value, $Res Function(_QuizResult) _then) = __$QuizResultCopyWithImpl;
@override @useResult
$Res call({
 int stepIndex, int totalQuestions, int correctCount, double score, int xpEarned, List<QuestionFeedback> feedback
});




}
/// @nodoc
class __$QuizResultCopyWithImpl<$Res>
    implements _$QuizResultCopyWith<$Res> {
  __$QuizResultCopyWithImpl(this._self, this._then);

  final _QuizResult _self;
  final $Res Function(_QuizResult) _then;

/// Create a copy of QuizResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stepIndex = null,Object? totalQuestions = null,Object? correctCount = null,Object? score = null,Object? xpEarned = null,Object? feedback = null,}) {
  return _then(_QuizResult(
stepIndex: null == stepIndex ? _self.stepIndex : stepIndex // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,xpEarned: null == xpEarned ? _self.xpEarned : xpEarned // ignore: cast_nullable_to_non_nullable
as int,feedback: null == feedback ? _self._feedback : feedback // ignore: cast_nullable_to_non_nullable
as List<QuestionFeedback>,
  ));
}


}


/// @nodoc
mixin _$QuestionFeedback {

 int get questionIndex; bool get isCorrect; String get studentAnswer; String get correctAnswer; String get explanation;
/// Create a copy of QuestionFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionFeedbackCopyWith<QuestionFeedback> get copyWith => _$QuestionFeedbackCopyWithImpl<QuestionFeedback>(this as QuestionFeedback, _$identity);

  /// Serializes this QuestionFeedback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestionFeedback&&(identical(other.questionIndex, questionIndex) || other.questionIndex == questionIndex)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect)&&(identical(other.studentAnswer, studentAnswer) || other.studentAnswer == studentAnswer)&&(identical(other.correctAnswer, correctAnswer) || other.correctAnswer == correctAnswer)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionIndex,isCorrect,studentAnswer,correctAnswer,explanation);

@override
String toString() {
  return 'QuestionFeedback(questionIndex: $questionIndex, isCorrect: $isCorrect, studentAnswer: $studentAnswer, correctAnswer: $correctAnswer, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $QuestionFeedbackCopyWith<$Res>  {
  factory $QuestionFeedbackCopyWith(QuestionFeedback value, $Res Function(QuestionFeedback) _then) = _$QuestionFeedbackCopyWithImpl;
@useResult
$Res call({
 int questionIndex, bool isCorrect, String studentAnswer, String correctAnswer, String explanation
});




}
/// @nodoc
class _$QuestionFeedbackCopyWithImpl<$Res>
    implements $QuestionFeedbackCopyWith<$Res> {
  _$QuestionFeedbackCopyWithImpl(this._self, this._then);

  final QuestionFeedback _self;
  final $Res Function(QuestionFeedback) _then;

/// Create a copy of QuestionFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionIndex = null,Object? isCorrect = null,Object? studentAnswer = null,Object? correctAnswer = null,Object? explanation = null,}) {
  return _then(_self.copyWith(
questionIndex: null == questionIndex ? _self.questionIndex : questionIndex // ignore: cast_nullable_to_non_nullable
as int,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,studentAnswer: null == studentAnswer ? _self.studentAnswer : studentAnswer // ignore: cast_nullable_to_non_nullable
as String,correctAnswer: null == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as String,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestionFeedback].
extension QuestionFeedbackPatterns on QuestionFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestionFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestionFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestionFeedback value)  $default,){
final _that = this;
switch (_that) {
case _QuestionFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestionFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _QuestionFeedback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int questionIndex,  bool isCorrect,  String studentAnswer,  String correctAnswer,  String explanation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestionFeedback() when $default != null:
return $default(_that.questionIndex,_that.isCorrect,_that.studentAnswer,_that.correctAnswer,_that.explanation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int questionIndex,  bool isCorrect,  String studentAnswer,  String correctAnswer,  String explanation)  $default,) {final _that = this;
switch (_that) {
case _QuestionFeedback():
return $default(_that.questionIndex,_that.isCorrect,_that.studentAnswer,_that.correctAnswer,_that.explanation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int questionIndex,  bool isCorrect,  String studentAnswer,  String correctAnswer,  String explanation)?  $default,) {final _that = this;
switch (_that) {
case _QuestionFeedback() when $default != null:
return $default(_that.questionIndex,_that.isCorrect,_that.studentAnswer,_that.correctAnswer,_that.explanation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestionFeedback implements QuestionFeedback {
  const _QuestionFeedback({required this.questionIndex, required this.isCorrect, required this.studentAnswer, required this.correctAnswer, required this.explanation});
  factory _QuestionFeedback.fromJson(Map<String, dynamic> json) => _$QuestionFeedbackFromJson(json);

@override final  int questionIndex;
@override final  bool isCorrect;
@override final  String studentAnswer;
@override final  String correctAnswer;
@override final  String explanation;

/// Create a copy of QuestionFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionFeedbackCopyWith<_QuestionFeedback> get copyWith => __$QuestionFeedbackCopyWithImpl<_QuestionFeedback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionFeedbackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestionFeedback&&(identical(other.questionIndex, questionIndex) || other.questionIndex == questionIndex)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect)&&(identical(other.studentAnswer, studentAnswer) || other.studentAnswer == studentAnswer)&&(identical(other.correctAnswer, correctAnswer) || other.correctAnswer == correctAnswer)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionIndex,isCorrect,studentAnswer,correctAnswer,explanation);

@override
String toString() {
  return 'QuestionFeedback(questionIndex: $questionIndex, isCorrect: $isCorrect, studentAnswer: $studentAnswer, correctAnswer: $correctAnswer, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class _$QuestionFeedbackCopyWith<$Res> implements $QuestionFeedbackCopyWith<$Res> {
  factory _$QuestionFeedbackCopyWith(_QuestionFeedback value, $Res Function(_QuestionFeedback) _then) = __$QuestionFeedbackCopyWithImpl;
@override @useResult
$Res call({
 int questionIndex, bool isCorrect, String studentAnswer, String correctAnswer, String explanation
});




}
/// @nodoc
class __$QuestionFeedbackCopyWithImpl<$Res>
    implements _$QuestionFeedbackCopyWith<$Res> {
  __$QuestionFeedbackCopyWithImpl(this._self, this._then);

  final _QuestionFeedback _self;
  final $Res Function(_QuestionFeedback) _then;

/// Create a copy of QuestionFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionIndex = null,Object? isCorrect = null,Object? studentAnswer = null,Object? correctAnswer = null,Object? explanation = null,}) {
  return _then(_QuestionFeedback(
questionIndex: null == questionIndex ? _self.questionIndex : questionIndex // ignore: cast_nullable_to_non_nullable
as int,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,studentAnswer: null == studentAnswer ? _self.studentAnswer : studentAnswer // ignore: cast_nullable_to_non_nullable
as String,correctAnswer: null == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as String,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
