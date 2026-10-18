import { describe, expect, it } from "vitest";
import { ApiError } from "../api/client";
import { isSolveRequiredError, toCommunityErrorMessage, toSolveSnapshotLabel } from "./communityPresentation";

describe("communityPresentation", () => {
  it("풀이 전 400 은 errorCode 로 구분하고 안내 문구를 준다", () => {
    const error = new ApiError(400, { errorCode: "COMMUNITY_SOLVE_REQUIRED", message: "서버 문구" });
    expect(isSolveRequiredError(error)).toBe(true);
    expect(toCommunityErrorMessage(error, "기본")).toBe("풀고 나서 의견을 볼 수 있어요");
  });

  it("알 수 없는 코드는 서버 4xx 문구, 5xx 는 기본 문구", () => {
    expect(toCommunityErrorMessage(new ApiError(400, { errorCode: "X", message: "서버 문구" }), "기본")).toBe("서버 문구");
    expect(toCommunityErrorMessage(new ApiError(500, { errorCode: "X", message: "내부" }), "기본")).toBe("기본");
  });

  it("스냅샷 배지 문구", () => {
    const base = { difficulty: 1, solvedAt: "2026-10-18T00:00:00Z", topicCode: null };
    expect(toSolveSnapshotLabel({ ...base, isCorrect: true, attemptCount: 2 })).toBe("정답 · 2번째 시도에 해결");
    expect(toSolveSnapshotLabel({ ...base, isCorrect: false, attemptCount: 3 })).toBe("오답 · 3번 시도");
  });
});
