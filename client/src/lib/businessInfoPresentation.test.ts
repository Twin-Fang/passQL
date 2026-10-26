// 사업자 정보 표시 줄: 상호 없으면 숨김, 빈 값 줄 제외 (#658)
import { describe, expect, it } from "vitest";
import { toBusinessInfoLines } from "./businessInfoPresentation";

const FULL_BUSINESS_INFO = {
  companyName: "콜리랩(KOLLYLAB)",
  representativeName: "서새찬",
  registrationNumber: "331-37-01670",
  contactEmail: "chan4760@naver.com",
  mailOrderSalesNumber: null,
};

describe("toBusinessInfoLines", () => {
  it("빈 값 줄(통신판매업 신고번호)은 빼고 순서대로", () => {
    expect(toBusinessInfoLines(FULL_BUSINESS_INFO)).toEqual([
      { label: "상호", value: "콜리랩(KOLLYLAB)" },
      { label: "대표자", value: "서새찬" },
      { label: "사업자등록번호", value: "331-37-01670" },
      { label: "문의", value: "chan4760@naver.com" },
    ]);
  });

  it("신고번호가 들어오면 표시", () => {
    const lines = toBusinessInfoLines({ ...FULL_BUSINESS_INFO, mailOrderSalesNumber: "2026-서울-0000" });
    expect(lines.map((line) => line.label)).toContain("통신판매업 신고번호");
  });

  it("상호가 없거나 구버전 서버 응답이면 빈 목록", () => {
    expect(toBusinessInfoLines({ ...FULL_BUSINESS_INFO, companyName: null })).toEqual([]);
    expect(toBusinessInfoLines(undefined)).toEqual([]);
  });
});
