import { create } from "zustand";
import type { ChoiceExplanation, ChoiceItem, SubmitResult } from "../types/api";
import { buildDisplayLabelByChoiceKey, type DisplayLabelByChoiceKey } from "../lib/choiceExplanationPresentation";

/** 해설함 항목 1건: 제출 1회 (choiceSetUuid + 고른 보기) */
export interface ExplanationHistoryEntry {
  // 같은 세트·보기 재제출이면 같은 항목
  readonly id: string;
  readonly questionUuid: string;
  readonly choiceSetUuid: string;
  readonly selectedChoiceKey: string;
  // 패널 제목·목록 표시용 (예: "3번 문제")
  readonly questionLabel: string;
  readonly displayLabelByChoiceKey: DisplayLabelByChoiceKey;
  readonly isCorrect: boolean;
  // 제출 응답의 구조화 해설 (있으면 조회 없이 즉시 표시)
  readonly initialExplanation: ChoiceExplanation | null;
  // 제출 응답의 잠긴 묶음 (무료면 FULL_EXPLANATION, #578)
  readonly initialLockedSections: readonly string[];
  // 구조화 해설 실패 시 마크다운 폴백 (제출 응답 explanation 또는 rationale)
  readonly fallbackText: string | null;
}

// 패널 본문: 한 문제 해설 / 해설함 목록
export type ExplanationPanelView = "detail" | "history";

// 해설함 최대 보관 수 (오래된 것부터 버림)
export const MAXIMUM_EXPLANATION_HISTORY_COUNT = 20;

interface ExplanationHistoryState {
  readonly entries: readonly ExplanationHistoryEntry[];
  readonly activeEntryId: string | null;
  readonly isOpen: boolean;
  // 좁은 화면 하단 시트 펼침 여부 (넓은 화면 사이드 패널은 항상 펼침)
  readonly isExpanded: boolean;
  readonly view: ExplanationPanelView;
}

interface ExplanationHistoryActions {
  readonly addEntry: (entry: ExplanationHistoryEntry) => void;
  readonly openEntry: (entryId: string) => void;
  readonly openHistory: () => void;
  readonly toggleExpanded: () => void;
  readonly close: () => void;
  readonly reset: () => void;
}

const INITIAL_STATE: ExplanationHistoryState = {
  entries: [],
  activeEntryId: null,
  isOpen: false,
  isExpanded: false,
  view: "detail",
};

/** 제출 1회 > 해설함 항목 id */
export function toExplanationEntryId(choiceSetUuid: string, selectedChoiceKey: string): string {
  return `${choiceSetUuid}:${selectedChoiceKey}`;
}

interface ExplanationEntrySource {
  readonly questionUuid: string;
  readonly choiceSetUuid: string;
  readonly selectedChoiceKey: string;
  // 1부터 시작하는 문제 번호 (없으면 "이 문제")
  readonly questionNumber?: number;
  // 화면 순서 보기 목록 (표시 라벨 계산)
  readonly choices: readonly ChoiceItem[];
  readonly result: SubmitResult;
}

/** 제출 성공 1건 > 해설함 항목 */
export function buildExplanationHistoryEntry({
  questionUuid,
  choiceSetUuid,
  selectedChoiceKey,
  questionNumber,
  choices,
  result,
}: ExplanationEntrySource): ExplanationHistoryEntry {
  return {
    id: toExplanationEntryId(choiceSetUuid, selectedChoiceKey),
    questionUuid,
    choiceSetUuid,
    selectedChoiceKey,
    questionLabel: questionNumber ? `${questionNumber}번 문제` : "이 문제",
    displayLabelByChoiceKey: buildDisplayLabelByChoiceKey(choices),
    isCorrect: result.isCorrect,
    initialExplanation: result.structuredExplanation ?? null,
    initialLockedSections: result.lockedSections ?? [],
    fallbackText: result.explanation || result.rationale || null,
  };
}

/**
 * 해설함 (풀이 세션 범위): 최근 해설 목록, 패널 열림·펼침·보기 상태
 * 페이지를 떠나면 ExplanationPanel 이 reset (세션 밖으로 남기지 않음)
 */
export const useExplanationHistoryStore = create<ExplanationHistoryState & ExplanationHistoryActions>()((set) => ({
  ...INITIAL_STATE,

  // 최근 순 앞에 추가 (같은 id 는 교체), 상한 초과분 버림
  addEntry: (entry) =>
    set((state) => ({
      entries: [entry, ...state.entries.filter((existing) => existing.id !== entry.id)].slice(
        0,
        MAXIMUM_EXPLANATION_HISTORY_COUNT,
      ),
    })),

  openEntry: (entryId) => set({ activeEntryId: entryId, isOpen: true, isExpanded: true, view: "detail" }),

  openHistory: () => set({ isOpen: true, isExpanded: true, view: "history" }),

  toggleExpanded: () => set((state) => ({ isExpanded: !state.isExpanded })),

  close: () => set({ isOpen: false }),

  reset: () => set(INITIAL_STATE),
}));
