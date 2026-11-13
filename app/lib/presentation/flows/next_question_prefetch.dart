import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chapter_providers.dart';
import '../providers/plan_providers.dart';
import '../providers/question_providers.dart';

/// 다음 문제 상세 미리 받기: 구독만 걸어 캐시 유지 (autoDispose), 넘길 때 로딩 없이 바로 표시
/// 선택지 준비(SSE 생성)는 비용이 커서 그 문제로 넘어간 뒤에만 시작 (풀이 화면 build 에서 호출)
void prefetchNextQuestionDetail(WidgetRef ref, ChapterState chapter) {
  final nextQuestionUuid = _nextQuestionUuidOf(chapter);
  if (nextQuestionUuid == null) return;
  ref.listen(questionDetailProvider(nextQuestionUuid), (_, _) {});
}

/// 무료(결제 UI 대상) 제출 성공 > 다음 문제 상세 다시 받기
/// 제출 전에 미리 받은 상세는 하루 한도 셈 이전 값 > 한도면 상세 403 > 넘어갈 때 한도 화면 (§5-4, #963)
void refetchNextQuestionDetailIfFree(WidgetRef ref, String flowId) {
  if (!ref.read(shouldShowProUiProvider)) return;
  final nextQuestionUuid = _nextQuestionUuidOf(
    ref.read(chapterProvider(flowId)),
  );
  if (nextQuestionUuid == null) return;
  ref.invalidate(questionDetailProvider(nextQuestionUuid));
}

/// 다음 문제 questionUuid (마지막 문제면 null)
String? _nextQuestionUuidOf(ChapterState chapter) {
  final nextIndex = chapter.currentIndex + 1;
  if (nextIndex >= chapter.questionUuids.length) return null;
  return chapter.questionUuids[nextIndex];
}
