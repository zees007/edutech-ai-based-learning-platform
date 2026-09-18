import 'package:freezed_annotation/freezed_annotation.dart';
import 'subscription_response.dart';

part 'user_current_profile_response.freezed.dart';
part 'user_current_profile_response.g.dart';

@freezed
abstract class UserCurrentProfileResponse with _$UserCurrentProfileResponse {
  const factory UserCurrentProfileResponse({
    required String id,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String email,
    String? mobile,
    String? country,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default([]) List<String> roles,
    SubscriptionResponse? subscription,
    @JsonKey(name: 'privilege_codes') @Default([]) List<String> privilegeCodes,
  }) = _UserCurrentProfileResponse;

  factory UserCurrentProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserCurrentProfileResponseFromJson(json);
}
