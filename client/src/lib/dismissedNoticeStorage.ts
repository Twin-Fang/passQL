// localStorage: 닫은 공지 noticeUuid 목록 (JSON 배열, 이 브라우저에만 기록)
const DISMISSED_NOTICE_UUIDS_KEY = "passql_dismissed_notice_uuids";

/** 닫은 공지 noticeUuid 목록 읽기 (저장소 차단·손상 값이면 빈 목록) */
export function readDismissedNoticeUuids(): ReadonlySet<string> {
  try {
    const storedValue = localStorage.getItem(DISMISSED_NOTICE_UUIDS_KEY);
    const parsedValue: unknown = storedValue ? JSON.parse(storedValue) : [];
    return Array.isArray(parsedValue)
      ? new Set(parsedValue.filter((uuid): uuid is string => typeof uuid === "string"))
      : new Set();
  } catch {
    return new Set();
  }
}

/** 공지 닫음 기록 > 갱신된 목록 반환 (저장 실패해도 이번 화면에서는 닫힘) */
export function saveDismissedNoticeUuid(noticeUuid: string): ReadonlySet<string> {
  const dismissedNoticeUuids = new Set(readDismissedNoticeUuids()).add(noticeUuid);
  try {
    localStorage.setItem(DISMISSED_NOTICE_UUIDS_KEY, JSON.stringify([...dismissedNoticeUuids]));
  } catch {
    // 시크릿 모드 등 저장 차단 > 기록 생략
  }
  return dismissedNoticeUuids;
}
