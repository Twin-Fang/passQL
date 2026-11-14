import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/exam_answer/exam_grading_rule.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/safe_call.dart';
import '../../core/utils/app_clock.dart';
import '../../data/exam_answer/exam_answer_repository.dart';
import '../../data/models/exam_answer/exam_answer_round_response.dart';
import 'exam_schedule_providers.dart';
import 'session_reset.dart';

/// 회차 키: 시험 종류(SQLD) + 회차 번호
typedef ExamAnswerRoundKey = ({String certType, int roundNumber});

/// 회차 가답안 (#1075): 화면을 떠나면 버림, 당겨서 새로고침으로 다시 받음
final examAnswerRoundProvider = FutureProvider.autoDispose
    .family<ExamAnswerRoundResponse, ExamAnswerRoundKey>(
      (ref, roundKey) => ref
          .read(examAnswerRepositoryProvider)
          .fetchRound(roundKey.certType, roundKey.roundNumber),
    );

/// 홈 진입 카드 회차: 올해 SQLD 일정 중 시행일이 지난 가장 최근 회차 > 가답안 상태가 수집 중·공식 반영이면 노출
/// 일정·회차 조회 실패나 가답안 없음(404)은 카드 숨김
final examAnswerHomeEntryProvider =
    FutureProvider.autoDispose<ExamAnswerRoundResponse?>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) return null;
      final overview = await safeCall(
        ref.watch(sqldExamScheduleOverviewProvider.future),
        label: 'examAnswerHomeSchedule',
      );
      final now = AppClock.now();
      final today = DateTime(now.year, now.month, now.day);
      final heldSchedules =
          (overview?.schedules ?? const [])
              .where(
                (schedule) =>
                    DateTime.tryParse(schedule.examDate)?.isAfter(today) ==
                    false,
              )
              .toList()
            ..sort((first, second) => first.round.compareTo(second.round));
      if (heldSchedules.isEmpty) return null;
      final latestSchedule = heldSchedules.last;
      final roundResponse = await safeCall(
        ref
            .read(examAnswerRepositoryProvider)
            .fetchRound(latestSchedule.certType, latestSchedule.round),
        label: 'examAnswerHomeRound',
      );
      return roundResponse != null && roundResponse.status.isOpenForEntry
          ? roundResponse
          : null;
    });

/// 내 가채점 상태: 입력 중 답안·채점 결과·채점 중·오류·편집 모드
class ExamAnswerSheetState {
  const ExamAnswerSheetState({
    required this.answers,
    this.gradedSheet,
    this.isLoaded = false,
    this.isGrading = false,
    this.isEditing = true,
    this.gradingError,
  });

  /// 답안 50자: '1'~'4' 보기, '0' 모름, '.' 미입력
  final String answers;
  final ExamAnswerMySheet? gradedSheet;
  final bool isLoaded;
  final bool isGrading;

  /// OMR 입력 화면인지 (false 면 결과 화면)
  final bool isEditing;
  final AppException? gradingError;

  // 미입력 자리 표시 (제출 때 모름 '0' 으로 바꿈)
  static const String emptyMark = '.';

  /// 빈 답안 (문항 수는 회차 채점 규칙, 불러오기 전엔 대체 규칙)
  static String emptyAnswersOf(ExamGradingRule rule) =>
      emptyMark * rule.questionCount;

  int get enteredCount =>
      answers.split('').where((mark) => mark != emptyMark).length;

  bool get isComplete => enteredCount == answers.length;

  /// 제출용 답안 (미입력 > 모름)
  String get submittableAnswers =>
      answers.replaceAll(emptyMark, '${ExamGradingRule.unknownAnswer}');

  /// 채점 뒤 답안을 고쳐 결과가 지금 답안과 다른지
  bool get isGradeOutdated =>
      gradedSheet != null && gradedSheet!.answers != submittableAnswers;

  ExamAnswerSheetState copyWith({
    String? answers,
    ExamAnswerMySheet? gradedSheet,
    bool? isLoaded,
    bool? isGrading,
    bool? isEditing,
    AppException? gradingError,
    bool shouldClearGradingError = false,
  }) => ExamAnswerSheetState(
    answers: answers ?? this.answers,
    gradedSheet: gradedSheet ?? this.gradedSheet,
    isLoaded: isLoaded ?? this.isLoaded,
    isGrading: isGrading ?? this.isGrading,
    isEditing: isEditing ?? this.isEditing,
    gradingError: shouldClearGradingError
        ? null
        : gradingError ?? this.gradingError,
  );
}

/// 내 가채점: 불러오기(임시 답안 > 서버 답안지) > OMR 입력·자동 저장 > 채점
class ExamAnswerSheetNotifier
    extends
        AutoDisposeFamilyNotifier<ExamAnswerSheetState, ExamAnswerRoundKey> {
  // 로그 접두사
  static const String _logTag = 'exam answer sheet';

  @override
  ExamAnswerSheetState build(ExamAnswerRoundKey roundKey) {
    unawaited(Future.microtask(_load));
    return ExamAnswerSheetState(
      answers: ExamAnswerSheetState.emptyAnswersOf(
        ExamGradingRule.sqldFallback,
      ),
    );
  }

  ExamAnswerRepository get _repository =>
      ref.read(examAnswerRepositoryProvider);

  /// 불러오기: 임시 답안이 있으면 그 답안, 없으면 서버 답안지 (결과는 서버 답안지 기준)
  Future<void> _load() async {
    final draftAnswers = await _repository.readDraftAnswers(
      arg.certType,
      arg.roundNumber,
    );
    ExamAnswerMySheet? serverSheet;
    var rule = ExamGradingRule.sqldFallback;
    try {
      final roundResponse = await ref.read(examAnswerRoundProvider(arg).future);
      rule = roundResponse.effectiveGradingRule;
      serverSheet = await _repository.fetchMySheet(roundResponse);
    } catch (exception) {
      // 회차·답안지 조회 실패 > 임시 답안만으로 입력 (회차 오류는 화면이 따로 보여 줌)
      AppLogger.warn(
        _logTag,
        'sheet load failed : ${exception.asAppException}',
      );
    }
    final answers =
        _normalizedDraft(draftAnswers, rule) ??
        serverSheet?.answers ??
        ExamAnswerSheetState.emptyAnswersOf(rule);
    state = state.copyWith(
      answers: answers,
      gradedSheet: serverSheet,
      isLoaded: true,
      // 채점한 답안지가 있으면 결과부터
      isEditing: serverSheet == null,
    );
  }

  /// 보기 선택 (같은 보기를 다시 누르면 지움, [choice] 0 = 모름) > 임시 저장
  void selectAnswer(int questionNo, int choice) {
    final index = questionNo - 1;
    if (index < 0 || index >= state.answers.length) return;
    final currentMark = state.answers[index];
    final nextMark = currentMark == '$choice'
        ? ExamAnswerSheetState.emptyMark
        : '$choice';
    final answers = state.answers.replaceRange(index, index + 1, nextMark);
    state = state.copyWith(answers: answers);
    unawaited(
      _repository.saveDraftAnswers(arg.certType, arg.roundNumber, answers),
    );
  }

  /// 채점: 제출(서버 채점, 실패면 기기 계산) > 결과 화면
  Future<void> grade() async {
    if (state.isGrading) return;
    state = state.copyWith(isGrading: true, shouldClearGradingError: true);
    try {
      final roundResponse = await ref.read(examAnswerRoundProvider(arg).future);
      final gradedSheet = await _repository.submitSheet(
        roundResponse,
        state.submittableAnswers,
      );
      state = state.copyWith(
        gradedSheet: gradedSheet,
        isGrading: false,
        isEditing: false,
      );
    } catch (exception) {
      state = state.copyWith(
        isGrading: false,
        gradingError: exception.asAppException,
      );
    }
  }

  void startEditing() => state = state.copyWith(isEditing: true);

  /// 고친 답안이 없으면 이전 결과로 돌아감
  void showResult() {
    if (state.gradedSheet == null) return;
    state = state.copyWith(isEditing: false);
  }

  // 저장 형식이 맞는 임시 답안만 (길이 = 회차 문항 수)
  static String? _normalizedDraft(String? draftAnswers, ExamGradingRule rule) =>
      draftAnswers?.length == rule.questionCount ? draftAnswers : null;
}

final examAnswerSheetProvider = NotifierProvider.autoDispose
    .family<ExamAnswerSheetNotifier, ExamAnswerSheetState, ExamAnswerRoundKey>(
      ExamAnswerSheetNotifier.new,
    );
