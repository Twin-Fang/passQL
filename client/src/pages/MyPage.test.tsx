// 마이페이지 오답 노트: 프로 필요면 오류 대신 잠금 미리보기, 그 외 실패는 재시도 (#596)
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { screen } from "@testing-library/react";
import MyPage from "./MyPage";
import { apiErrorResponse, renderPageForSmokeTest, stubApiResponses } from "../test/renderPageForSmokeTest";
import { useAuthStore } from "../stores/authStore";

function renderMyPage() {
  return renderPageForSmokeTest(<MyPage />, { routePath: "/mypage", initialPath: "/mypage" });
}

describe("MyPage 오답 노트", () => {
  beforeEach(() => useAuthStore.setState({ accessToken: "test-access-token", memberUuid: "m1", nickname: "테스터" }));
  afterEach(() => vi.unstubAllGlobals());

  it("프로 필요면 재시도 대신 잠금 미리보기", async () => {
    stubApiResponses({ "/progress/wrong-questions": apiErrorResponse(403, { errorCode: "PRO_REQUIRED" }) });
    renderMyPage();
    expect(await screen.findByRole("region", { name: "틀린 문제 모아보기 · 다시 풀기" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "앱에서 이용권으로 열기" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "다시 시도하기" })).toBeNull();
  });

  it("그 외 실패는 기존 재시도 안내", async () => {
    stubApiResponses({ "/progress/wrong-questions": apiErrorResponse(500, { errorCode: "INTERNAL_SERVER_ERROR" }) });
    renderMyPage();
    expect(await screen.findByRole("button", { name: "다시 시도하기" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "앱에서 이용권으로 열기" })).toBeNull();
  });
});
