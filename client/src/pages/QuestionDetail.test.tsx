// 문제 풀이 화면 렌더 스모크 (#458 페이지 분리): 지문·선택지·제출 버튼, 선택지 생성 실패 안내
import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen } from "@testing-library/react";
import QuestionDetail from "./QuestionDetail";
import { renderPageForSmokeTest, stubApiResponses } from "../test/renderPageForSmokeTest";
import type { QuestionDetail as QuestionDetailResponse } from "../types/api";

const QUESTION: QuestionDetailResponse = {
  questionUuid: "q1",
  topicName: "SELECT 기본",
  subtopicName: "조회",
  difficulty: 2,
  executionMode: "CONCEPT_ONLY",
  choiceSetPolicy: "AI_ONLY",
  stem: "회원 지문",
  schemaDisplay: "",
  schemaDdl: "",
  schemaSampleData: "",
  schemaIntent: "",
  schemaTables: [],
  answerSql: "",
  hint: "",
  choiceSets: [
    {
      choiceSetUuid: "cs1",
      source: "AI_RUNTIME",
      status: "OK",
      sandboxValidationPassed: true,
      createdAt: "",
      items: [
        { key: "A", kind: "TEXT", body: "첫 번째 보기", isCorrect: false, rationale: "", sortOrder: 1 },
        { key: "B", kind: "TEXT", body: "두 번째 보기", isCorrect: true, rationale: "", sortOrder: 2 },
      ],
    },
  ],
};

function renderQuestionDetail(questionUuid: string) {
  return renderPageForSmokeTest(<QuestionDetail />, {
    routePath: "/questions/:questionUuid",
    initialPath: `/questions/${questionUuid}`,
  });
}

describe("QuestionDetail", () => {
  afterEach(() => vi.unstubAllGlobals());

  it("지문·선택지를 그리고 선택 전에는 제출 버튼을 막는다", async () => {
    stubApiResponses({ "/questions/q1": QUESTION });
    renderQuestionDetail("q1");
    expect(await screen.findByText("두 번째 보기")).toBeInTheDocument();
    expect(screen.getByText("회원 지문")).toBeInTheDocument();
    expect(screen.getByText("SELECT 기본")).toBeInTheDocument();
    const submitButton = screen.getByRole("button", { name: "답안 제출하기" });
    expect(submitButton).toBeDisabled();
    fireEvent.click(screen.getByText("첫 번째 보기"));
    expect(submitButton).toBeEnabled();
  });

  it("선택지 세트가 없고 생성도 실패하면 실패 안내를 보여 준다", async () => {
    stubApiResponses({ "/questions/q3": { ...QUESTION, questionUuid: "q3", choiceSets: [] } });
    renderQuestionDetail("q3");
    expect(await screen.findByText("선택지 생성에 실패했어요")).toBeInTheDocument();
  });
});
