/**
 * 무료/프로 잠금 문구 단일 원본 (#578)
 * 앱 원본: pro_access_feedback.dart(사유·다시 열리는 때), locked_preview_samples.dart(잠금 자리 한 줄)
 * 웹은 판매하지 않음 > 버튼은 "앱에서 이용권으로 열기" + 앱 안내만
 */

// 잠금 자리 알약 버튼 (모든 잠금 자리 공통)
export const UNLOCK_IN_APP_LABEL = "앱에서 이용권으로 열기";

// 앱 안내 창: 제목, 본문 한 줄
export const APP_PASS_GUIDE_TITLE = "앱에서 이용권으로 열 수 있어요";
export const APP_PASS_GUIDE_DESCRIPTION =
  "passQL 앱에서 이용권(1개월·3개월)을 구매하면 웹에서도 같은 계정으로 열려요.";

// 잠금 자리별 가운데 한 줄 (앱 LockedPreviewCaptions 와 같은 문구)
export const LOCKED_PREVIEW_CAPTIONS = {
  explanation: "보기별 해설 · 함정 · 시험 팁",
  executionResult: "보기 SQL을 직접 실행해 결과 비교",
  stats: "토픽별 약점 · AI 학습 코멘트",
  examTrend: "최근 기출 토픽 비중 · 이번 회차 예상",
} as const;

// 사유 화면 3종 (앱 QuestionLoadErrorView 와 같은 문구)
export const FREE_DAILY_LIMIT_REASON = "오늘 무료 10문제를 다 풀었어요";
export const FREE_DAILY_LIMIT_RESET_NOTICE = "내일 0시에 10문제가 다시 열려요";
export const FAIR_USE_DAILY_LIMIT_REASON = "오늘 풀 수 있는 문제를 모두 풀었어요";
export const FAIR_USE_LIMIT_RESET_NOTICE = "내일 0시에 다시 풀 수 있어요";
export const PRO_REQUIRED_REASON = "이용권이 필요한 기능이에요";

// 등급 칩 글자
export const FREE_PLAN_CHIP_LABEL = "FREE";
export const PRO_PLAN_CHIP_LABEL = "PRO";
