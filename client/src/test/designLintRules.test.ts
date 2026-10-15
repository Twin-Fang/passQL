// @vitest-environment node
/// <reference types="node" />
// eslint 디자인 규칙 자체 검증 (#462): 위반 4종을 실제로 잡는지, 예외 2건만 통과하는지
import { describe, expect, it } from "vitest";
import { ESLint } from "eslint";

const eslint = new ESLint({ cwd: process.cwd() });

/** 코드 > 지정 파일 경로로 lint 한 no-restricted-syntax 오류 수 */
async function countDesignRuleErrors(code: string, filePath: string): Promise<number> {
  const [lintResult] = await eslint.lintText(code, { filePath });
  return lintResult.messages.filter((message) => message.ruleId === "no-restricted-syntax").length;
}

describe("eslint 디자인 규칙", () => {
  const SCREEN_FILE_PATH = "src/pages/LintProbe.tsx";

  it.each([
    ["hex 문자열", `export const color = "#5856D6";`],
    ["Tailwind 임의 색값", "export const probe = <div className={`p-2 bg-[#5856D6]`} />;"],
    ["Tailwind 기본 팔레트", `export const probe = <div className="text-gray-500" />;`],
    ["white 클래스", `export const probe = <div className="bg-white" />;`],
    ["인라인 style", `export const probe = <div style={{ width: 10 }} />;`],
  ])("%s 차단", async (_caseName, code) => {
    expect(await countDesignRuleErrors(code, SCREEN_FILE_PATH)).toBeGreaterThan(0);
  });

  it("토큰 클래스·이슈 번호 문자열은 통과", async () => {
    const code = `export const probe = <div className="bg-brand text-text-primary border-border" title="(#462)" />;`;
    expect(await countDesignRuleErrors(code, SCREEN_FILE_PATH)).toBe(0);
  });

  it("예외: Google 로고 파일은 hex 만 허용", async () => {
    const filePath = "src/components/SocialLoginIcons.tsx";
    expect(await countDesignRuleErrors(`export const probe = <path fill="#4285F4" />;`, filePath)).toBe(0);
    expect(await countDesignRuleErrors(`export const probe = <path style={{ width: 1 }} />;`, filePath)).toBeGreaterThan(0);
  });

  it("예외: MarkdownText 는 style 만 허용", async () => {
    const filePath = "src/components/MarkdownText.tsx";
    expect(await countDesignRuleErrors(`export const probe = <span style={{ "--i": 1 }} />;`, filePath)).toBe(0);
    expect(await countDesignRuleErrors(`export const probe = <span className="text-[#123456]" />;`, filePath)).toBeGreaterThan(0);
  });
});
