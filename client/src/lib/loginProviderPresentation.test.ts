import { describe, expect, it } from "vitest";
import { loginAccountLabelOf } from "./loginProviderPresentation";

// 로그인 계정 표시 판정 (#908): 이메일 > 없음·빈 값·Apple 가림이면 제공자 이름
describe("loginAccountLabelOf", () => {
  it("이메일이 있으면 이메일", () => {
    expect(loginAccountLabelOf("KAKAO", "sqld@kakao.com")).toBe("sqld@kakao.com");
  });

  it("이메일이 없거나 비면 제공자 이름", () => {
    expect(loginAccountLabelOf("KAKAO", null)).toBe("카카오");
    expect(loginAccountLabelOf("GITHUB", "  ")).toBe("GitHub");
  });

  it("Apple 이메일 가리기 주소는 제공자 이름", () => {
    expect(loginAccountLabelOf("APPLE", "x1y2z3@privaterelay.appleid.com")).toBe("Apple");
  });
});
