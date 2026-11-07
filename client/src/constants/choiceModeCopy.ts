import type { ChoiceGenerationMode } from "../types/api";

/**
 * 보기 방식 화면 문구 단일 원본 (#913, 앱 choice_generation_mode_display.dart·choice_mode_sheet.dart 와 같은 문구)
 * "실전"은 모의고사 이름이라 쓰지 않음 (DEC-0261). 설정 화면·풀이 칩·보기 방식 시트 공용
 */

// 켜고 끄는 기능 이름 (켜면 REAL)
export const FRESH_CHOICES_TITLE = "새 보기로 풀기";

// 풀이 화면 보기 방식 시트 제목
export const CHOICE_MODE_SHEET_TITLE = "보기 방식";

// 모드별 짧은 이름 (풀이 칩·스크린리더)
export const CHOICE_MODE_SHORT_NAME: Readonly<Record<ChoiceGenerationMode, string>> = {
  PRACTICE: "검증된 보기",
  REAL: "AI 새 보기",
};

// 모드별 한 줄 설명 (스위치 아래)
export const CHOICE_MODE_DESCRIPTION: Readonly<Record<ChoiceGenerationMode, string>> = {
  PRACTICE: "검증된 보기를 먼저 써요",
  REAL: "풀 때마다 AI가 새 보기를 만들어요",
};

// 바꾼 방식이 언제부터인지 (제출 전: 지금 문제 보기 교체, 제출 뒤: 채점한 보기 유지)
export const APPLIES_TO_CURRENT_QUESTION_NOTICE = "바꾸면 지금 문제부터 바로 적용돼요";
export const APPLIES_FROM_NEXT_SOLVE_NOTICE = "제출한 문제라 다음 풀이부터 적용돼요";

// 저장 실패 기본 문구 (서버 4xx 문구가 없을 때)
export const CHOICE_MODE_SAVE_FAILED_MESSAGE = "보기 방식을 바꾸지 못했어요. 잠시 후 다시 시도해 주세요.";
