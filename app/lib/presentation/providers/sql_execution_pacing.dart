/// SQL 실행 중 표시 최소 시간 (#727)
/// 서버·앱 캐시로 결과가 즉시 와도 실행 중 표시가 깜빡이지 않고 "실행했다"는 느낌이 남도록
const Duration minimumSqlExecutionDisplayDuration = Duration(milliseconds: 450);

/// 작업 결과를 최소 표시 시간 뒤에 돌려줌 (작업이 더 오래 걸리면 그대로, 실패도 같은 시점에 전달)
Future<T> runWithMinimumExecutionDisplay<T>(Future<T> Function() task) async {
  final minimumDisplay = Future<void>.delayed(
    minimumSqlExecutionDisplayDuration,
  );
  try {
    return await task();
  } finally {
    await minimumDisplay;
  }
}
