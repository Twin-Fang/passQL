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
  return studyTips[_dailyRotationIndexOf(studyTips.length, date)];
}

/// 날짜별 시작 항목으로 돌린 목록: 오늘 순번 항목부터, 순서는 유지 (같은 날은 같은 시작)
List<T> rotateToDailyStart<T>(List<T> items, DateTime date) {
  if (items.isEmpty) return items;
  final startIndex = _dailyRotationIndexOf(items.length, date);
  return [...items.skip(startIndex), ...items.take(startIndex)];
}

/// 연중 일수 % 항목 수 (날짜별 순환 공통)
int _dailyRotationIndexOf(int itemCount, DateTime date) {
  // 서머타임으로 하루가 23시간이어도 일수가 어긋나지 않도록 UTC 기준
  final dayOfYear = DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(date.year)).inDays;
  return dayOfYear % itemCount;
}
