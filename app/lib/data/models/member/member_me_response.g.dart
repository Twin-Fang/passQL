// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberMeResponseImpl _$$MemberMeResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MemberMeResponseImpl(
  memberUuid: json['memberUuid'] as String,
  nickname: json['nickname'] as String,
  choiceGenerationMode: $enumDecodeNullable(
    _$ChoiceGenerationModeEnumMap,
    json['choiceGenerationMode'],
    unknownValue: ChoiceGenerationMode.practice,
  ),
  nicknameChangedAt: json['nicknameChangedAt'] == null
      ? null
      : DateTime.parse(json['nicknameChangedAt'] as String),
  authProvider: json['authProvider'] as String?,
  providerUserId: json['providerUserId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  maskedEmail: json['maskedEmail'] as String?,
  memberCode: json['memberCode'] as String?,
  email: json['email'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$$MemberMeResponseImplToJson(
  _$MemberMeResponseImpl instance,
) => <String, dynamic>{
  'memberUuid': instance.memberUuid,
  'nickname': instance.nickname,
  'choiceGenerationMode':
      _$ChoiceGenerationModeEnumMap[instance.choiceGenerationMode],
  'nicknameChangedAt': instance.nicknameChangedAt?.toIso8601String(),
  'authProvider': instance.authProvider,
  'providerUserId': instance.providerUserId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'maskedEmail': instance.maskedEmail,
  'memberCode': instance.memberCode,
  'email': instance.email,
  'profileImageUrl': instance.profileImageUrl,
};

const _$ChoiceGenerationModeEnumMap = {
  ChoiceGenerationMode.practice: 'PRACTICE',
  ChoiceGenerationMode.real: 'REAL',
};
