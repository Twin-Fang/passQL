import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/api_providers.dart';
import '../providers/chapter_providers.dart';

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
  bool get tracksSession => false;

  /// 풀 문제의 UUID 목록. 실패하면 사용자에게 보여줄 수 있는 예외를 던진다.
  Future<List<String>> loadQuestionUuids(WidgetRef ref);

  /// 마지막 문제 제출 후 처리. [sessionUuid] 는 이번 풀이의 세션 식별자다.
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  );
}

/// 토픽(챕터) 하나에서 10문제를 푸는 흐름.
class TopicFlow extends QuestionFlow {
  const TopicFlow({required this.topicCode, required this.topicName});

  final String topicCode;
  final String topicName;

  @override
  String get id => 'topic:$topicCode';

  @override
  String get title => topicName;

  @override
  Future<List<String>> loadQuestionUuids(WidgetRef ref) async {
    final response = await ref
        .read(questionApiProvider)
        .getQuestions(0, 10, topic: topicCode);
    return response.content.map((q) => q.questionUuid).toList();
  }

  @override
  Future<void> onCompleted(
    BuildContext context,
    WidgetRef ref,
    ChapterSummary summary,
    String sessionUuid,
  ) async {
    // 경로의 sessionId 는 라우트 파라미터를 채우기 위한 값일 뿐 화면에서 쓰지 않는다.
    context.go('/practice/chapter-${const Uuid().v4()}/result', extra: summary);
  }
}
