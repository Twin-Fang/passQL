import { describe, expect, it } from "vitest";
import { ApiError } from "../api/client";
import { isWebpHeader, toScaledImageSize } from "./communityImageCompression";
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

  it("사진은 긴 변 기준으로 줄이고 확대하지 않는다", () => {
    expect(toScaledImageSize(4000, 3000, 1600)).toEqual({ width: 1600, height: 1200 });
    expect(toScaledImageSize(200, 100, 320)).toEqual({ width: 200, height: 100 });
  });

  it("WebP 는 앞 12바이트(RIFF....WEBP)로만 판별한다", () => {
    const webpHeader = Uint8Array.from([..."RIFF"].map((c) => c.charCodeAt(0)).concat([0, 0, 0, 0], [..."WEBP"].map((c) => c.charCodeAt(0))));
    expect(isWebpHeader(webpHeader)).toBe(true);
    expect(isWebpHeader(Uint8Array.from([0x89, 0x50, 0x4e, 0x47, 0, 0, 0, 0, 0, 0, 0, 0]))).toBe(false);
  });
});
