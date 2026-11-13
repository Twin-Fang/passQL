/**
 * 무료/프로 잠금 문구 단일 원본 (#578)
 * 앱 원본: pro_access_feedback.dart(사유·다시 열리는 때), locked_preview_samples.dart(잠금 자리 한 줄)
 * 웹은 판매하지 않음 > 버튼은 "앱에서 PRO로 보기" + 앱 안내만
 */

// 잠금 자리 알약 버튼 (모든 잠금 자리 공통)
export const UNLOCK_IN_APP_LABEL = "앱에서 PRO로 보기";

// 앱 안내 창: 제목, 본문 한 줄
export const APP_PASS_GUIDE_TITLE = "앱에서 이용권으로 열 수 있어요";
export const APP_PASS_GUIDE_DESCRIPTION =
  "passQL 앱에서 이용권(1개월·3개월)을 구매하면 웹에서도 같은 계정으로 열려요.";

// 잠금 자리별 가운데 한 줄 (앱 LockedPreviewCaptions 와 같은 문구)
export const LOCKED_PREVIEW_CAPTIONS = {
  explanation: "보기마다 왜 맞고 틀린지 알려 드려요",
  executionResult: "보기 SQL을 직접 실행해 결과를 비교해요",
  stats: "토픽별 약점과 정답률 차트를 봐요",
  examTrend: "최근 기출 비중과 이번 회차 예상을 봐요",
  wrongNotes: "틀린 문제를 모아 보고 다시 풀어요",
  aiAnalysis: "AI가 약점을 짚고 다음 공부를 추천해요",
  // 모의고사 (#866): 결과 과목·토픽 분석, 문항 해설, 점수 추이
  mockExamSubjectDetail: "과목별 점수와 과락, 토픽별 정답률을 봐요",
  mockExamReview: "문항별 해설과 보기별 근거, 다음에 할 일을 봐요",
  mockExamScoreTrend: "회차별 점수 변화를 합격선과 비교해요",
  // 프로필 난이도별 정답률·오답 정리 (#909)
  accuracyDetail: "어느 난이도에서 틀리는지, 오답이 줄고 있는지 봐요",
  // 보기 방식 (#913): AI 새 보기
  freshChoices: "풀 때마다 AI가 새 보기를 만들어요",
} as const;

// 사유 화면 3종 (앱 QuestionLoadErrorView 와 같은 문구)
export const FREE_DAILY_LIMIT_REASON = "오늘 크레딧을 다 썼어요";
export const FREE_DAILY_LIMIT_RESET_NOTICE = "내일 0시에 다시 열려요";
export const FAIR_USE_DAILY_LIMIT_REASON = "오늘 풀 수 있는 문제를 모두 풀었어요";
export const FAIR_USE_LIMIT_RESET_NOTICE = "내일 0시에 다시 풀 수 있어요";
export const PRO_REQUIRED_REASON = "이용권이 필요한 기능이에요";

// 등급 칩 글자
export const FREE_PLAN_CHIP_LABEL = "FREE";
export const PRO_PLAN_CHIP_LABEL = "PRO";
