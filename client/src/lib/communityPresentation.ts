import { ApiError } from "../api/client";
import type { CommunityFeedSource } from "../api/community";
import type { SolveSnapshot } from "../types/api";
import { toUserErrorMessage } from "./userErrorMessage";

export const COMMUNITY_PATH = "/community";
export const COMMUNITY_MINE_PATH = "/community/me";
export const toCommunityQuestionPath = (questionUuid: string) => `/community/questions/${questionUuid}`;

// 의견 최대 글자 수 (서버 검증과 동일: 1~500)
export const COMMUNITY_POST_MAX_LENGTH = 500;

export const COMMUNITY_FEED_TABS: readonly {
  readonly source: CommunityFeedSource;
  readonly label: string;
  readonly emptyMessage: string;
  readonly emptyActionLabel: string;
  readonly emptyActionPath: string;
}[] = [
  { source: "hot", label: "뜨는 토론", emptyMessage: "첫 토론을 시작해 보세요", emptyActionLabel: "문제 풀러 가기", emptyActionPath: "/questions" },
  { source: "trend", label: "최신 경향", emptyMessage: "최신 경향 문제의 의견이 아직 없어요", emptyActionLabel: "출제 경향 보기", emptyActionPath: "/exam-trend" },
  { source: "solved", label: "내가 푼 문제", emptyMessage: "문제를 풀면 여기에 모여요", emptyActionLabel: "문제 풀러 가기", emptyActionPath: "/questions" },
  { source: "mine", label: "내 의견", emptyMessage: "아직 남긴 의견이 없어요", emptyActionLabel: "문제 풀러 가기", emptyActionPath: "/questions" },
];

export const COMMUNITY_REPORT_CATEGORIES: readonly { readonly value: string; readonly label: string }[] = [
  { value: "ABUSE", label: "욕설·비방" },
  { value: "SPAM", label: "광고·스팸" },
  { value: "ANSWER_SPOILER", label: "정답 노출" },
  { value: "ETC", label: "기타" },
];

// 신고 상세 최대 글자 수 (서버 검증)
export const COMMUNITY_REPORT_DETAIL_MAX_LENGTH = 200;

export const COMMUNITY_UGC_NOTICE = "서로 존중하는 의견만 남겨 주세요. 정답을 직접 알려 주는 글은 신고될 수 있어요.";

// 서버 errorCode > 짧은 한국어 문구 (서버 message 가 없거나 길 때 화면 문구 통일)
const COMMUNITY_ERROR_MESSAGE_BY_CODE: Readonly<Record<string, string>> = {
  COMMUNITY_SOLVE_REQUIRED: "풀고 나서 의견을 볼 수 있어요",
  COMMUNITY_CONTENT_INVALID: "의견은 1~500자로 입력해 주세요",
  COMMUNITY_CONTENT_FORBIDDEN_WORD: "사용할 수 없는 표현이 포함돼 있어요",
  COMMUNITY_POST_DUPLICATE: "같은 내용을 이미 남겼어요",
  COMMUNITY_POST_RATE_LIMITED: "너무 빨라요. 잠시 후 다시 시도해 주세요",
  COMMUNITY_DAILY_LIMIT_EXCEEDED: "오늘 쓸 수 있는 의견 수를 모두 썼어요",
  DAILY_LIMIT_EXCEEDED: "오늘 쓸 수 있는 의견 수를 모두 썼어요",
  COMMUNITY_POST_NOT_FOUND: "이미 삭제되었거나 볼 수 없는 의견이에요",
};

// 이미지 errorCode > 서버 문구가 없을 때(5xx 등) 쓰는 문구 (서버 4xx 문구가 있으면 그쪽 우선)
const COMMUNITY_IMAGE_FALLBACK_MESSAGE_BY_CODE: Readonly<Record<string, string>> = {
  COMMUNITY_IMAGE_INVALID_FORMAT: "WebP 사진만 올릴 수 있어요",
  COMMUNITY_IMAGE_DIMENSION_EXCEEDED: "사진 크기가 너무 커요",
  COMMUNITY_IMAGE_QUOTA_EXCEEDED: "사진 저장 공간을 모두 썼어요",
  COMMUNITY_IMAGE_TOO_LARGE: "사진 용량이 너무 커요",
  COMMUNITY_IMAGE_UPLOAD_RATE_LIMITED: "사진을 너무 빨리 올리고 있어요. 잠시 후 다시 시도해 주세요",
  COMMUNITY_IMAGE_DAILY_LIMIT_EXCEEDED: "오늘 올릴 수 있는 사진 수를 모두 썼어요",
  COMMUNITY_IMAGE_STORAGE_UNAVAILABLE: "지금은 사진을 올릴 수 없어요. 잠시 후 다시 시도해 주세요",
  COMMUNITY_IMAGE_TOO_MANY: "사진은 최대 2장까지 올릴 수 있어요",
  COMMUNITY_IMAGE_INVALID_ATTACHMENT: "첨부할 수 없는 사진이에요. 사진을 다시 선택해 주세요",
};

/** 오류 > errorCode 문자열 (없으면 null) */
export function toErrorCode(error: unknown): string | null {
  if (!(error instanceof ApiError)) return null;
  const errorCode = (error.body as { errorCode?: unknown } | null)?.errorCode;
  return typeof errorCode === "string" ? errorCode : null;
}

/** 풀이 전이라 의견을 볼 수 없는 오류인지 */
export function isSolveRequiredError(error: unknown): boolean {
  return toErrorCode(error) === "COMMUNITY_SOLVE_REQUIRED";
}

/** 커뮤니티 오류 > 사용자 문구 (코드 매핑 > 서버 4xx 문구 > 이미지 코드 문구 > fallback) */
export function toCommunityErrorMessage(error: unknown, fallbackMessage: string): string {
  const errorCode = toErrorCode(error);
  if (errorCode && COMMUNITY_ERROR_MESSAGE_BY_CODE[errorCode]) return COMMUNITY_ERROR_MESSAGE_BY_CODE[errorCode];
  const serverMessage = toUserErrorMessage(error, "");
  if (serverMessage) return serverMessage;
  return (errorCode && COMMUNITY_IMAGE_FALLBACK_MESSAGE_BY_CODE[errorCode]) || fallbackMessage;
}

/** 사진 첨부가 지원되지 않는 브라우저 안내 */
export const COMMUNITY_IMAGE_UNSUPPORTED_NOTICE = "이 브라우저에서는 사진 첨부를 지원하지 않아요";

/** 풀이 스냅샷 > 배지 문구 ("정답 · 2번째 시도에 해결" / "오답 · 3번 시도") */
export function toSolveSnapshotLabel(snapshot: SolveSnapshot): string {
  return snapshot.isCorrect ? `정답 · ${snapshot.attemptCount}번째 시도에 해결` : `오답 · ${snapshot.attemptCount}번 시도`;
}
