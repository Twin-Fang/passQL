import { useState, useCallback, useRef, useMemo } from "react";
import { executeChoice } from "../api/questions";
import { toUserErrorMessage } from "../lib/userErrorMessage";
import type { AnswerFeedbackState } from "../types/answerFeedback";
import type { ChoiceItem, ExecuteResult } from "../types/api";

/**
 * 채점 결과 SQL 비교 상태: 아코디언 열림, 선택지별 실행·결과 캐시·에러, 모두 실행
 * 결과 캐시 초기값 = 제출 응답(selectedResult/correctResult)
 */
export function useAnswerFeedbackExecution(state: AnswerFeedbackState | null) {
  // 아코디언 열림 상태 — 내 선택/정답 카드는 기본 펼침
  const [openKeys, setOpenKeys] = useState<Set<string>>(() => {
    if (!state) return new Set();
    const defaultOpen = new Set<string>();
    if (state.selectedKey) defaultOpen.add(state.selectedKey);
    if (state.correctKey) defaultOpen.add(state.correctKey);
    return defaultOpen;
  });

  // 실행 중인 선택지 키 Set — 병렬 실행 시 각 카드의 로딩 상태를 독립적으로 관리
  const executingKeyRef = useRef<Set<string>>(new Set());
  // 캐시 guard 조회용 ref — resultCache state와 동기화
  const resultCacheRef = useRef<Record<string, ExecuteResult>>({});

  // 선택지 SQL 실행 결과 캐시 — 제출 응답(selectedResult/correctResult)으로 초기화
  const [resultCache, setResultCache] = useState<Record<string, ExecuteResult>>(() => {
    if (!state) return {};
    const cache: Record<string, ExecuteResult> = {};
    if (state.selectedResult && state.selectedKey) {
      cache[state.selectedKey] = state.selectedResult;
      resultCacheRef.current[state.selectedKey] = state.selectedResult;
    }
    if (state.correctResult && state.correctKey) {
      cache[state.correctKey] = state.correctResult;
      resultCacheRef.current[state.correctKey] = state.correctResult;
    }
    return cache;
  });
  const [executingKeys, setExecutingKeys] = useState<Set<string>>(new Set());
  const [executionErrorByKey, setExecutionErrorByKey] = useState<Record<string, string>>({});

  const toggleOpen = useCallback((key: string) => {
    setOpenKeys((prev) => {
      const next = new Set(prev);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      return next;
    });
  }, []);

  const executeChoiceSql = useCallback(async (choice: ChoiceItem) => {
    if (!state || resultCacheRef.current[choice.key] || executingKeyRef.current.has(choice.key)) return;
    setExecutionErrorByKey((prev) => { const next = { ...prev }; delete next[choice.key]; return next; });
    executingKeyRef.current.add(choice.key);
    setExecutingKeys((prev) => new Set([...prev, choice.key]));
    try {
      const result = await executeChoice(state.questionUuid, choice.body);
      resultCacheRef.current = { ...resultCacheRef.current, [choice.key]: result };
      setResultCache((prev) => ({ ...prev, [choice.key]: result }));
    } catch (err) {
      const message = toUserErrorMessage(err, "실행에 실패했습니다");
      setExecutionErrorByKey((prev) => ({ ...prev, [choice.key]: message }));
    } finally {
      executingKeyRef.current.delete(choice.key);
      setExecutingKeys((prev) => { const next = new Set(prev); next.delete(choice.key); return next; });
    }
  }, [state]);

  const isExecutable = state?.executionMode === "EXECUTABLE";
  const choices = state?.choices;
  const correctKey = state?.correctKey;
  const selectedKey = state?.selectedKey;

  // 정답 → 내 선택 → 나머지 순 정렬 — choices/키가 바뀔 때만 재계산
  const sqlChoices = useMemo(() => {
    if (!isExecutable) return [];
    return (choices ?? [])
      .filter((c) => c.kind === "SQL")
      .slice()
      .sort((a, b) => {
        const rank = (key: string) =>
          key === correctKey ? 0 : key === selectedKey ? 1 : 2;
        return rank(a.key) - rank(b.key);
      });
  }, [isExecutable, choices, correctKey, selectedKey]);

  // 미실행 선택지 전체 병렬 실행 — 이미 실행 중이거나 캐시된 항목은 guard로 자동 스킵
  const executeAllChoices = useCallback(async () => {
    const unexecuted = sqlChoices.filter(
      (c) => !resultCacheRef.current[c.key] && !executingKeyRef.current.has(c.key)
    );
    await Promise.allSettled(unexecuted.map((c) => executeChoiceSql(c)));
  }, [sqlChoices, executeChoiceSql]);

  return {
    sqlChoices,
    openKeys,
    resultCache,
    executingKeys,
    executionErrorByKey,
    toggleOpen,
    executeChoiceSql,
    executeAllChoices,
  };
}
