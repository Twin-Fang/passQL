// 출제 경향 화면 (#523): 섹션 표시, 최신 경향 문제 있는 항목만 풀기 버튼, 풀기 > 연습 세션, 실패 안내
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";
import ExamTrend from "./ExamTrend";
import { apiErrorResponse, renderPageForSmokeTest, stubApiResponses } from "../test/renderPageForSmokeTest";
import { useAuthStore } from "../stores/authStore";
import type { ExamTrendReportResponse } from "../types/api";

const REPORT: ExamTrendReportResponse = {
  title: "2026 SQLD 출제 경향",
  basisDescription: "제58~62회 시험 유형 분석",
  updatedDate: "2026-10-18",
  summary: "결과 추적형이 늘었어요.",
  latestTrendQuestionCount: 3,
  subjectShares: [
    { subjectName: "1과목", questionCount: 10, percent: 20, description: "상황형 증가" },
    { subjectName: "2과목", questionCount: 40, percent: 80, description: "추적형 대부분" },
  ],
  risingPatterns: [
    {
      title: "결과 비교형 보기",
      description: "행 수가 가장 많은 것 고르기",
      examRoundsText: "58회부터 증가",
      topicCode: "sql_join",
      topicName: "조인",
      latestTrendQuestionCount: 3,
    },
  ],
  frequentConcepts: [
    {
      rank: 1,
      name: "윈도우 함수",
      description: "순위 함수 3종",
      frequencyText: "10문항",
      topicCode: "sql_window",
      topicName: null,
      latestTrendQuestionCount: 0,
    },
  ],
  studyTips: ["결과 표를 직접 그려 보세요."],
  latestTrendTopics: [{ topicCode: "sql_join", topicName: "조인", latestTrendQuestionCount: 3 }],
};

function renderExamTrend() {
  return renderPageForSmokeTest(<ExamTrend />, { routePath: "/exam-trend", initialPath: "/exam-trend" });
}

describe("ExamTrend", () => {
  beforeEach(() => useAuthStore.setState({ accessToken: "test-access-token", memberUuid: "m1", nickname: "테스터" }));
  afterEach(() => vi.unstubAllGlobals());

  it("요약·과목 비중·늘어난 유형·자주 나오는 개념·공부 팁을 그린다", async () => {
    stubApiResponses({ "/exam-trends/latest": REPORT });
    renderExamTrend();
    expect(await screen.findByText("2026 SQLD 출제 경향")).toBeInTheDocument();
    expect(screen.queryByText("최신 경향 문제 3개를 풀 수 있어요")).not.toBeInTheDocument();
    expect(screen.getByText("20%")).toBeInTheDocument();
    expect(screen.getByText("결과 비교형 보기")).toBeInTheDocument();
    expect(screen.getByText("1. 윈도우 함수")).toBeInTheDocument();
    expect(screen.getByText("결과 표를 직접 그려 보세요.")).toBeInTheDocument();
  });

  it("최신 경향 문제가 있는 항목만 풀기 버튼을 보여 주고 누르면 연습 세션으로 간다", async () => {
    stubApiResponses({
      "/exam-trends/latest": REPORT,
      "/questions": {
        content: [{ questionUuid: "q1", topicCode: "sql_join", topicName: "조인", difficulty: 2, executionMode: "CONCEPT_ONLY", stemPreview: "", createdAt: "", isLatestTrend: true }],
        totalPages: 1, totalElements: 1, number: 0, size: 10, first: true, last: true, empty: false,
      },
    });
    const { router } = renderExamTrend();
    const solveButton = await screen.findByRole("button", { name: /조인 최신 경향 문제 3개 풀기/ });
    expect(screen.queryByRole("button", { name: /윈도우 함수/ })).not.toBeInTheDocument();
    fireEvent.click(solveButton);
    await waitFor(() => expect(router.state.location.pathname).toMatch(/^\/practice\//));
    const requestedUrl = String(vi.mocked(fetch).mock.calls.at(-1)?.[0]);
    expect(requestedUrl).toContain("latestTrend=true");
    expect(requestedUrl).toContain("topic=sql_join");
  });

  it("불러오기에 실패하면 재시도 안내를 보여 준다", async () => {
    stubApiResponses({});
    renderExamTrend();
    expect(await screen.findByRole("button", { name: "다시 시도하기" })).toBeInTheDocument();
  });

  it("프로 필요면 재시도 대신 잠금 미리보기 (#578)", async () => {
    stubApiResponses({ "/exam-trends/latest": apiErrorResponse(403, { errorCode: "PRO_REQUIRED" }) });
    renderExamTrend();
    expect(await screen.findByRole("region", { name: "최근 기출 토픽 비중 · 이번 회차 예상" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "앱에서 이용권으로 열기" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "다시 시도하기" })).toBeNull();
  });
});
