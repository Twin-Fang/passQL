import { fetchQuestions } from "./questions";
import type { QuestionSummary } from "../types/api";

/** 고른 카테고리에 풀 문제 0개 (화면은 안내 모달로 분기) */
export class EmptyPracticeTopicError extends Error {
  constructor() {
    super("해당 카테고리에 풀 수 있는 문제가 없어요.");
    this.name = "EmptyPracticeTopicError";
  }
}

interface GenerateResponse {
  readonly sessionId: string;
  readonly questions: readonly QuestionSummary[];
}

export async function generatePractice(topicCode: string): Promise<GenerateResponse> {
  const page = await fetchQuestions({ topic: topicCode, size: 10 });
  if (page.content.length === 0) {
    throw new EmptyPracticeTopicError();
  }
  return {
    // UUID v4로 생성 — 백엔드 ai-comment 캐시 키에 UUID 타입으로 전달됨
    sessionId: crypto.randomUUID(),
    questions: page.content,
  };
}
