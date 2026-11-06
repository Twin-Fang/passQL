import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/error_code.dart';
import '../../data/models/mock_exam/mock_exam_enums.dart';
import '../../data/models/mock_exam/mock_exam_sheet.dart';
import '../../data/sources/api_providers.dart';
import '../../data/sources/mock_exam_api.dart';
import 'learning_refresh.dart';
import 'mock_exam_countdown.dart';
import 'mock_exam_providers.dart';
import 'mock_exam_session_state.dart';

/// 모의고사 풀이 상태 (응시 UUID 별): 시험지 받기 > 보기 고르기·표시(바로 저장) > 다시 맞추기 > 제출
/// 시간·채점은 서버 판정, 기기는 서버 남은 초 + 단조 시계로 표시만
final mockExamSessionProvider = AsyncNotifierProvider.autoDispose
    .family<MockExamSessionNotifier, MockExamSessionState, String>(
      MockExamSessionNotifier.new,
    );

class MockExamSessionNotifier
    extends AutoDisposeFamilyAsyncNotifier<MockExamSessionState, String> {
  final Stopwatch _sinceSync = Stopwatch();
  int _remainingSecondsAtSync = 0;
  // 저장 요청을 순서대로 (늦게 도착한 옛 선택이 새 선택을 덮지 않게)
  Future<void> _saveQueue = Future.value();

  MockExamApiClient get _mockExamApi => ref.read(mockExamApiProvider);

  String get _attemptUuid => arg;

  @override
  Future<MockExamSessionState> build(String attemptUuid) async {
    final sheet = await _mockExamApi.getSheet(attemptUuid);
    _restartCountdown(sheet.remainingSeconds);
    return MockExamSessionState(
      sheet: sheet,
      currentIndex: 0,
      answerByNumber: answersFromSheet(sheet),
      isFinished: sheet.status != MockExamAttemptStatus.inProgress,
    );
  }

  /// 지금 남은 시간 (서버 값 + 단조 경과)
  MockExamCountdown get countdown => MockExamCountdown(
    remainingSecondsAtSync: _remainingSecondsAtSync,
    elapsedSinceSync: () => _sinceSync.elapsed,
  );

  /// 보기 고르기: 같은 보기를 다시 누르면 선택 해제
  void selectChoice(String choiceKey) {
    final current = state.valueOrNull;
    if (current == null || current.isFinished) return;
    final questionNumber = current.currentQuestion.questionNumber;
    final answer = current.answerOf(questionNumber);
    final nextKey = answer.selectedChoiceKey == choiceKey ? null : choiceKey;
    _updateAnswer(
      questionNumber,
      answer.copyWith(selectedChoiceKey: () => nextKey, isSynced: false),
    );
  }

  /// 현재 문항 표시 켜기·끄기
  void toggleFlag() {
    final current = state.valueOrNull;
    if (current == null || current.isFinished) return;
    final questionNumber = current.currentQuestion.questionNumber;
    final answer = current.answerOf(questionNumber);
    _updateAnswer(
      questionNumber,
      answer.copyWith(isFlagged: !answer.isFlagged, isSynced: false),
    );
  }

  void goTo(int index) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (index < 0 || index >= current.questions.length) return;
    state = AsyncData(current.copyWith(currentIndex: index));
  }

  /// 서버와 다시 맞추기 (앱 복귀·주기): 저장 못 한 답 먼저 보냄 > 시험지·남은 시간 다시 받기
  Future<void> resync() async {
    final current = state.valueOrNull;
    if (current == null || current.isFinished || current.isSubmitting) return;
    await _retryUnsyncedAnswers();
    try {
      final sheet = await _mockExamApi.getSheet(_attemptUuid);
      final latest = state.valueOrNull ?? current;
      _restartCountdown(sheet.remainingSeconds);
      state = AsyncData(
        latest.copyWith(
          sheet: sheet.questions.isEmpty ? latest.sheet : sheet,
          answerByNumber: sheet.questions.isEmpty
              ? latest.answerByNumber
              : mergeUnsyncedAnswers(
                  answersFromSheet(sheet),
                  latest.answerByNumber,
                ),
          isFinished: sheet.status != MockExamAttemptStatus.inProgress,
        ),
      );
    } catch (error) {
      // 네트워크 끊김: 기기 타이머로 계속 (다음 주기에 다시 맞춤), 인증 만료는 위로
      if (error.asAppException.code == ErrorCode.unauthorized) rethrow;
    }
  }

  /// 제출 (멱등): 기기 답 전부를 묶어 보냄 > 채점 끝 표시 > 학습 현황 갱신
  Future<void> submit() async {
    final current = state.valueOrNull;
    if (current == null || current.isSubmitting || current.isFinished) return;
    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      await _saveQueue;
      final latest = state.valueOrNull ?? current;
      await _mockExamApi.submit(
        _attemptUuid,
        MockExamSubmitRequest(answers: _toAnswerEntries(latest)),
      );
      _finish();
    } catch (error) {
      if (_isAttemptClosed(error)) {
        _finish();
        return;
      }
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(isSubmitting: false),
      );
      rethrow;
    }
  }

  void _finish() {
    final latest = state.valueOrNull;
    if (latest != null) {
      state = AsyncData(latest.copyWith(isSubmitting: false, isFinished: true));
    }
    _sinceSync.stop();
    refreshLearningData(ref.invalidate);
    ref.invalidate(mockExamRoundsProvider);
    ref.invalidate(mockExamHistoryProvider);
  }

  void _updateAnswer(int questionNumber, MockExamLocalAnswer answer) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        answerByNumber: {...current.answerByNumber, questionNumber: answer},
      ),
    );
    _saveQueue = _saveQueue.then((_) => _saveAnswer(questionNumber));
  }

  /// 문항 1개 저장: 성공 > 저장됨, 시간 끝·이미 제출 > 채점 끝, 그 외 실패 > 저장 안 됨 유지
  Future<void> _saveAnswer(int questionNumber) async {
    final current = state.valueOrNull;
    if (current == null || current.isFinished) return;
    final answer = current.answerOf(questionNumber);
    try {
      final response = await _mockExamApi.saveAnswer(
        _attemptUuid,
        questionNumber,
        MockExamAnswerSaveRequest(
          selectedChoiceKey: answer.selectedChoiceKey,
          isFlagged: answer.isFlagged,
        ),
      );
      _restartCountdown(response.remainingSeconds);
      final latest = state.valueOrNull;
      if (latest == null) return;
      // 저장 중 다시 바뀌었으면 다음 저장이 맡음
      final latestAnswer = latest.answerOf(questionNumber);
      if (latestAnswer.selectedChoiceKey == answer.selectedChoiceKey &&
          latestAnswer.isFlagged == answer.isFlagged) {
        state = AsyncData(
          latest.copyWith(
            answerByNumber: {
              ...latest.answerByNumber,
              questionNumber: latestAnswer.copyWith(isSynced: true),
            },
          ),
        );
      }
    } catch (error) {
      if (_isAttemptClosed(error)) _finish();
    }
  }

  Future<void> _retryUnsyncedAnswers() async {
    final current = state.valueOrNull;
    if (current == null) return;
    for (final entry in current.answerByNumber.entries) {
      if (!entry.value.isSynced) {
        _saveQueue = _saveQueue.then((_) => _saveAnswer(entry.key));
      }
    }
    await _saveQueue;
  }

  void _restartCountdown(int remainingSeconds) {
    _remainingSecondsAtSync = remainingSeconds;
    _sinceSync
      ..reset()
      ..start();
  }

  static List<MockExamAnswerEntry> _toAnswerEntries(
    MockExamSessionState state,
  ) => [
    for (final entry in state.answerByNumber.entries)
      if (entry.value.isAnswered || entry.value.isFlagged)
        MockExamAnswerEntry(
          questionNumber: entry.key,
          selectedChoiceKey: entry.value.selectedChoiceKey,
          isFlagged: entry.value.isFlagged,
        ),
  ];

  /// 서버가 이미 채점한 응시 (시간 끝 자동 제출·다른 기기 제출)
  static bool _isAttemptClosed(Object error) {
    final code = error.asAppException.code;
    return code == ErrorCode.mockExamTimeOver ||
        code == ErrorCode.mockExamAlreadySubmitted;
  }
}
