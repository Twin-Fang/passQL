// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_set_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailySetTodayResponseImpl _$$DailySetTodayResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DailySetTodayResponseImpl(
  questions:
      (json['questions'] as List<dynamic>?)
          ?.map((e) => QuestionSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  alreadyCompleted: json['alreadyCompleted'] as bool? ?? false,
  correctCount: (json['correctCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$$DailySetTodayResponseImplToJson(
  _$DailySetTodayResponseImpl instance,
) => <String, dynamic>{
  'questions': instance.questions,
  'alreadyCompleted': instance.alreadyCompleted,
  'correctCount': instance.correctCount,
};

_$DailySetCompleteResponseImpl _$$DailySetCompleteResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DailySetCompleteResponseImpl(
  correctCount: (json['correctCount'] as num).toInt(),
  rank: (json['rank'] as num).toInt(),
  totalParticipants: (json['totalParticipants'] as num).toInt(),
);

Map<String, dynamic> _$$DailySetCompleteResponseImplToJson(
  _$DailySetCompleteResponseImpl instance,
) => <String, dynamic>{
  'correctCount': instance.correctCount,
  'rank': instance.rank,
  'totalParticipants': instance.totalParticipants,
};

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardEntryImpl(
  rank: (json['rank'] as num).toInt(),
  nickname: json['nickname'] as String,
  correctCount: (json['correctCount'] as num).toInt(),
);

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
  _$LeaderboardEntryImpl instance,
) => <String, dynamic>{
  'rank': instance.rank,
  'nickname': instance.nickname,
  'correctCount': instance.correctCount,
};

_$LeaderboardResponseImpl _$$LeaderboardResponseImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardResponseImpl(
  date: json['date'] as String?,
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  myEntry: json['myEntry'] == null
      ? null
      : LeaderboardEntry.fromJson(json['myEntry'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$LeaderboardResponseImplToJson(
  _$LeaderboardResponseImpl instance,
) => <String, dynamic>{
  'date': instance.date,
  'entries': instance.entries,
  'myEntry': instance.myEntry,
};
