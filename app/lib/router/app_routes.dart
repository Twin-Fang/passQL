/// 앱 내 모든 라우트 경로 상수.
///
/// 문자열 경로를 직접 사용하는 대신 이 클래스를 참조한다 — 오타 방지.
/// 화면 코드의 경로 문자열 직접 사용은 test/architecture 규칙 테스트가 막는다.
abstract final class AppRoutes {
  // 경로·쿼리 파라미터 이름 (라우터 정의 <-> 화면 읽기 공통)
  static const String legalTypeParameter = 'type';
  static const String questionUuidParameter = 'questionUuid';
  static const String noticeUuidParameter = 'noticeUuid';
  static const String topicUuidParameter = 'topicUuid';
  static const String conceptUuidParameter = 'conceptUuid';
  // 커뮤니티 피드 시작 탭 (값은 CommunityFeedSource.serverValue)
  static const String communitySourceQuery = 'source';
  static const String topicCodeQuery = 'topic';
  static const String topicNameQuery = 'topicName';
  static const String conceptTitleQuery = 'title';
  // 최신 출제 경향 문제만 풀기 (값 'true', #523)
  static const String latestTrendQuery = 'latestTrend';
  static const String latestTrendQueryValue = 'true';
  // 문제 탭 보기 (값은 QuestionsTabView.queryValue)
  static const String questionsViewQuery = 'view';

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
  static const String concepts = '/concepts';
  static const String questions = '/questions';
  static const String stats = '/stats';
  static const String settings = '/settings';

  /// 문제 탭을 [viewQueryValue] 보기로 열기: /questions?view=VALUE
  static String questionsOf(String viewQueryValue) =>
      '$questions?$questionsViewQuery=$viewQueryValue';

  /// 하단 탭 순서(홈·개념·문제·토론·내 프로필). 탭 인덱스 <-> 경로 변환 기준
  /// 내 프로필 탭은 [stats] 경로, 설정은 톱니바퀴로 여는 푸시 화면(탭 아님)
  /// 개념 탭은 이용 가능할 때만 보이지만 브랜치 순서는 고정 (#577)
  static const List<String> tabRoots = [
    home,
    concepts,
    questions,
    community,
    stats,
  ];

  // 개념 학습 (#577)
  /// 라우터 정의용 단원 상세 경로 패턴: /concept-topics/:topicUuid
  static const String conceptTopicPattern =
      '/concept-topics/:$topicUuidParameter';

  /// 단원 상세(개념 목록). 개념 탭에서 진입
  static String conceptTopic(String topicUuid) => '/concept-topics/$topicUuid';

  /// 라우터 정의용 개념 학습 경로 패턴: /concept-study/:conceptUuid
  static const String conceptStudyPattern =
      '/concept-study/:$conceptUuidParameter';

  /// 개념 학습(읽기·풀기). 단원 상세·이어서 학습에서 진입
  static String conceptStudy(String conceptUuid) =>
      '/concept-study/$conceptUuid';

  /// 라우터 정의용 개념 관련 문제 경로 패턴: /concept-study/:conceptUuid/related?title=제목
  static const String conceptRelatedPattern =
      '/concept-study/:$conceptUuidParameter/related';

  /// 개념 관련 문제 풀이. 개념 풀기 결과에서 진입 (제목은 풀이 화면 앱바용)
  static String conceptRelated(String conceptUuid, String conceptTitle) => Uri(
    path: '/concept-study/$conceptUuid/related',
    queryParameters: {conceptTitleQuery: conceptTitle},
  ).toString();

  // 설정 서브 라우트
  /// 건의사항 작성/내역.
  static const String feedback = '/settings/feedback';

  static const String wrongNotes = '/settings/wrong-notes';

  /// 차단한 사용자 관리 (#525). 설정에서 진입
  static const String blockedMembers = '/settings/blocked-members';

  /// 알림함 (알림·공지 탭). 홈 종 아이콘에서 진입
  static const String notificationInbox = '/notifications';

  // 공지 (#529)
  /// 공지 목록 (지난 공지 포함). 공지 상세·알림함 공지 탭에서 진입
  static const String notices = '/notices';

  /// 라우터 정의용 공지 상세 경로 패턴: /notices/:noticeUuid
  static const String noticeDetailPattern = '$notices/:$noticeUuidParameter';

  /// 공지 상세. 홈 공지 배너·알림함 공지 항목·공지 목록에서 진입
  static String noticeDetail(String noticeUuid) => '$notices/$noticeUuid';

  // 커뮤니티 (#525)
  /// 커뮤니티 피드 (뜨는 토론·최신 경향·내가 푼 문제·내 의견). 토론 탭 루트. 홈 '오늘의 토론'은 go 로 탭 전환
  static const String community = '/community';

  /// 피드를 '내 의견' 칩으로 열기 (탭 안에서 go)
  static const String communityMine = '$community?$communitySourceQuery=mine';

  /// 라우터 정의용 문제별 의견 경로 패턴: /community/questions/:questionUuid
  static const String communityQuestionPattern =
      '$community/questions/:$questionUuidParameter';

  /// 문제별 의견 목록. [questionUuid]는 문제 UUID
  static String communityQuestion(String questionUuid) =>
      '$community/questions/$questionUuid';

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

  /// 랜덤 풀기 풀이 (전 범위 10문제, 홈·문제 탭에서 진입, #576)
  static const String randomPractice = '/random-practice';

  /// 옛 출제 경향 경로. 문제 탭 '최신 경향' 보기로 리다이렉트 (#523 > #574)
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
