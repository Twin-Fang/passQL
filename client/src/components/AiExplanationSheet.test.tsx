import { render, screen, fireEvent } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import AiExplanationSheet from "./AiExplanationSheet";

// AI 해설 시트(#354): 로딩 → 해설 본문 / 실패 시 안내. 요청이 실패해도 빈 화면이 되면 안 된다.
describe("AiExplanationSheet", () => {
  const base = { isOpen: true, isLoading: false, text: "", onClose: () => {} };

  it("닫혀 있으면 아무것도 그리지 않는다", () => {
    const { container } = render(<AiExplanationSheet {...base} isOpen={false} />);
    expect(container).toBeEmptyDOMElement();
  });

  it("로딩 중에는 분석 중 문구를 보여 준다", () => {
    render(<AiExplanationSheet {...base} isLoading />);
    expect(screen.getByText("AI가 분석 중입니다...")).toBeInTheDocument();
  });

  it("해설 본문과 고정되지 않은 안내 문구를 보여 준다 (모델명·프롬프트 버전을 적지 않는다)", () => {
    render(<AiExplanationSheet {...base} text={"RANK는 동점이면 순위를 건너뜁니다."} />);
    expect(screen.getByText(/RANK는 동점이면 순위를 건너뜁니다\./)).toBeInTheDocument();
    expect(screen.getByText(/AI가 만든 해설이에요/)).toBeInTheDocument();
    expect(screen.queryByText(/qwen|프롬프트 v/)).not.toBeInTheDocument();
  });

  it("요청이 실패하면 빈 화면 대신 안내를 보여 주고 하단 문구는 숨긴다", () => {
    render(<AiExplanationSheet {...base} isError text="" />);
    expect(screen.getByRole("alert")).toHaveTextContent("AI 해설을 불러올 수 없어요");
    expect(screen.queryByText(/AI가 만든 해설이에요/)).not.toBeInTheDocument();
  });

  it("닫기 버튼과 바깥 영역 클릭으로 닫는다", () => {
    const onClose = vi.fn();
    const { container } = render(<AiExplanationSheet {...base} text="x" onClose={onClose} />);
    fireEvent.click(screen.getByRole("button"));
    fireEvent.click(container.querySelector(".dialog-overlay")!);
    expect(onClose).toHaveBeenCalledTimes(2);
  });
});
