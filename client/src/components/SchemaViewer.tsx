import { memo, useState } from "react";
import { ChevronDown, Table2 } from "lucide-react";
import type { QuestionSchemaTable } from "../types/api";

// 테이블별 처음에 보여 줄 샘플 행 수 (나머지는 더 보기)
export const INITIAL_SAMPLE_ROW_COUNT = 5;

interface SchemaViewerProps {
  // 서버가 해석한 테이블 목록 (#520)
  readonly schemaTables: readonly QuestionSchemaTable[] | null | undefined;
  // 해석 결과가 비었을 때만 원문으로 보여 줄 DDL·샘플 INSERT
  readonly schemaDdl?: string | null;
  readonly schemaSampleData?: string | null;
}

/**
 * 문제 테이블 영역: 기본 펼침, 테이블마다 컬럼(이름·타입·키) 머리글 + 샘플 행 표
 * 해석 결과 없음 > DDL·INSERT 원문 표시, 둘 다 없으면 렌더하지 않음
 */
export const SchemaViewer = memo(function SchemaViewer({
  schemaTables,
  schemaDdl,
  schemaSampleData,
}: SchemaViewerProps) {
  const [isOpen, setIsOpen] = useState(true);
  const tables = schemaTables ?? [];
  const hasRawFallback = tables.length === 0 && Boolean(schemaDdl?.trim());
  if (tables.length === 0 && !hasRawFallback) return null;

  return (
    <section className="mt-3" aria-label="문제 테이블">
      {/* 펼침 토글 (제출 전·후 공통) */}
      <button
        type="button"
        aria-expanded={isOpen}
        onClick={() => setIsOpen((previous) => !previous)}
        className="flex w-full items-center gap-1.5 py-1 text-sm font-semibold text-text-secondary"
      >
        <Table2 size={14} aria-hidden="true" />
        테이블{tables.length > 0 ? ` ${tables.length}개` : ""}
        <ChevronDown
          size={14}
          aria-hidden="true"
          className={`ml-auto transition-transform duration-200 ${isOpen ? "rotate-180" : ""}`}
        />
      </button>

      {isOpen ? (
        <div className="mt-1 space-y-3">
          {hasRawFallback ? (
            <RawSchemaBlocks schemaDdl={schemaDdl ?? ""} schemaSampleData={schemaSampleData ?? ""} />
          ) : (
            tables.map((table) => <SchemaTableCard key={table.tableName} table={table} />)
          )}
        </div>
      ) : null}
    </section>
  );
});

/** 테이블 1개: 이름 > 컬럼 머리글(이름, 타입, PK·FK) > 샘플 행 (처음 5행 + 더 보기) */
function SchemaTableCard({ table }: { readonly table: QuestionSchemaTable }) {
  const [isShowingAllRows, setIsShowingAllRows] = useState(false);
  const visibleRows = isShowingAllRows ? table.sampleRows : table.sampleRows.slice(0, INITIAL_SAMPLE_ROW_COUNT);
  const hiddenRowCount = table.sampleRows.length - visibleRows.length;

  return (
    <div className="overflow-hidden rounded-xl border border-border bg-surface-card">
      <div className="flex items-center gap-1.5 border-b border-border bg-brand-light px-3 py-1.5 font-mono text-sm font-semibold text-brand">
        {table.tableName}
        <span className="ml-auto font-sans text-xs font-medium text-text-caption">
          {table.sampleRows.length > 0 ? `샘플 ${table.sampleRows.length}행` : "샘플 데이터 없음"}
        </span>
      </div>
      <div className="overflow-x-auto">
        <table className="data-table w-full whitespace-nowrap">
          <thead>
            <tr>
              {table.columns.map((column) => (
                <th key={column.name} scope="col">
                  <span className="font-mono">{column.name}</span>
                  {column.isPrimaryKey ? <KeyMark label="PK" /> : null}
                  {column.isForeignKey ? <KeyMark label="FK" /> : null}
                  {column.type ? (
                    <span className="block font-mono text-xs font-normal text-text-caption">{column.type}</span>
                  ) : null}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {visibleRows.map((row, rowIndex) => (
              <tr key={rowIndex}>
                {table.columns.map((column, columnIndex) => {
                  const cell = row[columnIndex];
                  return (
                    <td key={column.name} className={cell == null ? "result-table-null" : "font-mono"}>
                      {cell == null ? "NULL" : String(cell)}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {hiddenRowCount > 0 ? (
        <button
          type="button"
          onClick={() => setIsShowingAllRows(true)}
          className="w-full border-t border-border py-1.5 text-xs font-medium text-brand"
        >
          {hiddenRowCount}행 더 보기
        </button>
      ) : null}
    </div>
  );
}

/** 컬럼 키 표시 (PK, FK) */
function KeyMark({ label }: { readonly label: string }) {
  return <span className="ml-1 text-xs font-semibold text-brand">{label}</span>;
}

/** 해석 실패 대비: DDL·샘플 INSERT 원문 코드 블록 */
function RawSchemaBlocks({ schemaDdl, schemaSampleData }: { readonly schemaDdl: string; readonly schemaSampleData: string }) {
  return (
    <>
      <pre className="whitespace-pre-wrap rounded-lg bg-surface-code px-3 py-2 font-mono text-xs">{schemaDdl}</pre>
      {schemaSampleData.trim() ? (
        <pre className="whitespace-pre-wrap rounded-lg bg-surface-code px-3 py-2 font-mono text-xs">{schemaSampleData}</pre>
      ) : null}
    </>
  );
}
