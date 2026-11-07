import { useQuery } from "@tanstack/react-query";
import { fetchAccuracyDetail, fetchStudyPattern } from "../api/progress";
import { useMemberQueryScope } from "./useMemberQueryScope";
import { PROGRESS_QUERY_KEY_PREFIX } from "../lib/learningRecordQueries";

// 키 첫 요소를 progress 로 두어 제출 후 학습 기록 무효화에 함께 걸림 (#909)
const STUDY_PATTERN_QUERY_KEY = "studyPattern";
const ACCURACY_DETAIL_QUERY_KEY = "accuracyDetail";

/** 학습 패턴 (무료) */
export function useStudyPattern() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery({
    queryKey: [PROGRESS_QUERY_KEY_PREFIX, STUDY_PATTERN_QUERY_KEY, memberUuid],
    queryFn: fetchStudyPattern,
    enabled: isMemberQueryEnabled,
    retry: false,
  });
}

/** 정답률 상세 (프로): 무료는 403 PRO_REQUIRED > 화면이 잠금 미리보기 */
export function useAccuracyDetail() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery({
    queryKey: [PROGRESS_QUERY_KEY_PREFIX, ACCURACY_DETAIL_QUERY_KEY, memberUuid],
    queryFn: fetchAccuracyDetail,
    enabled: isMemberQueryEnabled,
    retry: false,
  });
}
