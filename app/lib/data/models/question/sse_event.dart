import '../../../core/error/app_exception.dart';
import 'choice_item.dart';

/// SSE 이벤트 계층. 코드 생성 없이 수동 파싱 사용.
sealed class SseEvent {}

/// 선택지 생성 진행 중 상태 메시지.
class SseStatusEvent extends SseEvent {
  final String message;
  SseStatusEvent(this.message);
}

/// 선택지 생성 완료. choices와 choiceSetId를 포함.
class SseCompleteEvent extends SseEvent {
  final List<ChoiceItem> choices;
  final String choiceSetId;
  SseCompleteEvent(this.choices, this.choiceSetId);
}

/// 선택지 생성 실패. retryable=true면 재시도 버튼 표시.
class SseErrorEvent extends SseEvent {
  /// 서버 오류 코드 (예: GENERATION_FAILED, CHOICE_SET_GENERATION_FAILED, 앱 내부 STREAM_CLOSED)
  final String code;
  final bool isRetryable;

  /// 연결 단계 실패의 공통 변환 결과 (서버 거부면 errorCode·문구 포함, 프로 접근 안내 판정용). 스트림 안 error 이벤트는 null
  final AppException? connectFailure;

  SseErrorEvent(this.code, this.isRetryable, {this.connectFailure});
}
