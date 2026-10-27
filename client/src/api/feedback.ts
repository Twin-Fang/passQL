import { apiFetch } from "./client";
import type { FeedbackSubmitResponse } from "../types/api";

// 의견 전송: multipart 의 request 파트(application/json) 한 개
export async function submitFeedback(content: string): Promise<FeedbackSubmitResponse> {
  const formData = new FormData();
  formData.append("request", new Blob([JSON.stringify({ content })], { type: "application/json" }));
  return apiFetch<FeedbackSubmitResponse>("/feedback", {
    method: "POST",
    body: formData,
  });
}
