import { describe, expect, it } from "vitest";
import { toStemBlocks, toStemPreviewLine } from "./stemBlocks";
import type { QuestionSchemaTable } from "../types/api";

// 지문 블록 나누기 판정 고정 (#903): 앱 stem 블록 규칙과 같은 입력·기대값
const EMP_SCHEMA_TABLE: QuestionSchemaTable = {
  tableName: "EMP",
  columns: [
    { name: "EMP_ID", type: "INT", isPrimaryKey: true, isForeignKey: false },
    { name: "NAME", type: "VARCHAR(20)", isPrimaryKey: false, isForeignKey: false },
    { name: "DEPT", type: "VARCHAR(10)", isPrimaryKey: false, isForeignKey: true },
  ],
  sampleRows: [
    ["1", "KIM", "DEV"],
    ["2", "LEE", null],
  ],
};

describe("toStemBlocks", () => {
  it("목록: 용어: 설명은 나누고, 아니면 글 그대로, 번호 유지", () => {
    const blocks = toStemBlocks("속성이 다음과 같다.\n- 대출번호: 직전 번호에 1을 더한 번호\n- 그냥 항목\n1. 첫째 조건");

    expect(blocks).toEqual([
      { kind: "paragraph", text: "속성이 다음과 같다." },
      {
        kind: "list",
        items: [
          { ordinal: null, term: "대출번호", description: "직전 번호에 1을 더한 번호" },
          { ordinal: null, term: null, description: "그냥 항목" },
          { ordinal: "1.", term: null, description: "첫째 조건" },
        ],
      },
    ]);
  });

  it("질문: 한글 있는 ? 문장만 떼고 앞뒤 글은 각자 단락", () => {
    const blocks = toStemBlocks("다음 SQL을 보자. 결과로 옳은 것은? 단 NULL 은 제외한다.\nWHY?");

    expect(blocks).toEqual([
      { kind: "paragraph", text: "다음 SQL을 보자." },
      { kind: "question", text: "결과로 옳은 것은?" },
      { kind: "paragraph", text: "단 NULL 은 제외한다.\nWHY?" },
    ]);
  });

  it("보조 설명: 줄 전체가 괄호인 줄", () => {
    const blocks = toStemBlocks("도서관 엔터티다.\n(반납예정일과 반납일은 별도 속성이다.)");

    expect(blocks).toEqual([
      { kind: "paragraph", text: "도서관 엔터티다." },
      { kind: "note", text: "(반납예정일과 반납일은 별도 속성이다.)" },
    ]);
  });

  it("표 이름: 바로 앞 [이름] 줄은 표 이름으로 옮기고 지움, NULL 글자는 SQL NULL", () => {
    const blocks = toStemBlocks("테이블이 있다.\n[TAB1]\n| C1 | C2 |\n| --- | --- |\n| 1 | NULL |");

    expect(blocks).toEqual([
      { kind: "paragraph", text: "테이블이 있다." },
      {
        kind: "table",
        table: {
          name: "TAB1",
          columns: [
            { name: "C1", isPrimaryKey: false, isForeignKey: false },
            { name: "C2", isPrimaryKey: false, isForeignKey: false },
          ],
          rows: [["1", null]],
        },
      },
    ]);
  });

  it("코드 캡션: 첫 줄·빈 줄 다음 -- 주석은 캡션, 다음 캡션 전까지가 그 코드", () => {
    const blocks = toStemBlocks(
      "```sql\n-- SQL 1\nSELECT 1\n  FROM EMP; -- 끝\n\n-- SQL 2 (결과 행 수를 C4 라 한다)\nSELECT 2;\n```",
    );

    expect(blocks).toEqual([
      { kind: "code", caption: "SQL 1", code: "SELECT 1\n  FROM EMP; -- 끝" },
      { kind: "code", caption: "SQL 2 (결과 행 수를 C4 라 한다)", code: "SELECT 2;" },
    ]);
  });

  it("스키마 중복 제거: 컬럼 이름이 같은 지문 표 자리에 스키마 표 (대소문자 무시)", () => {
    const blocks = toStemBlocks(
      "EMP 를 보자.\n| emp_id | name | dept |\n| --- | --- | --- |\n| 1 | KIM | DEV |\n```sql\nSELECT * FROM EMP;\n```\n결과로 옳은 것은?",
      [EMP_SCHEMA_TABLE],
    );

    expect(blocks.map((block) => block.kind)).toEqual(["paragraph", "table", "code", "question"]);
    expect(blocks[1]).toEqual({
      kind: "table",
      table: {
        name: "EMP",
        columns: [
          { name: "EMP_ID", isPrimaryKey: true, isForeignKey: false },
          { name: "NAME", isPrimaryKey: false, isForeignKey: false },
          { name: "DEPT", isPrimaryKey: false, isForeignKey: true },
        ],
        rows: [
          ["1", "KIM", "DEV"],
          ["2", "LEE", null],
        ],
      },
    });
  });

  it("스키마 배치: 같은 지문 표 없으면 첫 표·코드 앞 > 첫 질문 앞 > 맨 끝", () => {
    const beforeCode = toStemBlocks("설명이다.\n```sql\nSELECT 1;\n```", [EMP_SCHEMA_TABLE]);
    const beforeQuestion = toStemBlocks("설명이다. 옳은 것은?", [EMP_SCHEMA_TABLE]);
    const atEnd = toStemBlocks("설명이다.", [EMP_SCHEMA_TABLE]);

    expect(beforeCode.map((block) => block.kind)).toEqual(["paragraph", "table", "code"]);
    expect(beforeQuestion.map((block) => block.kind)).toEqual(["paragraph", "table", "question"]);
    expect(atEnd.map((block) => block.kind)).toEqual(["paragraph", "table"]);
  });

  it("스키마 배치: 컬럼이 같아도 이름이 다른 지문 표는 대체하지 않음", () => {
    const projSchemaTable: QuestionSchemaTable = {
      tableName: "PROJ",
      columns: [
        { name: "ID", type: "NUMBER", isPrimaryKey: true, isForeignKey: false },
        { name: "DEPT_NO", type: "NUMBER", isPrimaryKey: false, isForeignKey: true },
      ],
      sampleRows: [],
    };
    const blocks = toStemBlocks(
      "[EMP]\n| ID | DEPT_NO |\n| --- | --- |\n| 1 | 10 |\n\n[PROJ]\n| ID | DEPT_NO |\n| --- | --- |\n| 1 | 10 |",
      [projSchemaTable],
    );
    const tables = blocks.flatMap((block) => (block.kind === "table" ? [block.table] : []));

    expect(tables.map((table) => table.name)).toEqual(["EMP", "PROJ"]);
    expect(tables[0].columns[0].isPrimaryKey).toBe(false);
    expect(tables[1].columns[0].isPrimaryKey).toBe(true);
    expect(tables[1].rows).toEqual([["1", "10"]]);
  });

  it("코드 캡션: 제약 설명 주석은 캡션이 아니라 코드 안 주석", () => {
    const blocks = toStemBlocks(
      "```sql\n-- EMP.DEPT_NO : REFERENCES DEPT(DEPT_NO) ON DELETE SET NULL\nDELETE FROM DEPT WHERE DEPT_NO = 10;\n```",
    );

    expect(blocks).toEqual([
      {
        kind: "code",
        caption: null,
        code: "-- EMP.DEPT_NO : REFERENCES DEPT(DEPT_NO) ON DELETE SET NULL\nDELETE FROM DEPT WHERE DEPT_NO = 10;",
      },
    ]);
  });
});

describe("toStemPreviewLine", () => {
  it("표·코드 캡션이 섞여도 한 줄 (표 > [표], 코드 > [SQL])", () => {
    expect(toStemPreviewLine("[EMP]\n| A |\n| --- |\n| 1 |\n```sql\n-- SQL 1\nSELECT 1;\n```\n옳은 것은?")).toBe(
      "[표] [SQL] 옳은 것은?",
    );
  });
});
