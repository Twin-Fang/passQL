import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../data/sources/api_providers.dart';

/// 출제 경향 화면 내용 (#523). 화면을 벗어나면 버림 (다시 들어오면 최신 문제 수로 갱신)
final examTrendReportProvider =
    FutureProvider.autoDispose<ExamTrendReportResponse>(
      (ref) => ref.read(examTrendApiProvider).getLatestReport(),
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
