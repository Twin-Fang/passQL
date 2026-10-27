import { useMutation } from "@tanstack/react-query";
import { submitFeedback } from "../api/feedback";

/**
 * 의견 전송 mutation (목록 조회 없음, 단건 전송만)
 */
export function useSubmitFeedback() {
  return useMutation({ mutationFn: submitFeedback });
}
