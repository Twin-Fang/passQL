// 설정: 약관 열람·사업자 정보 표시 (#658), Play 비공개면 "출시 준비 중" 비활성 (#531)
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen } from "@testing-library/react";
import Settings from "./Settings";
import { renderPageForSmokeTest, stubApiResponses } from "../test/renderPageForSmokeTest";
import { useAuthStore } from "../stores/authStore";

vi.mock("../lib/firebase", () => ({ firebaseAuth: {}, googleProvider: {}, appleProvider: {} }));

const BUSINESS_INFO = {
  companyName: "콜리랩(KOLLYLAB)",
  representativeName: "서새찬",
  registrationNumber: "331-37-01670",
  contactEmail: "chan4760@naver.com",
  mailOrderSalesNumber: null,
};

function renderSettings() {
  return renderPageForSmokeTest(<Settings />, { routePath: "/settings", initialPath: "/settings" });
}

describe("Settings 약관·사업자 정보", () => {
  beforeEach(() => useAuthStore.setState({ accessToken: "test-access-token", memberUuid: "m1", nickname: "테스터" }));
  afterEach(() => vi.unstubAllGlobals());

  it("약관 2종 행과 사업자 정보 표시, 신고번호 빈 값 줄 숨김", async () => {
    stubApiResponses({ "/meta/app-config": { businessInfo: BUSINESS_INFO } });
    renderSettings();

    expect(screen.getByRole("button", { name: /이용약관/ })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /개인정보처리방침/ })).toBeInTheDocument();
    expect(await screen.findByText("331-37-01670")).toBeInTheDocument();
    expect(screen.getByText("콜리랩(KOLLYLAB)")).toBeInTheDocument();
    expect(screen.queryByText("통신판매업 신고번호")).toBeNull();
  });

  it("이용약관 행을 누르면 서버 약관 본문 모달", async () => {
    HTMLDialogElement.prototype.showModal ??= function showModal(this: HTMLDialogElement) { this.open = true; };
    stubApiResponses({
      "/meta/legal/TERMS_OF_SERVICE": { type: "TERMS_OF_SERVICE", title: "passQL 이용약관", content: "제1조 목적", status: "PUBLISHED" },
    });
    renderSettings();

    fireEvent.click(screen.getByRole("button", { name: /이용약관/ }));

    expect(await screen.findByText("passQL 이용약관")).toBeInTheDocument();
    expect(await screen.findByText(/제1조 목적/)).toBeInTheDocument();
  });

  it("Play 비공개(IS_GOOGLE_PLAY_PUBLIC=false)면 링크 대신 출시 준비 중", async () => {
    stubApiResponses({ "/meta/app-links": { androidUrl: "https://play.google.com/store/apps/details?id=x", iosUrl: null } });
    renderSettings();

    expect(await screen.findByText("출시 준비 중")).toBeInTheDocument();
    expect(screen.queryByText("Google Play")).toBeNull();
    expect(screen.queryByRole("button", { name: /Android 앱 받기/ })).toBeNull();
  });
});
