// 문제 풀이 화면 렌더 스모크 (#458 페이지 분리): 지문·선택지·제출 버튼, 선택지 생성 실패 안내
import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen } from "@testing-library/react";
import QuestionDetail from "./QuestionDetail";
import { apiErrorResponse, renderPageForSmokeTest, stubApiResponses } from "../test/renderPageForSmokeTest";
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
  isLatestTrend: true,
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
    // 최신 경향 문제 배지 (#523)
    expect(screen.getByText("최신 경향")).toBeInTheDocument();
    const submitButton = screen.getByRole("button", { name: "답안 제출하기" });
    expect(submitButton).toBeDisabled();
    fireEvent.click(screen.getByText("첫 번째 보기"));
    expect(submitButton).toBeEnabled();
  });

  it("최신 경향이 아닌 문제는 배지를 그리지 않는다", async () => {
    stubApiResponses({ "/questions/q2": { ...QUESTION, questionUuid: "q2", isLatestTrend: false } });
    renderQuestionDetail("q2");
    expect(await screen.findByText("두 번째 보기")).toBeInTheDocument();
    expect(screen.queryByText("최신 경향")).not.toBeInTheDocument();
  });

  it("선택지 세트가 없고 생성도 실패하면 실패 안내를 보여 준다", async () => {
    stubApiResponses({ "/questions/q3": { ...QUESTION, questionUuid: "q3", choiceSets: [] } });
    renderQuestionDetail("q3");
    expect(await screen.findByText("선택지 생성에 실패했어요")).toBeInTheDocument();
  });

  it("무료 하루 한도면 일반 오류 대신 사유 화면 + 앱 안내 버튼, 제출 바 없음 (#578)", async () => {
    stubApiResponses({ "/questions/q4": apiErrorResponse(403, { errorCode: "FREE_DAILY_LIMIT_REACHED" }) });
    renderQuestionDetail("q4");
    expect(await screen.findByText("오늘 무료 10문제를 다 풀었어요")).toBeInTheDocument();
    expect(screen.getByText("내일 0시에 10문제가 다시 열려요")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "앱에서 이용권으로 열기" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "답안 제출하기" })).toBeNull();
  });
});
