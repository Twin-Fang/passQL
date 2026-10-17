import { describe, expect, it } from "vitest";
import { ApiError } from "../api/client";
import { toUserErrorMessage } from "./userErrorMessage";

const FALLBACK_MESSAGE = "실행에 실패했어요";

describe("toUserErrorMessage", () => {
  it("4xx 서버 문구는 그대로 보여 준다", () => {
    const error = new ApiError(409, { errorCode: "NICKNAME_DUPLICATE", message: "이미 사용 중인 닉네임이에요" });
    expect(toUserErrorMessage(error, FALLBACK_MESSAGE)).toBe("이미 사용 중인 닉네임이에요");
  });

  it("5xx 는 서버 문구 대신 기본 문구", () => {
    const error = new ApiError(500, { errorCode: "INTERNAL_SERVER_ERROR", message: "NullPointerException" });
    expect(toUserErrorMessage(error, FALLBACK_MESSAGE)).toBe(FALLBACK_MESSAGE);
  });

  it("본문 없는 ApiError·네트워크 오류는 내부 문구 대신 기본 문구", () => {
    expect(toUserErrorMessage(new ApiError(404, null), FALLBACK_MESSAGE)).toBe(FALLBACK_MESSAGE);
    expect(toUserErrorMessage(new TypeError("Failed to fetch"), FALLBACK_MESSAGE)).toBe(FALLBACK_MESSAGE);
  });
});
