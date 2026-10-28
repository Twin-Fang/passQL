// 스토어 스크린샷 가짜 API의 등급 응답 (#576): --dart-define=SHOT_PLAN=off|free|pro
// off 결제 꺼짐 | free 무료·결제 켜짐 | pro 프로·결제 켜짐 (없으면 off, 기존 촬영과 같은 화면)
// 운영 코드(lib/)에는 영향이 없다.

const String _shotPlan = String.fromEnvironment(
  'SHOT_PLAN',
  defaultValue: 'off',
);
const bool _isBillingEnabled = _shotPlan != 'off';
const bool _isFreeLocked = _shotPlan == 'free';
const bool _isPro = _shotPlan == 'pro';

/// 앱 시작 설정의 결제 스위치 값 (/meta/app-config isAndroidBillingEnabled)
const bool isShotBillingEnabled = _isBillingEnabled;

// 무료 응답에서 빼는 묶음 (제출·해설 공통)
const List<String> _lockedSections = _isFreeLocked
    ? ['EXECUTION_RESULT', 'FULL_EXPLANATION']
    : <String>[];

/// 무료일 때 403 PRO_REQUIRED 로 막는 경로 (앱은 잠금이면 요청하지 않아야 함)
bool isProRequiredShotPath(String path) =>
    _isFreeLocked &&
    (path.endsWith('/execute') ||
        path.contains('/ai/similar/') ||
        path.endsWith('/progress/topic-analysis') ||
        path.endsWith('/progress/ai-comment') ||
        path.endsWith('/progress/wrong-questions') ||
        path.endsWith('/questions/recommendations') ||
        path.contains('/exam-trends/latest'));

/// GET /members/me/plan 가짜 응답 (시각은 KST)
Map<String, dynamic> memberPlanShotResponse() => {
  'isBillingEnabled': _isBillingEnabled,
  'plan': _isPro ? 'PRO' : 'FREE',
  'todayRandomSolvedCount': _isFreeLocked ? 3 : 0,
  'dailyFreeLimit': 10,
  // deprecated (옛 앱 호환): 3개월권 예상 만료일과 같은 값
  'purchasableUntil': _isPro ? '2027-02-12T23:59:59' : '2027-01-21T14:32:00',
  // 이용권 2종 (3개월 먼저), 만료일 = 지금 사면 될 날짜 (프로는 현재 만료일에 이어 붙임)
  'passOptions': [
    {
      'productId': 'pro_pass_3m',
      'durationDays': 90,
      'expiresAtIfPurchased': _isPro
          ? '2027-02-12T23:59:59'
          : '2027-01-21T14:32:00',
    },
    {
      'productId': 'pro_pass_1m',
      'durationDays': 30,
      'expiresAtIfPurchased': _isPro
          ? '2026-12-14T23:59:59'
          : '2026-11-22T14:32:00',
    },
  ],
  'proExpiresAt': _isPro ? '2026-11-14T23:59:59' : null,
  'lastPurchasedAt': _isPro ? '2026-10-20T14:32:00' : null,
  'lastOrderId': _isPro ? 'GPA.3312-5521-0937-41522' : null,
};

/// POST /ai/choice-explanation 가짜 응답: 오답 B, 무료면 판정만 + FULL_EXPLANATION 잠금
Map<String, dynamic> choiceExplanationShotResponse() => {
  'choiceSetUuid': '33333333-0000-4000-8000-000000000001',
  'selectedChoiceKey': 'B',
  'status': 'READY',
  'explanation': {
    'selectedChoiceKey': 'B',
    'correctChoiceKey': 'A',
    'isSelectedCorrect': false,
    'verdict': '고른 B 는 오답, 정답은 A',
    if (!_isFreeLocked) ...{
      'correctReason': '`WHERE` 는 그룹으로 묶기 전에 행마다 조건을 비교해요.',
      'keyConcepts': [
        {'name': 'WHERE', 'description': '행 단위 조건, 집계 전에 적용'},
        {'name': 'HAVING', 'description': '그룹 단위 조건, GROUP BY 뒤에 적용'},
      ],
      'confusingPoints': ['`HAVING` 만 쓰면 전체를 한 그룹으로 보고 비교해요.'],
      'choiceAnalyses': [
        {'choiceKey': 'A', 'isCorrect': true, 'reason': '행마다 급여를 비교해요.'},
        {
          'choiceKey': 'B',
          'isCorrect': false,
          'reason': 'GROUP BY 없는 HAVING 은 행 조건이 아니에요.',
        },
      ],
      'examTip': '행 조건은 WHERE, 그룹 조건은 HAVING.',
    },
  },
  'lockedSections': _isFreeLocked ? ['FULL_EXPLANATION'] : <String>[],
};

/// POST /questions/{uuid}/submit 가짜 응답: 오답 B, 무료면 실행 결과 없음 + 잠금 표시
Map<String, dynamic> submitShotResponse({required String correctSql}) => {
  'isCorrect': false,
  'correctKey': 'A',
  'rationale': 'WHERE 절로 행을 먼저 걸러요.',
  'selectedSql': 'SELECT ENAME FROM EMP HAVING SAL >= 3000;',
  'correctSql': correctSql,
  'submissionUuid': '77777777-0000-4000-8000-000000000001',
  // 오답 B(HAVING 만 단독)는 PostgreSQL 에서 실행 오류 > 내 답 vs 정답 비교 연출 (#727)
  if (!_isFreeLocked)
    'selectedResult': {
      'status': 'ERROR',
      'columns': <String>[],
      'rows': <List<Object>>[],
      'errorCode': '42803',
      'errorMessage': 'column "emp.sal" must appear in the GROUP BY clause or be used in an aggregate function',
    },
  if (!_isFreeLocked)
    'correctResult': {
      'status': 'SUCCESS',
      'columns': ['ENAME'],
      'rows': [
        ['KING'],
        ['SCOTT'],
        ['FORD'],
      ],
      'rowCount': 3,
      'elapsedMs': 12,
    },
  'lockedSections': _lockedSections,
};
