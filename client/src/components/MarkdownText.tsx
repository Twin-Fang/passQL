import { createContext, isValidElement, memo, useContext, useRef } from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { SQL_NULL_CELL_LABEL } from "../lib/sqlCellPresentation";

// 전역 단어 인덱스 카운터 — Context로 커스텀 컴포넌트 간 공유
const WordIndexContext = createContext<{ current: number } | null>(null);

/** 단어를 공백 기준으로 쪼개 <span style="--i: N">단어</span> 배열로 변환 */
function splitToAnimatedSpans(
  text: string,
  indexRef: { current: number },
): React.ReactNode[] {
  return text.split(/(\s+)/).map((token, i) => {
    // 공백이거나 빈 문자열은 그대로 — 빈 span 생성 방지
    if (!token || /^\s+$/.test(token)) return token;
    const idx = indexRef.current++;
    return (
      <span key={i} className="md-word" style={{ "--i": idx } as React.CSSProperties}>
        {token}
      </span>
    );
  });
}

/**
 * children을 순서대로 순회하며 애니메이션 처리
 * - string: 단어 단위 span으로 분해
 * - MdInlineCode element: 코드 전체를 단어 1개로 취급해 md-word span으로 교체
 *   (MdInlineCode 렌더 시점에 인덱스를 소비하면 순서가 어긋남 — 여기서 미리 처리)
 * - 그 외 React element: 그대로 반환 (MdStrong 등은 자체적으로 처리)
 */
function animateTextNodes(
  children: React.ReactNode,
  indexRef: { current: number },
): React.ReactNode {
  if (Array.isArray(children)) {
    return children.map((child) => animateTextNodes(child, indexRef));
  }
  if (typeof children === "string") {
    return splitToAnimatedSpans(children, indexRef);
  }
  if (isValidElement(children)) {
    const el = children as React.ReactElement<{ children?: React.ReactNode }>;
    // MdInlineCode: 코드 전체를 단어 1개로 취급
    // 여기서 인덱스 소비 안 하면 string 처리 후 나중에 렌더되어 순서 역전 발생
    if (el.type === MdInlineCode) {
      const idx = indexRef.current++;
      return (
        <span key={idx} className="md-word" style={{ "--i": idx } as React.CSSProperties}>
          {children}
        </span>
      );
    }
  }
  return children;
}

// ── 커스텀 Markdown 요소 컴포넌트 ──────────────────────────────

function MdP({ children }: { children?: React.ReactNode }) {
  const indexRef = useContext(WordIndexContext);
  const content = indexRef ? animateTextNodes(children, indexRef) : children;
  return <p className="text-body leading-relaxed mb-2 last:mb-0">{content}</p>;
}

function MdStrong({ children }: { children?: React.ReactNode }) {
  const indexRef = useContext(WordIndexContext);
  const content = indexRef ? animateTextNodes(children, indexRef) : children;
  return <strong className="font-bold">{content}</strong>;
}

function MdEm({ children }: { children?: React.ReactNode }) {
  const indexRef = useContext(WordIndexContext);
  const content = indexRef ? animateTextNodes(children, indexRef) : children;
  return <em className="italic">{content}</em>;
}

function MdInlineCode({ children }: { children?: React.ReactNode }) {
  // 인덱스 소비는 부모(MdP, MdLi 등)의 animateTextNodes에서 처리
  // 이 컴포넌트는 스타일만 담당
  return (
    <code className="bg-surface-code px-1 rounded text-sm font-mono">{children}</code>
  );
}

function MdPre({ children }: { children?: React.ReactNode }) {
  // 코드 블록은 애니메이션 없이 그대로 — 들여쓰기/포맷 보호
  return (
    <pre className="bg-surface-code rounded-lg px-4 py-3 text-xs leading-relaxed whitespace-pre-wrap wrap-break-word font-mono my-2">
      {children}
    </pre>
  );
}

function MdUl({ children }: { children?: React.ReactNode }) {
  return <ul className="list-disc pl-4 space-y-1 mb-2">{children}</ul>;
}

function MdOl({ children }: { children?: React.ReactNode }) {
  return <ol className="list-decimal pl-4 space-y-1 mb-2">{children}</ol>;
}

function MdLi({ children }: { children?: React.ReactNode }) {
  const indexRef = useContext(WordIndexContext);
  const content = indexRef ? animateTextNodes(children, indexRef) : children;
  return <li className="text-body leading-relaxed">{content}</li>;
}

function MdA({ href, children }: { href?: string; children?: React.ReactNode }) {
  // 공지 본문 링크 (#529): 새 탭, 원래 페이지 정보 넘기지 않음
  return (
    <a href={href} target="_blank" rel="noopener noreferrer" className="text-brand underline underline-offset-2 break-all">
      {children}
    </a>
  );
}

// 지문 속 마크다운 표 (#550): 결과 표와 같은 data-table 모양, 넓으면 가로 스크롤
function MdTable({ children }: { children?: React.ReactNode }) {
  return (
    <div className="overflow-x-auto rounded-lg my-2">
      <table className="data-table w-full">{children}</table>
    </div>
  );
}

function MdTd({ children }: { children?: React.ReactNode }) {
  // 칸 글자가 NULL 이면 결과 표와 같은 NULL 표시
  const isNullCell = children === SQL_NULL_CELL_LABEL;
  return <td className={isNullCell ? "result-table-null" : "font-mono"}>{children}</td>;
}

// ── 컴포넌트 맵 ───────────────────────────────────────────────

const MD_COMPONENTS = {
  p: MdP,
  strong: MdStrong,
  em: MdEm,
  code: MdInlineCode,
  pre: MdPre,
  ul: MdUl,
  ol: MdOl,
  li: MdLi,
  a: MdA,
  table: MdTable,
  td: MdTd,
} as const;

// 표·취소선 등 GFM 문법 (렌더마다 새 배열을 만들지 않게 모듈 상수)
const REMARK_PLUGINS = [remarkGfm];

// ── MarkdownText 메인 컴포넌트 ────────────────────────────────

interface MarkdownTextProps {
  readonly text: string;
  /** 단어별 fade-in 애니메이션 여부 — AI 리포트에만 true */
  readonly animated?: boolean;
  readonly className?: string;
}

function MarkdownText({
  text,
  animated = false,
  className,
}: MarkdownTextProps) {
  const indexRef = useRef({ current: 0 });
  // text가 바뀌면 카운터 초기화
  indexRef.current.current = 0;

  const content = (
    <div className={className}>
      <ReactMarkdown remarkPlugins={REMARK_PLUGINS} components={MD_COMPONENTS}>{text}</ReactMarkdown>
    </div>
  );

  return animated ? (
    <WordIndexContext.Provider value={indexRef.current}>
      {content}
    </WordIndexContext.Provider>
  ) : (
    content
  );
}

// 부모 리렌더(타이머·단계 상태)마다 마크다운 재파싱 방지: text·animated·className 같으면 재사용
export default memo(MarkdownText);
