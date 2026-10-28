import 'execute_result.dart';

/// 내 답 <-> 정답 실행 결과 비교: 한 줄 요약 + 한쪽에만 있는 행 위치 (#727)
/// 행 비교는 순서 무시 다중집합 (같은 행이 2번이면 2번 모두 짝이 있어야 같음)
class ExecuteResultComparison {
  const ExecuteResultComparison({
    required this.summary,
    this.myOnlyRowIndexes = const {},
    this.correctOnlyRowIndexes = const {},
  });

  /// 비교 > 무엇이 다른지 한 줄
  factory ExecuteResultComparison.of({
    required ExecuteResult myResult,
    required ExecuteResult correctResult,
  }) {
    // 오류 > 열 > 행 수 > 행 값 > 순서 순으로 먼저 걸리는 차이 하나만 요약
    if (_hasError(myResult)) {
      return ExecuteResultComparison(
        summary: '내 답은 실행 오류(${myResult.errorCode})가 나요',
      );
    }
    if (_hasError(correctResult)) {
      return const ExecuteResultComparison(summary: '정답 SQL 을 실행하지 못했어요');
    }
    if (!_isSameColumns(myResult.columns, correctResult.columns)) {
      return const ExecuteResultComparison(summary: '조회한 열이 정답과 달라요');
    }
    final myRowKeys = [for (final row in myResult.rows) _toRowKey(row)];
    final correctRowKeys = [
      for (final row in correctResult.rows) _toRowKey(row),
    ];
    final myOnlyRowIndexes = _findUnmatchedRowIndexes(
      myRowKeys,
      correctRowKeys,
    );
    final correctOnlyRowIndexes = _findUnmatchedRowIndexes(
      correctRowKeys,
      myRowKeys,
    );
    final String summary;
    if (myRowKeys.length != correctRowKeys.length) {
      summary = '내 답은 ${myRowKeys.length}행, 정답은 ${correctRowKeys.length}행이에요';
    } else if (myOnlyRowIndexes.isNotEmpty) {
      summary = '${myRowKeys.length}행 중 ${myOnlyRowIndexes.length}행의 값이 달라요';
    } else if (!_isSameOrder(myRowKeys, correctRowKeys)) {
      summary = '행은 같고 순서가 달라요';
    } else {
      summary = '실행 결과는 같아요';
    }
    return ExecuteResultComparison(
      summary: summary,
      myOnlyRowIndexes: myOnlyRowIndexes,
      correctOnlyRowIndexes: correctOnlyRowIndexes,
    );
  }

  final String summary;

  /// 내 결과에만 있는 행 위치 (정답에 짝이 없음)
  final Set<int> myOnlyRowIndexes;

  /// 정답 결과에만 있는 행 위치 (내 결과에 없음)
  final Set<int> correctOnlyRowIndexes;

  static bool _hasError(ExecuteResult result) =>
      result.errorCode?.isNotEmpty == true;

  /// 열 이름 비교 (대소문자 무시, 순서 포함)
  static bool _isSameColumns(List<String> mine, List<String> correct) {
    if (mine.length != correct.length) return false;
    for (var i = 0; i < mine.length; i++) {
      if (mine[i].toLowerCase() != correct[i].toLowerCase()) return false;
    }
    return true;
  }

  /// 행 > 비교 키 (NULL 과 문자열 'null' 구분)
  static String _toRowKey(List<dynamic> row) =>
      row.map((cell) => cell == null ? '\u0000' : '$cell').join('\u0001');

  /// [source] 중 [target] 에 짝이 없는 행 위치 (짝은 한 번씩만 씀)
  static Set<int> _findUnmatchedRowIndexes(
    List<String> source,
    List<String> target,
  ) {
    final remainingCountByKey = <String, int>{};
    for (final key in target) {
      remainingCountByKey[key] = (remainingCountByKey[key] ?? 0) + 1;
    }
    final unmatchedRowIndexes = <int>{};
    for (final (index, key) in source.indexed) {
      final remainingCount = remainingCountByKey[key] ?? 0;
      if (remainingCount > 0) {
        remainingCountByKey[key] = remainingCount - 1;
      } else {
        unmatchedRowIndexes.add(index);
      }
    }
    return unmatchedRowIndexes;
  }

  static bool _isSameOrder(List<String> mine, List<String> correct) {
    for (var i = 0; i < mine.length; i++) {
      if (mine[i] != correct[i]) return false;
    }
    return true;
  }
}
