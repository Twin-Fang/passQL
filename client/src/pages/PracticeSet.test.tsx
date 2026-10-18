// 연습 세트 풀이 렌더 스모크 (#458 페이지 분리): 진행 바·문제, 나가기 확인 모달, 세션 불일치 > 목록 이동
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";
import PracticeSet from "./PracticeSet";
import { renderPageForSmokeTest, stubApiResponses } from "../test/renderPageForSmokeTest";
import { usePracticeStore } from "../stores/practiceStore";

function renderPracticeSet(sessionId: string) {
  return renderPageForSmokeTest(<PracticeSet />, {
    routePath: "/practice/:sessionId",
    initialPath: `/practice/${sessionId}`,
  });
}

describe("PracticeSet", () => {
  beforeEach(() => {
    usePracticeStore.getState().startSession("s1", "T", "SELECT 기본", [
      { questionUuid: "q1", topicCode: "T", topicName: "SELECT 기본", difficulty: 1, executionMode: "CONCEPT_ONLY", stemPreview: "", createdAt: "", isLatestTrend: false },
      { questionUuid: "q2", topicCode: "T", topicName: "SELECT 기본", difficulty: 1, executionMode: "CONCEPT_ONLY", stemPreview: "", createdAt: "", isLatestTrend: false },
    ]);
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    usePracticeStore.getState().reset();
  });

  it("진행 번호·토픽·문제를 그리고 나가기 버튼으로 확인 모달을 연다", async () => {
    stubApiResponses({
      "/questions/q1": {
        questionUuid: "q1", topicName: "SELECT 기본", subtopicName: "", difficulty: 1, executionMode: "CONCEPT_ONLY",
        choiceSetPolicy: "AI_ONLY", stem: "첫 문제 지문", schemaDisplay: "", schemaDdl: "", schemaSampleData: "",
        schemaIntent: "", schemaTables: [], answerSql: "", hint: "",
        choiceSets: [{ choiceSetUuid: "cs1", source: "AI_RUNTIME", status: "OK", sandboxValidationPassed: true, createdAt: "",
          items: [{ key: "A", kind: "TEXT", body: "보기 A", isCorrect: true, rationale: "", sortOrder: 1 }] }],
      },
    });
    renderPracticeSet("s1");
    expect(screen.getByText("1 / 2")).toBeInTheDocument();
    expect(screen.getByText("SELECT 기본")).toBeInTheDocument();
    expect(await screen.findByText("첫 문제 지문")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "확인" })).toBeDisabled();
    fireEvent.click(screen.getByRole("button", { name: "풀이 나가기" }));
    expect(screen.getByText("풀이를 그만할까요?")).toBeInTheDocument();
  });

  it("주소의 세션이 저장된 세션과 다르면 문제 목록으로 이동한다", async () => {
    stubApiResponses({});
    const { router } = renderPracticeSet("other-session");
    await waitFor(() => expect(router.state.location.pathname).toBe("/questions"));
  });
});
