// 알림 표시 규칙: 이동 라우트, 배지 문구, 탭 제목, 상대 시간 (#491)
import { describe, expect, it } from "vitest";
import {
  formatNotificationTime,
  resolveNotificationRoute,
  toDocumentTitle,
  toUnreadBadgeLabel,
} from "./notificationPresentation";
import type { NotificationItem } from "../types/api";

function buildNotification(overrides: Partial<NotificationItem>): NotificationItem {
  return {
    id: "n1", category: "GENERAL", type: "ADMIN_MESSAGE", title: "제목", body: "본문",
    linkTarget: null, linkQuestionUuid: null, isRead: false, createdAt: "2026-10-16T09:00:00", isImportant: false,
    ...overrides,
  };
}

describe("resolveNotificationRoute", () => {
  it("허용 목록 값 > 웹 라우트", () => {
    expect(resolveNotificationRoute(buildNotification({ linkTarget: "HOME" }))).toBe("/");
    expect(resolveNotificationRoute(buildNotification({ linkTarget: "DAILY_SET" }))).toBe("/daily-set");
    expect(resolveNotificationRoute(buildNotification({ linkTarget: "QUESTIONS" }))).toBe("/questions");
    expect(resolveNotificationRoute(buildNotification({ linkTarget: "STATS" }))).toBe("/stats");
  });

  it("문제 상세는 questionUuid 필요, 없거나 이동 대상 없으면 null", () => {
    expect(resolveNotificationRoute(buildNotification({ linkTarget: "QUESTION_DETAIL", linkQuestionUuid: "q-1" }))).toBe("/questions/q-1");
    expect(resolveNotificationRoute(buildNotification({ linkTarget: "QUESTION_DETAIL" }))).toBeNull();
    expect(resolveNotificationRoute(buildNotification({ linkTarget: null }))).toBeNull();
  });

  it("공지는 이동 없음", () => {
    expect(resolveNotificationRoute(buildNotification({ category: "NOTICE", linkTarget: "HOME" }))).toBeNull();
  });
});

describe("toUnreadBadgeLabel / toDocumentTitle", () => {
  it("0 이하 숨김, 9 이하 숫자, 10 이상 9+", () => {
    expect(toUnreadBadgeLabel(0)).toBeNull();
    expect(toUnreadBadgeLabel(9)).toBe("9");
    expect(toUnreadBadgeLabel(10)).toBe("9+");
  });

  it("탭 제목에 개수 반영", () => {
    expect(toDocumentTitle(0)).toBe("passQL");
    expect(toDocumentTitle(3)).toBe("(3) passQL");
    expect(toDocumentTitle(120)).toBe("(99+) passQL");
  });
});

describe("formatNotificationTime", () => {
  const now = new Date("2026-10-16T12:00:00").getTime();
  it("상대 시간 구간", () => {
    expect(formatNotificationTime("2026-10-16T11:59:30", now)).toBe("방금");
    expect(formatNotificationTime("2026-10-16T11:30:00", now)).toBe("30분 전");
    expect(formatNotificationTime("2026-10-16T09:00:00", now)).toBe("3시간 전");
    expect(formatNotificationTime("2026-10-14T12:00:00", now)).toBe("2일 전");
    expect(formatNotificationTime("2026-09-01T12:00:00", now)).toBe("9월 1일");
  });
});
