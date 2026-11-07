// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_me_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MemberMeResponse _$MemberMeResponseFromJson(Map<String, dynamic> json) {
  return _MemberMeResponse.fromJson(json);
}

/// @nodoc
mixin _$MemberMeResponse {
  String get memberUuid => throw _privateConstructorUsedError;
  String get nickname =>
      throw _privateConstructorUsedError; // 서버에 새 값이 생겨도 앱이 깨지지 않도록 모르는 값은 practice 로 받는다.
  @JsonKey(unknownEnumValue: ChoiceGenerationMode.practice)
  ChoiceGenerationMode? get choiceGenerationMode =>
      throw _privateConstructorUsedError;
  DateTime? get nicknameChangedAt =>
      throw _privateConstructorUsedError; // 로그인 제공자 서버 값 (GOOGLE, APPLE, KAKAO, NAVER, GITHUB): 탈퇴 연결 해제 분기 기준
  String? get authProvider =>
      throw _privateConstructorUsedError; // 제공자 회원 식별자 (GOOGLE·APPLE 은 Firebase uid): 탈퇴 재인증 계정 대조 기준
  String? get providerUserId =>
      throw _privateConstructorUsedError; // 가입 시각 (KST): 계정 화면 가입일 (#816)
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // 가린 이메일 (예: sq***@kakao.com, 이메일 없는 제공자면 null, #816)
  String? get maskedEmail =>
      throw _privateConstructorUsedError; // 회원 번호 표시값 (PQL- + UUID 앞 8자리 대문자): 문의 때 회원 확인 (#816)
  String? get memberCode =>
      throw _privateConstructorUsedError; // 소셜 계정 이메일 원문 (본인 응답 전용, 없으면 null): 계정 화면 로그인 방법 (#908)
  String? get email =>
      throw _privateConstructorUsedError; // 소셜 계정 프로필 이미지 https 주소 (없으면 null > 닉네임 첫 글자): 프로필 머리 (#908)
  String? get profileImageUrl => throw _privateConstructorUsedError;

  /// Serializes this MemberMeResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberMeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberMeResponseCopyWith<MemberMeResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberMeResponseCopyWith<$Res> {
  factory $MemberMeResponseCopyWith(
    MemberMeResponse value,
    $Res Function(MemberMeResponse) then,
  ) = _$MemberMeResponseCopyWithImpl<$Res, MemberMeResponse>;
  @useResult
  $Res call({
    String memberUuid,
    String nickname,
    @JsonKey(unknownEnumValue: ChoiceGenerationMode.practice)
    ChoiceGenerationMode? choiceGenerationMode,
    DateTime? nicknameChangedAt,
    String? authProvider,
    String? providerUserId,
    DateTime? createdAt,
    String? maskedEmail,
    String? memberCode,
    String? email,
    String? profileImageUrl,
  });
}

/// @nodoc
class _$MemberMeResponseCopyWithImpl<$Res, $Val extends MemberMeResponse>
    implements $MemberMeResponseCopyWith<$Res> {
  _$MemberMeResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberMeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberUuid = null,
    Object? nickname = null,
    Object? choiceGenerationMode = freezed,
    Object? nicknameChangedAt = freezed,
    Object? authProvider = freezed,
    Object? providerUserId = freezed,
    Object? createdAt = freezed,
    Object? maskedEmail = freezed,
    Object? memberCode = freezed,
    Object? email = freezed,
    Object? profileImageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            memberUuid: null == memberUuid
                ? _value.memberUuid
                : memberUuid // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            choiceGenerationMode: freezed == choiceGenerationMode
                ? _value.choiceGenerationMode
                : choiceGenerationMode // ignore: cast_nullable_to_non_nullable
                      as ChoiceGenerationMode?,
            nicknameChangedAt: freezed == nicknameChangedAt
                ? _value.nicknameChangedAt
                : nicknameChangedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            authProvider: freezed == authProvider
                ? _value.authProvider
                : authProvider // ignore: cast_nullable_to_non_nullable
                      as String?,
            providerUserId: freezed == providerUserId
                ? _value.providerUserId
                : providerUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            maskedEmail: freezed == maskedEmail
                ? _value.maskedEmail
                : maskedEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            memberCode: freezed == memberCode
                ? _value.memberCode
                : memberCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemberMeResponseImplCopyWith<$Res>
    implements $MemberMeResponseCopyWith<$Res> {
  factory _$$MemberMeResponseImplCopyWith(
    _$MemberMeResponseImpl value,
    $Res Function(_$MemberMeResponseImpl) then,
  ) = __$$MemberMeResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String memberUuid,
    String nickname,
    @JsonKey(unknownEnumValue: ChoiceGenerationMode.practice)
    ChoiceGenerationMode? choiceGenerationMode,
    DateTime? nicknameChangedAt,
    String? authProvider,
    String? providerUserId,
    DateTime? createdAt,
    String? maskedEmail,
    String? memberCode,
    String? email,
    String? profileImageUrl,
  });
}

/// @nodoc
class __$$MemberMeResponseImplCopyWithImpl<$Res>
    extends _$MemberMeResponseCopyWithImpl<$Res, _$MemberMeResponseImpl>
    implements _$$MemberMeResponseImplCopyWith<$Res> {
  __$$MemberMeResponseImplCopyWithImpl(
    _$MemberMeResponseImpl _value,
    $Res Function(_$MemberMeResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemberMeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberUuid = null,
    Object? nickname = null,
    Object? choiceGenerationMode = freezed,
    Object? nicknameChangedAt = freezed,
    Object? authProvider = freezed,
    Object? providerUserId = freezed,
    Object? createdAt = freezed,
    Object? maskedEmail = freezed,
    Object? memberCode = freezed,
    Object? email = freezed,
    Object? profileImageUrl = freezed,
  }) {
    return _then(
      _$MemberMeResponseImpl(
        memberUuid: null == memberUuid
            ? _value.memberUuid
            : memberUuid // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        choiceGenerationMode: freezed == choiceGenerationMode
            ? _value.choiceGenerationMode
            : choiceGenerationMode // ignore: cast_nullable_to_non_nullable
                  as ChoiceGenerationMode?,
        nicknameChangedAt: freezed == nicknameChangedAt
            ? _value.nicknameChangedAt
            : nicknameChangedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        authProvider: freezed == authProvider
            ? _value.authProvider
            : authProvider // ignore: cast_nullable_to_non_nullable
                  as String?,
        providerUserId: freezed == providerUserId
            ? _value.providerUserId
            : providerUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        maskedEmail: freezed == maskedEmail
            ? _value.maskedEmail
            : maskedEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        memberCode: freezed == memberCode
            ? _value.memberCode
            : memberCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberMeResponseImpl implements _MemberMeResponse {
  const _$MemberMeResponseImpl({
    required this.memberUuid,
    required this.nickname,
    @JsonKey(unknownEnumValue: ChoiceGenerationMode.practice)
    this.choiceGenerationMode,
    this.nicknameChangedAt,
    this.authProvider,
    this.providerUserId,
    this.createdAt,
    this.maskedEmail,
    this.memberCode,
    this.email,
    this.profileImageUrl,
  });

  factory _$MemberMeResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberMeResponseImplFromJson(json);

  @override
  final String memberUuid;
  @override
  final String nickname;
  // 서버에 새 값이 생겨도 앱이 깨지지 않도록 모르는 값은 practice 로 받는다.
  @override
  @JsonKey(unknownEnumValue: ChoiceGenerationMode.practice)
  final ChoiceGenerationMode? choiceGenerationMode;
  @override
  final DateTime? nicknameChangedAt;
  // 로그인 제공자 서버 값 (GOOGLE, APPLE, KAKAO, NAVER, GITHUB): 탈퇴 연결 해제 분기 기준
  @override
  final String? authProvider;
  // 제공자 회원 식별자 (GOOGLE·APPLE 은 Firebase uid): 탈퇴 재인증 계정 대조 기준
  @override
  final String? providerUserId;
  // 가입 시각 (KST): 계정 화면 가입일 (#816)
  @override
  final DateTime? createdAt;
  // 가린 이메일 (예: sq***@kakao.com, 이메일 없는 제공자면 null, #816)
  @override
  final String? maskedEmail;
  // 회원 번호 표시값 (PQL- + UUID 앞 8자리 대문자): 문의 때 회원 확인 (#816)
  @override
  final String? memberCode;
  // 소셜 계정 이메일 원문 (본인 응답 전용, 없으면 null): 계정 화면 로그인 방법 (#908)
  @override
  final String? email;
  // 소셜 계정 프로필 이미지 https 주소 (없으면 null > 닉네임 첫 글자): 프로필 머리 (#908)
  @override
  final String? profileImageUrl;

  @override
  String toString() {
    return 'MemberMeResponse(memberUuid: $memberUuid, nickname: $nickname, choiceGenerationMode: $choiceGenerationMode, nicknameChangedAt: $nicknameChangedAt, authProvider: $authProvider, providerUserId: $providerUserId, createdAt: $createdAt, maskedEmail: $maskedEmail, memberCode: $memberCode, email: $email, profileImageUrl: $profileImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberMeResponseImpl &&
            (identical(other.memberUuid, memberUuid) ||
                other.memberUuid == memberUuid) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.choiceGenerationMode, choiceGenerationMode) ||
                other.choiceGenerationMode == choiceGenerationMode) &&
            (identical(other.nicknameChangedAt, nicknameChangedAt) ||
                other.nicknameChangedAt == nicknameChangedAt) &&
            (identical(other.authProvider, authProvider) ||
                other.authProvider == authProvider) &&
            (identical(other.providerUserId, providerUserId) ||
                other.providerUserId == providerUserId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.maskedEmail, maskedEmail) ||
                other.maskedEmail == maskedEmail) &&
            (identical(other.memberCode, memberCode) ||
                other.memberCode == memberCode) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    memberUuid,
    nickname,
    choiceGenerationMode,
    nicknameChangedAt,
    authProvider,
    providerUserId,
    createdAt,
    maskedEmail,
    memberCode,
    email,
    profileImageUrl,
  );

  /// Create a copy of MemberMeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberMeResponseImplCopyWith<_$MemberMeResponseImpl> get copyWith =>
      __$$MemberMeResponseImplCopyWithImpl<_$MemberMeResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberMeResponseImplToJson(this);
  }
}

abstract class _MemberMeResponse implements MemberMeResponse {
  const factory _MemberMeResponse({
    required final String memberUuid,
    required final String nickname,
    @JsonKey(unknownEnumValue: ChoiceGenerationMode.practice)
    final ChoiceGenerationMode? choiceGenerationMode,
    final DateTime? nicknameChangedAt,
    final String? authProvider,
    final String? providerUserId,
    final DateTime? createdAt,
    final String? maskedEmail,
    final String? memberCode,
    final String? email,
    final String? profileImageUrl,
  }) = _$MemberMeResponseImpl;

  factory _MemberMeResponse.fromJson(Map<String, dynamic> json) =
      _$MemberMeResponseImpl.fromJson;

  @override
  String get memberUuid;
  @override
  String get nickname; // 서버에 새 값이 생겨도 앱이 깨지지 않도록 모르는 값은 practice 로 받는다.
  @override
  @JsonKey(unknownEnumValue: ChoiceGenerationMode.practice)
  ChoiceGenerationMode? get choiceGenerationMode;
  @override
  DateTime? get nicknameChangedAt; // 로그인 제공자 서버 값 (GOOGLE, APPLE, KAKAO, NAVER, GITHUB): 탈퇴 연결 해제 분기 기준
  @override
  String? get authProvider; // 제공자 회원 식별자 (GOOGLE·APPLE 은 Firebase uid): 탈퇴 재인증 계정 대조 기준
  @override
  String? get providerUserId; // 가입 시각 (KST): 계정 화면 가입일 (#816)
  @override
  DateTime? get createdAt; // 가린 이메일 (예: sq***@kakao.com, 이메일 없는 제공자면 null, #816)
  @override
  String? get maskedEmail; // 회원 번호 표시값 (PQL- + UUID 앞 8자리 대문자): 문의 때 회원 확인 (#816)
  @override
  String? get memberCode; // 소셜 계정 이메일 원문 (본인 응답 전용, 없으면 null): 계정 화면 로그인 방법 (#908)
  @override
  String? get email; // 소셜 계정 프로필 이미지 https 주소 (없으면 null > 닉네임 첫 글자): 프로필 머리 (#908)
  @override
  String? get profileImageUrl;

  /// Create a copy of MemberMeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberMeResponseImplCopyWith<_$MemberMeResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
