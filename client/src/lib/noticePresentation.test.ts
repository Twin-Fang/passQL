// 공지 표시 규칙: 게시일 yyyy.MM.dd, 미리보기 마크다운 표기 제거, 상세 경로 (#529)
import { describe, expect, it } from "vitest";
import { formatNoticeDate, toNoticeDetailPath, toNoticePreview } from "./noticePresentation";

describe("noticePresentation", () => {
  it("게시일 > yyyy.MM.dd (잘못된 값은 빈 문자열)", () => {
    expect(formatNoticeDate("2026-03-05T09:00:00")).toBe("2026.03.05");
    expect(formatNoticeDate("잘못된 값")).toBe("");
  });

  it("미리보기는 굵게·코드·목록·링크 표기를 지우고 한 줄로", () => {
    const body = "**점검 안내**\n\n- 일시: `10월 20일`\n- 자세히: [공지 링크](https://passql.example/notice)";
    expect(toNoticePreview(body)).toBe("점검 안내 일시: 10월 20일 자세히: 공지 링크");
  });

  it("상세 경로는 uuid 를 인코딩", () => {
    expect(toNoticeDetailPath("abc-123")).toBe("/notices/abc-123");
  });
});
