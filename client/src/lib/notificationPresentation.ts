import type { NotificationItem, NotificationLinkTarget } from "../types/api";

// 알림 이동 대상 > 웹 라우트 (웹에 없는 화면은 매핑하지 않음 > 읽음만 처리)
const ROUTE_BY_LINK_TARGET: Readonly<Partial<Record<NotificationLinkTarget, string>>> = {
  HOME: "/",
  DAILY_SET: "/daily-set",
  QUESTIONS: "/questions",
  STATS: "/stats",
};

/** 알림 > 이동할 웹 라우트 (이동 없으면 null) */
export function resolveNotificationRoute(notification: NotificationItem): string | null {
  if (notification.category === "NOTICE" || notification.linkTarget === null) return null;
  if (notification.linkTarget === "QUESTION_DETAIL") {
    return notification.linkQuestionUuid ? `/questions/${notification.linkQuestionUuid}` : null;
  }
  return ROUTE_BY_LINK_TARGET[notification.linkTarget] ?? null;
}

// 배지 숫자 상한 (10 이상 9+)
const BADGE_MAX_DISPLAY_COUNT = 9;

/** 안 읽은 개수 > 배지 문구 (0 이하는 null) */
export function toUnreadBadgeLabel(unreadCount: number): string | null {
  if (unreadCount <= 0) return null;
  return unreadCount > BADGE_MAX_DISPLAY_COUNT ? `${BADGE_MAX_DISPLAY_COUNT}+` : String(unreadCount);
}

const APP_TITLE = "passQL · SQLD·SQLP 문제 풀이";

/** 안 읽은 개수 > 브라우저 탭 제목 ("(3) passQL") */
export function toDocumentTitle(unreadCount: number): string {
  if (unreadCount <= 0) return APP_TITLE;
  return `(${unreadCount > 99 ? "99+" : unreadCount}) ${APP_TITLE}`;
}

/** ISO 8601 > 상대 시간 (방금 / N분 전 / N시간 전 / N일 전 / 날짜) */
export function formatNotificationTime(isoString: string, nowMilliseconds: number = Date.now()): string {
  const createdAt = new Date(isoString);
  if (Number.isNaN(createdAt.getTime())) return "";
  const elapsedMinutes = Math.floor((nowMilliseconds - createdAt.getTime()) / 60_000);
  if (elapsedMinutes < 1) return "방금";
  if (elapsedMinutes < 60) return `${elapsedMinutes}분 전`;
  const elapsedHours = Math.floor(elapsedMinutes / 60);
  if (elapsedHours < 24) return `${elapsedHours}시간 전`;
  const elapsedDays = Math.floor(elapsedHours / 24);
  if (elapsedDays < 7) return `${elapsedDays}일 전`;
  return `${createdAt.getMonth() + 1}월 ${createdAt.getDate()}일`;
}

/** 알림 두 건 중 최신순 비교 (createdAt 내림차순) */
export function compareByNewest(left: NotificationItem, right: NotificationItem): number {
  return new Date(right.createdAt).getTime() - new Date(left.createdAt).getTime();
}
