import type { ReactNode } from "react";

// 해설 문장 속 표기 2종: **굵게**, `코드`
const INLINE_MARK_PATTERN = /\*\*(.+?)\*\*|`([^`\n]+)`/g;

/** 한 문장 > 글자·굵게·인라인 코드 조각 */
function toInlineNodes(text: string): ReactNode[] {
  const nodes: ReactNode[] = [];
  let cursor = 0;
  for (const match of text.matchAll(INLINE_MARK_PATTERN)) {
    const matchStart = match.index ?? 0;
    if (matchStart > cursor) nodes.push(text.slice(cursor, matchStart));
    if (match[1] !== undefined) {
      nodes.push(<strong key={matchStart} className="font-bold">{match[1]}</strong>);
    } else {
      nodes.push(<code key={matchStart} className="explanation-inline-code">{match[2]}</code>);
    }
    cursor = matchStart + match[0].length;
  }
  if (cursor < text.length) nodes.push(text.slice(cursor));
  return nodes;
}

interface InlineMarkdownTextProps {
  readonly text: string;
  readonly className?: string;
}

/**
 * 구조화 해설 문장 1개 (블록 마크다운 없음, 말줄임 line-clamp 가능하게 span 하나로)
 */
export default function InlineMarkdownText({ text, className }: InlineMarkdownTextProps) {
  return <span className={className}>{toInlineNodes(text)}</span>;
}
