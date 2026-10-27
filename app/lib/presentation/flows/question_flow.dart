import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/monitoring/app_analytics.dart';
import '../providers/chapter_providers.dart';
import '../providers/topic_providers.dart';
import '../../router/app_routes.dart';

/// 문제 묶음을 순서대로 푸는 흐름의 종류.
///
/// 풀이 화면(`ChapterPage`)은 흐름이 달라도 같다. 흐름마다 다른 두 가지만 여기서 정한다.
/// - 풀 문제 목록을 어디서 가져오는가
/// - 마지막 문제를 제출한 뒤 무엇을 하는가
/// 새 풀이 방식(모의고사, 복습 등)은 이 클래스를 구현하기만 하면 같은 화면을 쓴다.
abstract class QuestionFlow {
  const QuestionFlow();

  /// 상태를 구분하는 키. 같은 키의 흐름은 같은 진행 상태를 공유한다.
  String get id;

  /// 앱바에 보여줄 이름.
  String get title;

  /// 서버에 세션 단위로 기록해야 하는 흐름인지.
  /// true 면 답안을 제출할 때 같은 세션 UUID 를 함께 보낸다.
  bool get shouldTrackSession => false;

  /// 신규 가입 온보딩에서 들어온 풀이인지 (첫 문제 배지·첫 문제 뒤 축하 화면)
  bool get isOnboarding => false;

  /// 풀 문제의 UUID 목록. 실패하면 사용자에게 보여줄 수 있는 예외를 던진다.
  Future<List<String>> loadQuestionUuids(WidgetRef ref);

  /// 풀이 시작 정보. 기본은 처음부터, 이어 풀기가 있는 흐름만 덮어쓴다 (#566)
  Future<ChapterStart> loadStart(WidgetRef ref) async =>
      ChapterStart(questionUuids: await loadQuestionUuids(ref));

  /// 마지막 문제 제출 후 처리. [sessionUuid] 는 이번 풀이의 세션 식별자다.
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  );
}

/// 토픽(챕터) 하나에서 10문제를 푸는 흐름.
/// [isLatestTrendOnly] 면 그 토픽의 최신 출제 경향 문제만 (홈 출제 경향 카드·문제 탭 최신 경향·개념 TOP 10에서 진입, #523)
class TopicFlow extends QuestionFlow {
  const TopicFlow({
    required this.topicCode,
    required this.topicName,
    this.isLatestTrendOnly = false,
  });

  final String topicCode;
  final String topicName;
  final bool isLatestTrendOnly;

  // 일반 챕터와 진행 상태를 섞지 않는다
  @override
  String get id =>
      isLatestTrendOnly ? 'topic:$topicCode:latestTrend' : 'topic:$topicCode';

  @override
  String get title => isLatestTrendOnly ? '$topicName 최신 경향' : topicName;

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) {
    return ref
        .read(topicChapterServiceProvider)
        .fetchQuestionUuids(topicCode, isLatestTrendOnly: isLatestTrendOnly);
  }

  @override
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  ) async {
    ref
        .read(appAnalyticsProvider)
        .logChapterCompleted(
          topicCode: topicCode,
          correctCount: summary.results
              .where((result) => result.isCorrect)
              .length,
          questionCount: summary.results.length,
        );
    // 챕터 화면 자리를 결과로 교체 (뒤로 가기 > 챕터 진입 전 화면)
    context.pushReplacement(AppRoutes.chapterResult, extra: summary);
  }
}
