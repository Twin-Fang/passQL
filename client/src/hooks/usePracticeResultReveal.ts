import { useState, useCallback, useRef, useEffect } from "react";
import type { PracticeQuestionResult } from "../types/api";

// 통계 3칸 순차 등장 간격 (ms)
const STAT_REVEAL_INTERVAL_MILLISECONDS = 150;
// 문제 카드 순차 등장: 섹션 등장 후 첫 카드 지연, 카드 간격 (ms)
const FIRST_CARD_DELAY_MILLISECONDS = 100;
const CARD_REVEAL_INTERVAL_MILLISECONDS = 80;

/** MarkdownText animated 단어 수 기반 총 애니메이션 시간 계산 */
function calculateAiCommentAnimationMilliseconds(text: string): number {
  const wordCount = text.split(/\s+/).filter(Boolean).length;
  // startDelay 200ms + 단어 간격 55ms + 마지막 fade 300ms + 여유 300ms
  return 200 + (wordCount - 1) * 55 + 300 + 300;
}

/**
 * 연습 결과 순차 등장: 점수 카운트 완료 > 통계 3칸, AI 코멘트 애니메이션 완료(실패 시 즉시) > 문제 목록·카드
 */
export function usePracticeResultReveal(aiComment: string | null | false, results: readonly PracticeQuestionResult[]) {
  const [visibleStats, setVisibleStats] = useState<boolean[]>([
    false,
    false,
    false,
  ]);
  // 문제 카드 순차 등장 상태 — 인덱스별 visible 여부
  const [visibleCards, setVisibleCards] = useState<boolean[]>([]);
  // 문제 리스트 섹션 자체 등장 여부
  const [isResultListVisible, setIsResultListVisible] = useState(false);

  // 타이머를 역할별로 분리 — scoreComplete 타이머와 AI/카드 타이머가 서로 취소하지 않도록
  const scoreTimerIdsRef = useRef<ReturnType<typeof setTimeout>[]>([]);
  const cardTimerIdsRef = useRef<ReturnType<typeof setTimeout>[]>([]);

  // 언마운트 시 대기 타이머 정리 (점수·카드 공통)
  useEffect(() => {
    return () => {
      scoreTimerIdsRef.current.forEach(clearTimeout);
      cardTimerIdsRef.current.forEach(clearTimeout);
    };
  }, []);

  // AI 애니메이션 완료 or 실패 시 문제 카드 순차 등장
  useEffect(() => {
    // 로딩 중이면 대기
    if (aiComment === null) return;
    cardTimerIdsRef.current.forEach(clearTimeout);
    cardTimerIdsRef.current = [];

    // AI 실패 시 즉시 등장, 성공 시 애니메이션 완료 후 등장
    const animDuration =
      typeof aiComment === "string" && aiComment
        ? calculateAiCommentAnimationMilliseconds(aiComment)
        : 0;
    const cardCount = results.length;

    // 문제 리스트 섹션 먼저 등장
    const sectionId = setTimeout(() => {
      setIsResultListVisible(true);
      setVisibleCards(new Array(cardCount).fill(false));
    }, animDuration);
    cardTimerIdsRef.current.push(sectionId);

    // 카드 80ms 간격 순차 등장
    results.forEach((_, i) => {
      const id = setTimeout(
        () => {
          setVisibleCards((prev) => {
            const next = [...prev];
            next[i] = true;
            return next;
          });
        },
        animDuration + FIRST_CARD_DELAY_MILLISECONDS + i * CARD_REVEAL_INTERVAL_MILLISECONDS,
      );
      cardTimerIdsRef.current.push(id);
    });
  }, [aiComment, results]);

  // 점수 카운트업 완료 시 통계 3칸 150ms 간격 등장
  const revealStatsSequentially = useCallback(() => {
    scoreTimerIdsRef.current.forEach(clearTimeout);
    scoreTimerIdsRef.current = [];
    [0, 1, 2].forEach((i) => {
      const id = setTimeout(() => {
        setVisibleStats((prev) => {
          const next = [...prev];
          next[i] = true;
          return next;
        });
      }, i * STAT_REVEAL_INTERVAL_MILLISECONDS);
      scoreTimerIdsRef.current.push(id);
    });
  }, []);

  return { visibleStats, visibleCards, isResultListVisible, revealStatsSequentially };
}
