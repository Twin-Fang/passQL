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
);

Map<String, dynamic> _$$MemberMeResponseImplToJson(
  _$MemberMeResponseImpl instance,
) => <String, dynamic>{
  'memberUuid': instance.memberUuid,
  'nickname': instance.nickname,
  'choiceGenerationMode':
      _$ChoiceGenerationModeEnumMap[instance.choiceGenerationMode],
  'nicknameChangedAt': instance.nicknameChangedAt?.toIso8601String(),
};

const _$ChoiceGenerationModeEnumMap = {
  ChoiceGenerationMode.practice: 'PRACTICE',
  ChoiceGenerationMode.real: 'REAL',
};
