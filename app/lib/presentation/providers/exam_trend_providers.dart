import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../data/sources/api_providers.dart';
import 'pro_ui_providers.dart';

/// 출제 경향 화면 내용 (#523). 화면을 벗어나면 버림 (다시 들어오면 최신 문제 수로 갱신)
/// null = 잠금: 무료(결제 켜짐)면 요청 없이 null > 화면이 본문 블러
final examTrendReportProvider =
    FutureProvider.autoDispose<ExamTrendReportResponse?>((ref) async {
      final examTrendApi = ref.read(examTrendApiProvider);
      if (await watchIsProFeatureLocked(ref)) return null;
      return examTrendApi.getLatestReport();
    });

/// 토픽 코드 > 최신 경향 문제 수 (토픽 목록 '최신 경향' 표시, 1개 이상인 토픽만)
/// 무료(결제 켜짐)면 요청 없이 빈 값, 프로가 되면 잠금 판정이 바뀌어 다시 받음
final latestTrendQuestionCountByTopicProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
      final examTrendApi = ref.read(examTrendApiProvider);
      if (await watchIsProFeatureLocked(ref)) return const {};
      final topicCounts = await examTrendApi.getLatestTrendTopics();
      return {
        for (final topicCount in topicCounts)
          if (topicCount.latestTrendQuestionCount > 0)
            topicCount.topicCode: topicCount.latestTrendQuestionCount,
      };
    });
