// 공지 화면 경로 (목록·상세, #529)
export const NOTICE_LIST_PATH = "/notices";

/** 공지 상세 경로: /notices/{noticeUuid} */
export function toNoticeDetailPath(noticeUuid: string): string {
  return `${NOTICE_LIST_PATH}/${encodeURIComponent(noticeUuid)}`;
}

/** 게시 시각(ISO, KST) > "2026.10.18" (잘못된 값 > 빈 문자열) */
export function formatNoticeDate(isoString: string): string {
  const publishedAt = new Date(isoString);
  if (Number.isNaN(publishedAt.getTime())) return "";
  const month = String(publishedAt.getMonth() + 1).padStart(2, "0");
  const day = String(publishedAt.getDate()).padStart(2, "0");
  return `${publishedAt.getFullYear()}.${month}.${day}`;
}

// 목록 미리보기에서 지우는 마크다운 표기 (굵게·코드, 줄머리 목록 기호)
const INLINE_MARKER_PATTERN = /\*\*|`/g;
const LIST_MARKER_PATTERN = /^\s*(?:[-*]|\d+\.)\s+/;
// 링크 [이름](주소) > 이름
const LINK_PATTERN = /\[([^\]]+)\]\([^)\s]+\)/g;

/** 본문 마크다운 > 목록 미리보기 한 줄 (표기 제거, 줄바꿈은 공백) */
export function toNoticePreview(body: string): string {
  return body
    .split(/\r?\n/)
    .map((line) => line.replace(LIST_MARKER_PATTERN, "").replace(LINK_PATTERN, "$1").replace(INLINE_MARKER_PATTERN, "").trim())
    .filter((line) => line.length > 0)
    .join(" ");
}
