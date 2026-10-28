import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/question/execute_request.dart';
import '../../data/models/question/execute_result.dart';
import '../../data/sources/api_providers.dart';
import 'plan_providers.dart';
import 'sql_execution_pacing.dart';

/// 실습 칸 시작 SQL 3종: 정답, 내 답(오답일 때만), 빈 칸
enum SqlPracticeStart { correctAnswer, myAnswer, blank }

/// 채점 뒤 직접 실행해보기 칸 상태: 고치는 SQL, 시작 SQL, 실행 결과·실패·잠금 (#727)
class SqlPracticeState {
  const SqlPracticeState({
    this.draftSql,
    this.start = SqlPracticeStart.correctAnswer,
    this.executeResult,
    this.executeFailure,
    this.isExecuting = false,
    this.isExecutionLocked = false,
  });

  /// 사용자가 고친 SQL (null 이면 아직 손대지 않음 > 시작 SQL 그대로)
  final String? draftSql;
  final SqlPracticeStart start;
  final ExecuteResult? executeResult;

  /// 실행 요청 자체 실패 (네트워크·5xx·SANDBOX_TIMEOUT 등)
  final AppException? executeFailure;
  final bool isExecuting;

  /// 무료(결제 켜짐)라 실행하지 않음 > 결과 자리 블러
  final bool isExecutionLocked;

  SqlPracticeState copyWith({
    String? draftSql,
    bool clearDraftSql = false,
    SqlPracticeStart? start,
    ExecuteResult? executeResult,
    bool clearExecuteResult = false,
    AppException? executeFailure,
    bool clearExecuteFailure = false,
    bool? isExecuting,
    bool? isExecutionLocked,
  }) {
    return SqlPracticeState(
      draftSql: clearDraftSql ? null : (draftSql ?? this.draftSql),
      start: start ?? this.start,
      executeResult: clearExecuteResult
          ? null
          : (executeResult ?? this.executeResult),
      executeFailure: clearExecuteFailure
          ? null
          : (executeFailure ?? this.executeFailure),
      isExecuting: isExecuting ?? this.isExecuting,
      isExecutionLocked: isExecutionLocked ?? this.isExecutionLocked,
    );
  }
}

/// 실습 칸: 시작 SQL 고르기 > 고치기 > 실행 (questionUuid별, 화면 이탈 시 해제)
class SqlPracticeNotifier
    extends AutoDisposeFamilyNotifier<SqlPracticeState, String> {
  /// 이 문제에서 실행한 SQL > 결과 (같은 SQL 재실행은 요청 없이 재사용)
  final Map<String, ExecuteResult> _executeResultBySql = {};

  @override
  SqlPracticeState build(String questionUuid) => const SqlPracticeState();

  /// 시작 SQL 바꾸기 > 고친 내용·이전 결과 비움
  void changeStart(SqlPracticeStart start) {
    if (start == state.start) return;
    state = SqlPracticeState(start: start);
  }

  void updateDraft(String sql) {
    state = state.copyWith(draftSql: sql);
  }

  /// 실행: 빈 SQL 무시 > 무료(결제 켜짐)면 잠금 > 앱 캐시 > POST /execute(서버도 결과 캐시) > 결과 또는 실패 사유
  /// 캐시로 즉시 끝나도 실행 중 표시는 최소 시간 유지
  Future<void> run(String sql) async {
    if (sql.trim().isEmpty || state.isExecuting) return;
    final isExecutionLocked = ref.read(shouldShowProUiProvider);
    state = state.copyWith(
      clearExecuteResult: true,
      clearExecuteFailure: true,
      isExecutionLocked: isExecutionLocked,
      isExecuting: !isExecutionLocked,
    );
    if (isExecutionLocked) return;
    try {
      final executeResult = await runWithMinimumExecutionDisplay(
        () async =>
            _executeResultBySql[sql] ??
            await ref
                .read(questionApiProvider)
                .executeChoice(arg, ExecuteRequest(sql: sql)),
      );
      _executeResultBySql[sql] = executeResult;
      state = state.copyWith(executeResult: executeResult, isExecuting: false);
    } catch (exception) {
      // 인증 만료는 인터셉터가 세션 만료 신호로 처리
      state = state.copyWith(
        isExecuting: false,
        executeFailure: exception.asAppException,
      );
    }
  }
}

/// questionUuid별 실습 칸 Provider
final sqlPracticeProvider = NotifierProvider.autoDispose
    .family<SqlPracticeNotifier, SqlPracticeState, String>(
      SqlPracticeNotifier.new,
    );
