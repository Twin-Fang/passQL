import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_event_names.dart';

/// 분석 수집 저수준 전송: 이벤트, 화면 조회, 회원 식별자
/// 기본은 아무것도 하지 않는 구현 > main 에서 Firebase 구현으로 교체 (테스트는 Firebase 없이 동작)
abstract class AnalyticsBackend {
  const AnalyticsBackend();

  Future<void> logEvent(String eventName, Map<String, Object> parameters);

  Future<void> logScreenView(String screenName);

  /// null 이면 해제 (회원 UUID 만)
  Future<void> setMemberIdentifier(String? memberUuid);
}

/// 수집하지 않는 구현 (테스트·Firebase 초기화 전)
class NoopAnalyticsBackend extends AnalyticsBackend {
  const NoopAnalyticsBackend();

  @override
  Future<void> logEvent(
    String eventName,
    Map<String, Object> parameters,
  ) async {}

  @override
  Future<void> logScreenView(String screenName) async {}

  @override
  Future<void> setMemberIdentifier(String? memberUuid) async {}
}

/// 앱 분석 공통 지점: 핵심 이벤트 8종·화면 조회·회원 식별자 기록
/// 이벤트 이름·파라미터는 [AnalyticsEventNames]·[AnalyticsParameterNames] 한 곳에서만 씀
class AppAnalytics {
  const AppAnalytics(this._backend);

  final AnalyticsBackend _backend;

  /// 앱 전역 분석기. 라우터처럼 ref 가 없는 곳도 이 값을 씀
  static AppAnalytics current = const AppAnalytics(NoopAnalyticsBackend());

  /// 로그인 완료. [loginMethod]: google, apple
  Future<void> logLoginCompleted(String loginMethod) => _backend.logEvent(
    AnalyticsEventNames.login,
    {AnalyticsParameterNames.method: loginMethod},
  );

  /// 문제 답안 제출 결과 (토픽 이름은 알 때만)
  Future<void> logAnswerSubmitted({
    required bool isCorrect,
    String? topicName,
  }) => _backend.logEvent(AnalyticsEventNames.answerSubmitted, {
    AnalyticsParameterNames.isCorrect: isCorrect ? 1 : 0,
    AnalyticsParameterNames.topicName: ?topicName,
  });

  Future<void> logDailySetCompleted({
    required int correctCount,
    required int questionCount,
  }) => _backend.logEvent(AnalyticsEventNames.dailySetCompleted, {
    AnalyticsParameterNames.correctCount: correctCount,
    AnalyticsParameterNames.questionCount: questionCount,
  });

  Future<void> logChapterCompleted({
    required String topicCode,
    required int correctCount,
    required int questionCount,
  }) => _backend.logEvent(AnalyticsEventNames.chapterCompleted, {
    AnalyticsParameterNames.topicCode: topicCode,
    AnalyticsParameterNames.correctCount: correctCount,
    AnalyticsParameterNames.questionCount: questionCount,
  });

  Future<void> logWrongNotesOpened() =>
      _backend.logEvent(AnalyticsEventNames.wrongNotesOpened, const {});

  /// 건의 전송 성공 (본문은 보내지 않음)
  Future<void> logFeedbackSent() =>
      _backend.logEvent(AnalyticsEventNames.feedbackSent, const {});

  /// 문제 신고 성공 (사유·상세 내용은 보내지 않음)
  Future<void> logQuestionReported() =>
      _backend.logEvent(AnalyticsEventNames.questionReported, const {});

  /// AI 해설 요청. [isErrorExplanation] true: SQL 실행 오류, false: 오답
  Future<void> logAiExplanationRequested({required bool isErrorExplanation}) =>
      _backend.logEvent(AnalyticsEventNames.aiExplanationRequested, {
        AnalyticsParameterNames.explanationType: isErrorExplanation
            ? _sqlErrorExplanationType
            : _wrongAnswerExplanationType,
      });

  Future<void> logScreenView(String screenName) =>
      _backend.logScreenView(screenName);

  Future<void> setMemberIdentifier(String? memberUuid) =>
      _backend.setMemberIdentifier(memberUuid);

  // explanation_type 값
  static const String _sqlErrorExplanationType = 'sql_error';
  static const String _wrongAnswerExplanationType = 'wrong_answer';
}

/// 화면·상태 코드용 분석기 (테스트는 가짜 backend 로 override)
final appAnalyticsProvider = Provider<AppAnalytics>(
  (ref) => AppAnalytics.current,
);
