// 지문 마크다운: 표는 파이프 원문이 아닌 표로, NULL 칸은 결과 표와 같은 NULL 표시, 결과형 보기 NULL 셀 (#549, #550)
import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import MarkdownText from "./MarkdownText";
import { ResultMatchTable } from "./ResultMatchTable";

describe("MarkdownText", () => {
  it("지문 속 마크다운 표를 표로 그리고 NULL 칸을 구분한다", () => {
    render(<MarkdownText text={"[EMP]\n\n| ID | BONUS |\n| --- | --- |\n| 1 | NULL |\n| 2 | 50 |"} />);

    expect(screen.getByRole("table")).toBeInTheDocument();
    expect(screen.getByRole("columnheader", { name: "BONUS" })).toBeInTheDocument();
    expect(screen.getByText("NULL")).toHaveClass("result-table-null");
    expect(screen.queryByText(/\| --- \|/)).not.toBeInTheDocument();
  });
});

describe("ResultMatchTable", () => {
  it("결과형 보기의 NULL 은 빈칸이 아니라 NULL 로 보인다", () => {
    render(<ResultMatchTable body={'[{"ID":1,"BONUS":null}]'} />);

    expect(screen.getByText("NULL")).toHaveClass("result-table-null");
  });
});
