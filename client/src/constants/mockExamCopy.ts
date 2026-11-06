import type { MockExamStartBlockReason } from "../types/api";

/**
 * SQLD 모의고사 화면 문구 단일 원본 (#866)
 * 숫자(문항 수·시간·합격선·과락 점수)는 문구에 넣지 않음 > 서버 examRule·결과 값으로 조립 (lib/mockExamPresentation)
 */

export const MOCK_EXAM_TITLE = "SQLD 모의고사";

// 진입 카드·행 설명 (홈, AI문제 탭)
export const MOCK_EXAM_ENTRY_DESCRIPTION = "실제 시험처럼 시간 안에 풀고 합격선을 확인해요";

// 시험 안내 고정 줄 (형식·합격 기준 줄은 examRule 로 조립)
export const MOCK_EXAM_GUIDE_FIXED_LINES = [
  "시간이 끝나면 자동으로 제출돼요",
  "나갔다 와도 이어 풀 수 있어요. 시간은 계속 흘러요",
  "풀이 중에는 정답·SQL 실행·해설이 없어요",
] as const;

// 무료 회원 안내 (결제 켜짐 + 무료일 때만)
export const MOCK_EXAM_FREE_TRIAL_NOTICE = "무료 체험은 1회예요. 과목별 분석·문항 해설은 이용권으로 열려요";

// 무료 체험 회차 배지
export const MOCK_EXAM_FREE_TRIAL_BADGE = "무료 체험";

// 시작할 수 없는 이유 > 회차 행·안내 화면 한 줄
export const MOCK_EXAM_START_BLOCK_REASON_LABELS: Readonly<Record<MockExamStartBlockReason, string>> = {
  PRO_REQUIRED: "이용권으로 열리는 회차예요",
  FREE_TRIAL_USED: "무료 체험을 이미 사용했어요",
  OTHER_ATTEMPT_IN_PROGRESS: "풀고 있는 시험을 먼저 마쳐 주세요",
};

// 시작 확인 창
export const MOCK_EXAM_START_CONFIRM = {
  title: "지금 시작할까요?",
  description: "중간에 나가도 시간은 계속 흘러요.",
  confirmLabel: "시작하기",
  cancelLabel: "다시 볼게요",
} as const;

// 나가기 확인 창
export const MOCK_EXAM_LEAVE_CONFIRM = {
  title: "시험을 잠시 나갈까요?",
  description: "시간은 계속 흘러요. 목록에서 이어 풀 수 있어요",
  confirmLabel: "나가기",
  cancelLabel: "계속 풀기",
} as const;

// 제출 확인 창 (안 푼·표시한 문항 수는 설명에 조립)
export const MOCK_EXAM_SUBMIT_CONFIRM = {
  title: "답안을 제출할까요?",
  confirmLabel: "제출하기",
  cancelLabel: "계속 풀기",
} as const;

// 저장 실패 표시 (다음 저장·제출 때 함께 보냄)
export const MOCK_EXAM_UNSAVED_LABEL = "저장 안 됨";

// 시간 끝 자동 제출 안내
export const MOCK_EXAM_TIME_UP_MESSAGE = "시간이 끝나 답안을 제출하고 있어요";

// 제출 실패 안내 (답은 문항마다 저장돼 있음 > 다시 시도)
export const MOCK_EXAM_SUBMIT_FAILED_MESSAGE = "제출하지 못했어요. 연결을 확인하고 다시 시도해 주세요";
