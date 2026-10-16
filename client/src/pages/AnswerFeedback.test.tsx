// 채점 결과 화면 렌더 스모크 (#458 페이지 분리): 실행형·개념형 섹션 조합, state 없음 > 목록 이동
import { afterEach, describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";
import AnswerFeedback from "./AnswerFeedback";
import { renderPageForSmokeTest, stubApiResponses } from "../test/renderPageForSmokeTest";
import type { AnswerFeedbackState } from "../types/answerFeedback";
import type { ChoiceItem } from "../types/api";

const SQL_CHOICES: readonly ChoiceItem[] = [
  { key: "A", kind: "SQL", body: "SELECT 1;", isCorrect: false, rationale: "", sortOrder: 1 },
  { key: "B", kind: "SQL", body: "SELECT 2;", isCorrect: true, rationale: "", sortOrder: 2 },
];
const EXECUTABLE_WRONG_STATE: AnswerFeedbackState = {
  isCorrect: false,
  correctKey: "B",
  rationale: "해설 본문",
  selectedKey: "A",
  selectedSql: null,
  correctSql: null,
  questionUuid: "q1",
  executionMode: "EXECUTABLE",
  selectedResult: null,
  correctResult: null,
  choices: SQL_CHOICES,
  stem: "지문",
};

function renderAnswerFeedback(state: AnswerFeedbackState | null) {
  return renderPageForSmokeTest(<AnswerFeedback />, {
    routePath: "/questions/:questionUuid/result",
    initialPath: "/questions/q1/result",
    initialState: state,
  });
}

describe("AnswerFeedback", () => {
  afterEach(() => vi.unstubAllGlobals());

  it("실행형 오답: 헤더·문제 보기·해설·SQL 실행 비교·유사 문제를 그린다", async () => {
    stubApiResponses({ "/ai/similar/q1": [{ questionUuid: "s1", stem: "유사 지문", topicName: "JOIN", score: 0.9 }] });
    renderAnswerFeedback(EXECUTABLE_WRONG_STATE);
    expect(screen.getByText("틀렸어요")).toBeInTheDocument();
    expect(screen.getByText("문제 보기")).toBeInTheDocument();
    expect(screen.getByText("해설")).toBeInTheDocument();
    expect(screen.getByText("SQL 실행 비교")).toBeInTheDocument();
    expect(screen.getByText("내 선택")).toBeInTheDocument();
    expect(await screen.findByText("유사 지문")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "문제 목록으로" })).toBeInTheDocument();
  });

  it("개념형 정답: 선택지 답 카드를 그리고 SQL 비교는 숨긴다", () => {
    stubApiResponses({});
    renderAnswerFeedback({ ...EXECUTABLE_WRONG_STATE, isCorrect: true, selectedKey: "B", executionMode: "CONCEPT_ONLY", isDailyChallenge: true });
    expect(screen.getByText("맞혔어요!")).toBeInTheDocument();
    expect(screen.getByText("내가 선택한 답 · 정답")).toBeInTheDocument();
    expect(screen.queryByText("SQL 실행 비교")).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: "홈으로 가기" })).toBeInTheDocument();
  });

  it("진입 state 가 없으면 문제 목록으로 이동한다", async () => {
    stubApiResponses({});
    const { router } = renderAnswerFeedback(null);
    await waitFor(() => expect(router.state.location.pathname).toBe("/questions"));
  });
});
