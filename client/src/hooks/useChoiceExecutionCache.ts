import { useState, useCallback, useRef, useEffect } from "react";
import { useExecuteChoice } from "./useQuestionDetail";
import type { ExecuteResult } from "../types/api";

/**
 * 풀이 화면 선택지 SQL 실행: 선택지별 결과 캐시 + 병렬 실행 상태, 중복 실행 방지
 */
export function useChoiceExecutionCache(questionUuid: string) {
  const executeMutation = useExecuteChoice(questionUuid);
  const [executeCache, setExecuteCache] = useState<
    Record<string, ExecuteResult>
  >({});
  const executeCacheRef = useRef(executeCache);
  executeCacheRef.current = executeCache;
  // 선택지별 독립 실행 상태 — Set으로 병렬 실행 추적 (단일 mutation 상태에 의존하지 않음)
  const [executingKeys, setExecutingKeys] = useState<Set<string>>(new Set());
  const executingKeysRef = useRef(executingKeys);
  executingKeysRef.current = executingKeys;

  // 문제 교체 시 실행 중 상태 초기화 — practiceMode에서 리마운트 없이 questionUuid만 바뀌는 케이스 대응
  useEffect(() => {
    setExecutingKeys(new Set());
  }, [questionUuid]);

  const executeChoiceSql = useCallback(
    async (choiceKey: string, sql: string) => {
      // 이미 캐시된 결과나 실행 중이면 중복 호출 방지
      if (executeCacheRef.current[choiceKey]) return;
      if (executingKeysRef.current.has(choiceKey)) return;

      setExecutingKeys((prev) => new Set([...prev, choiceKey]));
      try {
        // mutateAsync: 각 호출이 독립된 Promise를 반환해 병렬 실행 시 콜백 덮어씌우기 방지
        const result = await executeMutation.mutateAsync(sql);
        setExecuteCache((prev) => ({ ...prev, [choiceKey]: result }));
      } catch {
        // 에러 표시는 ChoiceCard 내부에서 처리
      } finally {
        setExecutingKeys((prev) => {
          const next = new Set(prev);
          next.delete(choiceKey);
          return next;
        });
      }
    },
    // executingKeys는 ref로 읽으므로 의존성 불필요
    [executeMutation],
  );

  return { executeCache, executingKeys, executeChoiceSql };
}
