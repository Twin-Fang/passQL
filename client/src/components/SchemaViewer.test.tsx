// 문제 테이블 영역: 기본 펼침, 컬럼·키·샘플 행 표시, 접기·펼치기, 더 보기, 원문 대체, 개념형 미표시 (#520)
import { describe, expect, it } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { INITIAL_SAMPLE_ROW_COUNT, SchemaViewer } from "./SchemaViewer";
import type { QuestionSchemaTable } from "../types/api";

const EMP_TABLE: QuestionSchemaTable = {
  tableName: "EMP",
  columns: [
    { name: "EMP_ID", type: "INT", isPrimaryKey: true, isForeignKey: false },
    { name: "NAME", type: "VARCHAR(50)", isPrimaryKey: false, isForeignKey: false },
    { name: "DEPT_ID", type: "INT", isPrimaryKey: false, isForeignKey: true },
  ],
  sampleRows: [
    ["1", "홍길동", "10"],
    ["2", "김영희", null],
  ],
};

describe("SchemaViewer", () => {
  it("기본 펼침으로 컬럼 이름·타입·키와 샘플 행(NULL 포함)을 보여 준다", () => {
    render(<SchemaViewer schemaTables={[EMP_TABLE]} />);

    expect(screen.getByRole("button", { name: /테이블 1개/ })).toHaveAttribute("aria-expanded", "true");
    expect(screen.getByText("EMP")).toBeInTheDocument();
    expect(screen.getByText("VARCHAR(50)")).toBeInTheDocument();
    expect(screen.getByText("PK")).toBeInTheDocument();
    expect(screen.getByText("FK")).toBeInTheDocument();
    expect(screen.getByText("홍길동")).toBeInTheDocument();
    expect(screen.getByText("NULL")).toBeInTheDocument();
    expect(screen.getByText("샘플 2행")).toBeInTheDocument();
  });

  it("토글로 접고 다시 펼칠 수 있다", () => {
    render(<SchemaViewer schemaTables={[EMP_TABLE]} />);
    const toggle = screen.getByRole("button", { name: /테이블 1개/ });

    fireEvent.click(toggle);
    expect(screen.queryByText("홍길동")).not.toBeInTheDocument();
    expect(toggle).toHaveAttribute("aria-expanded", "false");

    fireEvent.click(toggle);
    expect(screen.getByText("홍길동")).toBeInTheDocument();
  });

  it("샘플 행이 많으면 일부만 보이고 더 보기로 전부 펼친다", () => {
    const manyRows = Array.from({ length: INITIAL_SAMPLE_ROW_COUNT + 3 }, (_, index) => [`${index}`, `이름${index}`, "10"]);
    render(<SchemaViewer schemaTables={[{ ...EMP_TABLE, sampleRows: manyRows }]} />);

    expect(screen.queryByText(`이름${INITIAL_SAMPLE_ROW_COUNT}`)).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: "3행 더 보기" }));
    expect(screen.getByText(`이름${INITIAL_SAMPLE_ROW_COUNT + 2}`)).toBeInTheDocument();
  });

  it("해석된 테이블이 없으면 DDL·INSERT 원문을 보여 준다", () => {
    render(
      <SchemaViewer schemaTables={[]} schemaDdl="CREATE TABLE T (A INT)" schemaSampleData="INSERT INTO T VALUES (1)" />,
    );

    expect(screen.getByText("CREATE TABLE T (A INT)")).toBeInTheDocument();
    expect(screen.getByText("INSERT INTO T VALUES (1)")).toBeInTheDocument();
  });

  it("스키마 없는 개념형 문제는 영역을 그리지 않는다", () => {
    const { container } = render(<SchemaViewer schemaTables={[]} schemaDdl={null} />);

    expect(container).toBeEmptyDOMElement();
  });
});
