/// 앱 내 모든 라우트 경로 상수.
///
/// 문자열 경로를 직접 사용하는 대신 이 클래스를 참조한다 — 오타 방지.
/// 화면 코드의 경로 문자열 직접 사용은 test/architecture 규칙 테스트가 막는다.
abstract final class AppRoutes {
  // 경로·쿼리 파라미터 이름 (라우터 정의 <-> 화면 읽기 공통)
  static const String legalTypeParameter = 'type';
  static const String questionUuidParameter = 'questionUuid';
  static const String topicCodeQuery = 'topic';
  static const String topicNameQuery = 'topicName';
  // 최신 출제 경향 문제만 풀기 (값 'true', #523)
  static const String latestTrendQuery = 'latestTrend';
  static const String latestTrendQueryValue = 'true';

  // 인증
  static const String login = '/login';

  /// 약관 경로 접두사. 로그인 전에도 접근할 수 있어 redirect 예외 판정에 쓴다.
  static const String legalPrefix = '/legal/';

  /// 라우터 정의용 약관 경로 패턴: /legal/:type
  static const String legalPattern = '$legalPrefix:$legalTypeParameter';

  /// 약관 열람. [type] 은 LegalType.serverValue. 로그인 전에도 접근할 수 있다.
  static String legal(String type) => '$legalPrefix$type';

  // 앱 시작 차단 화면 (점검·강제 업데이트, 로그인 여부와 무관)
  static const String forceUpdate = '/force-update';
  static const String maintenance = '/maintenance';

  // 탭 루트
  static const String home = '/home';
  static const String questions = '/questions';
  static const String stats = '/stats';
  static const String settings = '/settings';

  /// 하단 탭 순서(홈·문제·통계·설정). 탭 인덱스 <-> 경로 변환 기준
  static const List<String> tabRoots = [home, questions, stats, settings];

  // 설정 서브 라우트
  /// 건의사항 작성/내역.
  static const String feedback = '/settings/feedback';

  static const String wrongNotes = '/settings/wrong-notes';

  /// 알림함 (알림·공지 탭). 홈 종 아이콘에서 진입
  static const String notificationInbox = '/notifications';

  // 데일리 세트
  /// 오늘의 세트 풀이.
  static const String dailySet = '/daily-set';

  /// 오늘의 세트 결과.
  static const String dailySetResult = '/daily-set/result';

  /// 리더보드.
  static const String leaderboard = '/leaderboard';

  // 문제 탭 서브 라우트
  /// 토픽 선택 후 챕터 플로우. topic(topicCode), topicName 쿼리 파라미터.
  static const String questionChapter = '/questions/chapter';

  /// 챕터 플로우 진입: /questions/chapter?topic=CODE&topicName=NAME(&latestTrend=true)
  static String questionChapterOf({
    required String topicCode,
    required String topicName,
    bool isLatestTrendOnly = false,
  }) =>
      '$questionChapter?$topicCodeQuery=$topicCode'
      '&$topicNameQuery=${Uri.encodeComponent(topicName)}'
      '${isLatestTrendOnly ? '&$latestTrendQuery=$latestTrendQueryValue' : ''}';

  /// 출제 경향 화면 (홈 진입 카드에서, #523)
  static const String examTrend = '/exam-trend';

  // 풀스크린
  /// 라우터 정의용 문제 상세 경로 패턴: /questions/:questionUuid
  static const String questionDetailPattern =
      '$questions/:$questionUuidParameter';

  /// 문제 상세. [uuid]는 questionUuid.
  static String questionDetail(String uuid) => '$questions/$uuid';

  /// 상세 화면 아래 결과 하위 경로
  static const String resultSubPath = 'result';

  /// 결과 화면. [uuid]는 questionUuid.
  static String questionResult(String uuid) =>
      '${questionDetail(uuid)}/$resultSubPath';

  /// 챕터 결과. 챕터 화면을 대신해 열려 뒤로 가면 챕터 진입 전 화면(문제 목록)으로 돌아간다.
  static const String chapterResult = '/chapter-result';
}
