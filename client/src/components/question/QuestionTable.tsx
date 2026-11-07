import type { StemTable } from "../../lib/stemBlocks";
import { isSqlNullCell, toSqlCellText } from "../../lib/sqlCellPresentation";

interface QuestionTableProps {
  readonly table: StemTable;
}

/**
 * 지문 표·스키마 표 공통: 이름 > 머리글(컬럼 이름 + PK·FK) > 모든 행
 * 풀이에 행 전부가 필요해 접지 않음, 자료형은 표시하지 않음 (#903)
 */
export default function QuestionTable({ table }: QuestionTableProps) {
  return (
    <figure className="flex flex-col gap-1.5">
      {table.name ? (
        <figcaption className="font-mono text-sm font-semibold text-text-primary">{table.name}</figcaption>
      ) : null}
      <div className="overflow-x-auto rounded-tile border border-border bg-surface-card">
        <table className="question-table">
          <thead>
            <tr>
              {table.columns.map((column, columnIndex) => (
                <th key={`${column.name}-${columnIndex}`} scope="col">
                  {column.name}
                  {column.isPrimaryKey ? <ColumnKeyBadge label="PK" isPrimaryKey /> : null}
                  {column.isForeignKey ? <ColumnKeyBadge label="FK" isPrimaryKey={false} /> : null}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {table.rows.map((row, rowIndex) => (
              <tr key={rowIndex}>
                {table.columns.map((column, columnIndex) => {
                  const cell = row[columnIndex] ?? null;
                  return (
                    <td key={`${column.name}-${columnIndex}`} className={isSqlNullCell(cell) ? "result-table-null" : undefined}>
                      {toSqlCellText(cell)}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </figure>
  );
}

/** 컬럼 키 배지: PK 채움, FK 연한 배경 */
function ColumnKeyBadge({ label, isPrimaryKey }: { readonly label: string; readonly isPrimaryKey: boolean }) {
  const colorClassName = isPrimaryKey ? "bg-brand text-on-brand" : "bg-brand-light text-brand";
  return (
    <span className={`ml-1 inline-block rounded px-1 align-middle font-sans text-micro font-bold leading-normal ${colorClassName}`}>
      {label}
    </span>
  );
}
