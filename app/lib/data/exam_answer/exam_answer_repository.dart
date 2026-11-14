import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/error_code.dart';
import '../../core/exam_answer/exam_answer_device_store.dart';
import '../../core/exam_answer/exam_answer_score_report.dart';
import '../../core/exam_answer/sqld_answer_grader.dart';
import '../../core/logging/app_logger.dart';
import '../models/exam_answer/exam_answer_enums.dart';
import '../models/exam_answer/exam_answer_round_response.dart';
import '../models/exam_answer/exam_answer_sheet_models.dart';
import '../sources/api_providers.dart';
import '../sources/exam_answer_api.dart';

/// 내 답안지: 답안 50자 + 채점 결과 (서버 결과 또는 오프라인 계산)
class ExamAnswerMySheet {
  const ExamAnswerMySheet({required this.answers, required this.report});

  final String answers;
  final ExamAnswerScoreReport report;
}

/// 가답안·가채점 저장소 (#1075): 공개 API + 기기 토큰·임시 답안
/// 채점은 서버 결과 우선, 서버에 닿지 못하면(네트워크·5xx) 가답안으로 기기에서 계산
class ExamAnswerRepository {
  ExamAnswerRepository(this._examAnswerApi, this._deviceStore);

  final ExamAnswerApiClient _examAnswerApi;
  final ExamAnswerDeviceStore _deviceStore;

  // 로그 접두사
  static const String _logTag = 'exam answer';

  Future<ExamAnswerRoundResponse> fetchRound(
    String certType,
    int roundNumber,
  ) async {
    try {
      return await _examAnswerApi.getRound(certType, roundNumber);
    } catch (exception) {
      throw exception.asAppException;
    }
  }

  /// 이 기기 답안지 (제출 전이면 null, 결과가 없으면 가답안으로 계산)
  Future<ExamAnswerMySheet?> fetchMySheet(
    ExamAnswerRoundResponse roundResponse,
  ) async {
    final round = roundResponse.round;
    final clientToken = await _deviceStore.readOrCreateClientToken();
    try {
      final sheet = await _examAnswerApi.getSheet(
        round.certType,
        round.roundNumber,
        clientToken,
      );
      final answers = sheet.answers;
      if (answers == null) return null;
      return ExamAnswerMySheet(
        answers: answers,
        report:
            sheet.grade?.toScoreReport() ??
            gradeLocally(answers, roundResponse.items),
      );
    } catch (exception) {
      final error = exception.asAppException;
      if (error.code == ErrorCode.notFound) return null;
      throw error;
    }
  }

  /// 답안 제출 > 채점 (서버에 닿지 못하면 기기 계산, 입력 오류 등 4xx 는 그대로 던짐)
  Future<ExamAnswerMySheet> submitSheet(
    ExamAnswerRoundResponse roundResponse,
    String answers,
  ) async {
    final round = roundResponse.round;
    final clientToken = await _deviceStore.readOrCreateClientToken();
    try {
      final sheet = await _examAnswerApi.submitSheet(
        round.certType,
        round.roundNumber,
        ExamAnswerSheetRequest(
          clientToken: clientToken,
          answers: answers,
          source: ExamAnswerSheetSource.app,
        ),
      );
      return ExamAnswerMySheet(
        answers: sheet.answers ?? answers,
        report:
            sheet.grade?.toScoreReport() ??
            gradeLocally(answers, roundResponse.items),
      );
    } catch (exception) {
      final error = exception.asAppException;
      if (!_isServerUnreachable(error)) throw error;
      AppLogger.warn(_logTag, 'submit fell back to local grading : $error');
      return ExamAnswerMySheet(
        answers: answers,
        report: gradeLocally(answers, roundResponse.items),
      );
    }
  }

  Future<String?> readDraftAnswers(String certType, int roundNumber) =>
      _deviceStore.readDraftAnswers(certType, roundNumber);

  Future<void> saveDraftAnswers(
    String certType,
    int roundNumber,
    String answers,
  ) => _deviceStore.saveDraftAnswers(certType, roundNumber, answers);

  /// 가답안 문항 > 채점 입력 > 오프라인 결과
  static ExamAnswerScoreReport gradeLocally(
    String answers,
    List<ExamAnswerItem> items,
  ) => SqldAnswerGrader.grade(answers, [
    for (final item in items)
      ExamAnswerKey(
        questionNo: item.questionNo,
        displayAnswer: item.answer,
        acceptedAnswers: {?item.answer, ...item.alternativeAnswers},
        isSettled: item.answerStatus.isSettled,
      ),
  ]);

  // 서버에 닿지 못함: 네트워크 끊김·시간 초과·5xx
  static bool _isServerUnreachable(AppException error) =>
      error.isNetwork || (error.statusCode ?? 0) >= 500;
}

/// 가채점 저장소 (기기 토큰 저장소는 앱 수명 동안 1개 > 토큰 캐시 공유)
final examAnswerRepositoryProvider = Provider<ExamAnswerRepository>(
  (ref) => ExamAnswerRepository(
    ref.watch(examAnswerApiProvider),
    ExamAnswerDeviceStore(),
  ),
);
