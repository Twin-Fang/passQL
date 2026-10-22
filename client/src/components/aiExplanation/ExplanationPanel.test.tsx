// AI 해설 화면 (#521): 즉시 표시, 생성 중 > 완료 전환, 실패 재시도, 패널 열린 채 다음 문제, 해설함 다시 열기
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { useState } from "react";
import { act, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import ExplanationPanel from "./ExplanationPanel";
import ExplanationPreviewCard from "./ExplanationPreviewCard";
import ExplanationHistoryButton from "./ExplanationHistoryButton";
import { useAuthStore } from "../../stores/authStore";
import { useExplanationHistoryStore, type ExplanationHistoryEntry } from "../../stores/explanationHistoryStore";
import type { ChoiceExplanation, ChoiceExplanationResponse } from "../../types/api";

// 재조회 간격만 짧게 (횟수 상한은 실제 규칙)
vi.mock("../../lib/choiceExplanationPolling", async (importOriginal) => ({
  ...(await importOriginal<typeof import("../../lib/choiceExplanationPolling")>()),
  computeNextPollDelayMilliseconds: () => 10,
}));

const STRUCTURED_EXPLANATION: ChoiceExplanation = {
  selectedChoiceKey: "B",
  correctChoiceKey: "A",
  isSelectedCorrect: false,
  verdict: "서버 판정 문구",
  correctReason: "`DENSE_RANK` 는 동점 다음 순위를 건너뛰지 않음",
  keyConcepts: [{ name: "DENSE_RANK", description: "동점 같은 순위, 다음 순위 1 증가" }],
  confusingPoints: ["`RANK` 와 다음 순위만 다름"],
  choiceAnalyses: [
    { choiceKey: "A", isCorrect: true, reason: "건너뛰지 않아 3" },
    { choiceKey: "B", isCorrect: false, reason: "4 는 RANK 기준 순위" },
  ],
  examTip: "동점 바로 다음 행 순위로 구분",
};

function buildEntry(overrides: Partial<ExplanationHistoryEntry> = {}): ExplanationHistoryEntry {
  return {
    id: "cs1:B",
    questionUuid: "q1",
    choiceSetUuid: "cs1",
    selectedChoiceKey: "B",
    questionLabel: "1번 문제",
    displayLabelByChoiceKey: { A: "A", B: "B" },
    isCorrect: false,
    initialExplanation: null,
    fallbackText: null,
    ...overrides,
  };
}

function toResponse(overrides: Partial<ChoiceExplanationResponse>): ChoiceExplanationResponse {
  return {
    choiceSetUuid: "cs1",
    selectedChoiceKey: "B",
    status: "READY",
    explanation: null,
    text: null,
    promptVersion: 1,
    retryAfterMilliseconds: null,
    lockedSections: [],
    ...overrides,
  };
}

/** 해설 조회 응답을 순서대로 돌려주는 가짜 fetch (마지막 응답 반복), 호출 수 기록 */
function stubChoiceExplanationResponses(responses: readonly (ChoiceExplanationResponse | "network-error")[]) {
  const fetchMock = vi.fn(async () => {
    const response = responses[Math.min(fetchMock.mock.calls.length - 1, responses.length - 1)];
    if (response === "network-error") return new Response(JSON.stringify({ message: "실패" }), { status: 500 });
    return new Response(JSON.stringify(response), { status: 200 });
  });
  vi.stubGlobal("fetch", fetchMock);
  return fetchMock;
}

function renderWithQueryClient(element: React.ReactElement) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(<QueryClientProvider client={queryClient}>{element}</QueryClientProvider>);
}

/** 풀이 화면 축소판: 미리보기(피드백 바) + 다음 문제 버튼 + 패널 */
function PracticeHost({ entries }: { readonly entries: readonly ExplanationHistoryEntry[] }) {
  const [questionIndex, setQuestionIndex] = useState(0);
  const addEntry = useExplanationHistoryStore((state) => state.addEntry);
  const openEntry = useExplanationHistoryStore((state) => state.openEntry);
  const currentEntry = entries[questionIndex];
  return (
    <>
      <ExplanationHistoryButton />
      <p>{`${questionIndex + 1}번 풀이 화면`}</p>
      {currentEntry && (
        <>
          <button type="button" onClick={() => addEntry(currentEntry)}>
            제출
          </button>
          <ExplanationPreviewCard entry={currentEntry} onOpen={() => openEntry(currentEntry.id)} />
        </>
      )}
      <button type="button" onClick={() => setQuestionIndex((index) => index + 1)}>
        다음 문제
      </button>
      <ExplanationPanel />
    </>
  );
}

describe("AI 해설", () => {
  beforeEach(() => {
    useAuthStore.setState({ memberUuid: "m1" });
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    useExplanationHistoryStore.getState().reset();
  });

  it("제출 응답 구조화 해설은 조회 없이 바로 미리보기·전체 해설을 보여 준다", () => {
    const fetchMock = stubChoiceExplanationResponses([toResponse({})]);
    const entry = buildEntry({ initialExplanation: STRUCTURED_EXPLANATION });
    renderWithQueryClient(<PracticeHost entries={[entry]} />);
    fireEvent.click(screen.getByRole("button", { name: "제출" }));

    expect(screen.getByText("4 는 RANK 기준 순위")).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: "해설 전체 보기" }));
    const panel = screen.getByRole("complementary", { name: "AI 해설 패널" });
    expect(within(panel).getByText("AI 해설 · 1번 문제")).toBeInTheDocument();
    // 판정은 서버 verdict 가 아니라 표시 라벨로 조립
    expect(within(panel).getByText("오답 · B 선택, 정답은 A · 4 는 RANK 기준 순위")).toBeInTheDocument();
    expect(within(panel).queryByText("서버 판정 문구")).not.toBeInTheDocument();
    for (const sectionTitle of ["정답 A 근거", "핵심 개념", "헷갈리는 지점", "보기별 판단", "시험 팁"]) {
      expect(within(panel).getByText(sectionTitle)).toBeInTheDocument();
    }
    expect(within(panel).getByText("DENSE_RANK", { selector: "dt" })).toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("생성 중이면 스켈레톤 한 블록을 보이고 재조회로 완료되면 해설로 바꾼다", async () => {
    const fetchMock = stubChoiceExplanationResponses([
      toResponse({ status: "GENERATING", retryAfterMilliseconds: 1500 }),
      toResponse({ status: "READY", explanation: STRUCTURED_EXPLANATION }),
    ]);
    renderWithQueryClient(<ExplanationPreviewCard entry={buildEntry()} onOpen={() => {}} />);

    expect(screen.getAllByRole("status")).toHaveLength(1);
    expect(await screen.findByText("4 는 RANK 기준 순위")).toBeInTheDocument();
    expect(screen.queryByRole("status")).not.toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledTimes(2);
    const requestedUrl = String((fetchMock.mock.calls[0] as unknown[])[0]);
    expect(requestedUrl).toContain("/ai/choice-explanation?questionUuid=q1&choiceSetUuid=cs1&selectedChoiceKey=B");
  });

  it("생성이 끝나지 않으면 최대 횟수 뒤 실패로 바꾸고 다시 시도하면 처음부터 다시 묻는다", async () => {
    const fetchMock = stubChoiceExplanationResponses([toResponse({ status: "GENERATING" })]);
    renderWithQueryClient(<ExplanationPreviewCard entry={buildEntry()} onOpen={() => {}} />);

    expect(await screen.findByText("AI 해설을 불러오지 못했어요")).toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledTimes(8);

    fireEvent.click(screen.getByRole("button", { name: "다시 시도" }));
    await waitFor(() => expect(fetchMock.mock.calls.length).toBeGreaterThan(8));
  });

  it("서버 실패면 재시도 버튼과 마크다운 폴백을 보여 준다", async () => {
    stubChoiceExplanationResponses(["network-error"]);
    const entry = buildEntry({ fallbackText: "**정답 A** 는 `DENSE_RANK` 결과" });
    renderWithQueryClient(<PracticeHost entries={[entry]} />);
    fireEvent.click(screen.getByRole("button", { name: "제출" }));
    act(() => useExplanationHistoryStore.getState().openEntry(entry.id));

    const panel = screen.getByRole("complementary", { name: "AI 해설 패널" });
    expect(await within(panel).findByRole("button", { name: "다시 시도" })).toBeInTheDocument();
    expect(within(panel).getByText("DENSE_RANK", { selector: "code" })).toBeInTheDocument();
  });

  it("패널을 연 채 다음 문제로 넘어가도 패널이 남고, 해설함에서 앞 문제 해설을 다시 연다", async () => {
    stubChoiceExplanationResponses([toResponse({ status: "READY", explanation: STRUCTURED_EXPLANATION })]);
    const firstEntry = buildEntry({ initialExplanation: STRUCTURED_EXPLANATION });
    const secondEntry = buildEntry({ id: "cs2:A", questionUuid: "q2", choiceSetUuid: "cs2", selectedChoiceKey: "A", questionLabel: "2번 문제", isCorrect: true });
    renderWithQueryClient(<PracticeHost entries={[firstEntry, secondEntry]} />);

    fireEvent.click(screen.getByRole("button", { name: "제출" }));
    fireEvent.click(screen.getByRole("button", { name: "해설 전체 보기" }));
    // 패널이 떠 있어도 다음 문제 버튼이 눌림 (비모달)
    fireEvent.click(screen.getByRole("button", { name: "다음 문제" }));
    expect(screen.getByText("2번 풀이 화면")).toBeInTheDocument();
    const panel = screen.getByRole("complementary", { name: "AI 해설 패널" });
    expect(within(panel).getByText("AI 해설 · 1번 문제")).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: "제출" }));
    fireEvent.click(within(panel).getByRole("button", { name: "해설함 (2개)" }));
    const historyList = within(panel).getByRole("list", { name: "해설함" });
    expect(within(historyList).getByText("2번 문제")).toBeInTheDocument();
    fireEvent.click(within(historyList).getByText("1번 문제"));
    expect(within(panel).getByText("AI 해설 · 1번 문제")).toBeInTheDocument();

    // 닫으면 상단 바 해설함 버튼으로 다시 열기
    fireEvent.click(within(panel).getByRole("button", { name: "해설 닫기" }));
    expect(screen.queryByRole("complementary", { name: "AI 해설 패널" })).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: "해설함 열기 (2개)" }));
    expect(screen.getByRole("list", { name: "해설함" })).toBeInTheDocument();
  });
});
