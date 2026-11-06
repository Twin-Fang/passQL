import { useCallback, useEffect, useRef, useState } from "react";
import { findCrossedAnnouncementMinute, toRemainingSecondsAt, toRemainingTimeSpeech } from "../lib/mockExamCountdown";

// 화면 갱신 주기 (250ms: 초 경계를 늦게 넘지 않게, 값이 바뀔 때만 다시 그림)
const COUNTDOWN_TICK_MILLISECONDS = 250;

interface CountdownSyncPoint {
  readonly serverRemainingSeconds: number;
  readonly syncedAtMonotonicMilliseconds: number;
}

/**
 * 모의고사 남은 시간: 서버 남은 초를 받은 순간부터 단조 시계(performance.now)로 줄임 (#866)
 * 시험지 재조회·답 저장 응답마다 syncRemainingSeconds 로 기준점 교체 > 기기 시각 변경 영향 없음
 * 30·10·5·1분 경계를 지날 때 낭독 문구 1회 (aria-live 영역용)
 */
export function useMockExamCountdown(initialSyncPoint: CountdownSyncPoint) {
  const syncPointRef = useRef<CountdownSyncPoint>(initialSyncPoint);
  const [remainingSeconds, setRemainingSeconds] = useState(initialSyncPoint.serverRemainingSeconds);
  const [announcement, setAnnouncement] = useState("");
  const previousSecondsRef = useRef(initialSyncPoint.serverRemainingSeconds);

  // 기준점 교체 (서버 값이 원본)
  const syncRemainingSeconds = useCallback((serverRemainingSeconds: number, syncedAtMonotonicMilliseconds: number) => {
    syncPointRef.current = { serverRemainingSeconds, syncedAtMonotonicMilliseconds };
  }, []);

  // 주기 계산 > 바뀐 초만 반영 > 경계 지나면 낭독
  useEffect(() => {
    const updateRemainingSeconds = () => {
      const syncPoint = syncPointRef.current;
      const nextSeconds = toRemainingSecondsAt(
        syncPoint.serverRemainingSeconds,
        syncPoint.syncedAtMonotonicMilliseconds,
        performance.now(),
      );
      const crossedMinute = findCrossedAnnouncementMinute(previousSecondsRef.current, nextSeconds);
      if (crossedMinute !== null) setAnnouncement(toRemainingTimeSpeech(crossedMinute * 60));
      previousSecondsRef.current = nextSeconds;
      setRemainingSeconds(nextSeconds);
    };
    updateRemainingSeconds();
    const timerId = window.setInterval(updateRemainingSeconds, COUNTDOWN_TICK_MILLISECONDS);
    return () => window.clearInterval(timerId);
  }, []);

  return { remainingSeconds, announcement, syncRemainingSeconds };
}
