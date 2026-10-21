import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../data/sources/api_providers.dart';
import 'session_reset.dart';

/// 출제 경향 응답 (홈·문제 탭 공용, #523). 화면을 벗어나면 버림 (다시 들어오면 최신 문제 수로 갱신)
/// 로그아웃이면 로딩 유지 (API 호출 없음)
final examTrendReportProvider =
    FutureProvider.autoDispose<ExamTrendReportResponse>(
      (ref) => ref.watch(currentMemberUuidProvider) == null
          ? waitForSignedInMember()
          : ref.read(examTrendApiProvider).getLatestReport(),
    );

/// 토픽 코드 > 최신 경향 문제 수 (토픽 목록 '최신 경향' 표시, 1개 이상인 토픽만)
final latestTrendQuestionCountByTopicProvider =
    FutureProvider<Map<String, int>>((ref) async {
      final topicCounts = await ref
          .read(examTrendApiProvider)
          .getLatestTrendTopics();
      return {
        for (final topicCount in topicCounts)
          if (topicCount.latestTrendQuestionCount > 0)
            topicCount.topicCode: topicCount.latestTrendQuestionCount,
      };
    });

/// 오늘의 공부 팁 1건: 연중 일수 순환 (목록 비면 null, 같은 날은 같은 팁)
String? selectDailyStudyTip(List<String> studyTips, DateTime date) {
  if (studyTips.isEmpty) return null;
  // 서머타임으로 하루가 23시간이어도 일수가 어긋나지 않도록 UTC 기준
  final dayOfYear = DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(date.year)).inDays;
  return studyTips[dayOfYear % studyTips.length];
}
