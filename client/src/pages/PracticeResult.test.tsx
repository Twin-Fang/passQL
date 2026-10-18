// 연습 결과 렌더 스모크 (#458 페이지 분리): 점수 요약·AI 리포트·문제별 결과, 세션 불일치 > 목록 이동
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";
import PracticeResult from "./PracticeResult";
import { renderPageForSmokeTest, stubApiResponses } from "../test/renderPageForSmokeTest";
import { usePracticeStore } from "../stores/practiceStore";

function renderPracticeResult(sessionId: string) {
  return renderPageForSmokeTest(<PracticeResult />, {
    routePath: "/practice/:sessionId/result",
    initialPath: `/practice/${sessionId}/result`,
  });
}

describe("PracticeResult", () => {
  beforeEach(() => {
    usePracticeStore.getState().startSession("s1", "T", "SELECT 기본", [
      { questionUuid: "q1", topicCode: "T", topicName: "SELECT 기본", difficulty: 1, executionMode: "EXECUTABLE", stemPreview: "첫 문제 지문", createdAt: "", isLatestTrend: false },
    ]);
    usePracticeStore.setState({
      results: [{ questionUuid: "q1", isCorrect: true, selectedChoiceKey: "A", selectedChoiceBody: "SELECT 1;", durationMs: 42000 }],
    });
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    usePracticeStore.getState().reset();
  });

  it("점수 요약·AI 리포트를 그리고 AI 애니메이션 뒤 문제별 결과를 보여 준다", async () => {
    stubApiResponses({ "/progress/ai-comment": { comment: "잘했어요", generatedAt: "" } });
    renderPracticeResult("s1");
    expect(screen.getByText("SELECT 기본")).toBeInTheDocument();
    expect(screen.getByText("문제당 평균")).toBeInTheDocument();
    expect(screen.getByText("AI 리포트")).toBeInTheDocument();
    expect(await screen.findByText("문제별 결과", {}, { timeout: 4000 })).toBeInTheDocument();
    expect(screen.getAllByText("첫 문제 지문").length).toBeGreaterThan(0);
    expect(screen.getByText("내 답: SELECT 1;")).toBeInTheDocument();
  });

  it("주소의 세션이 저장된 세션과 다르면 문제 목록으로 이동한다", async () => {
    stubApiResponses({});
    const { router } = renderPracticeResult("other-session");
    await waitFor(() => expect(router.state.location.pathname).toBe("/questions"));
  });
});
