// @vitest-environment node
/// <reference types="node" />
// 디자인 토큰 규칙 테스트 (#462, #517): CSS hex 금지, 미정의 토큰 참조 금지, 앱·brand 색 원본 일치
import { describe, expect, it } from "vitest";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const CLIENT_ROOT = process.cwd();
const SOURCE_ROOT = join(CLIENT_ROOT, "src");
const STYLES_ROOT = join(SOURCE_ROOT, "styles");
// hex 를 둘 수 있는 유일한 CSS (색 원본)
const TOKEN_FILE = join(STYLES_ROOT, "tokens.css");
const THEME_FILE = join(STYLES_ROOT, "theme.css");
// 색 원본 2곳: 앱 색 토큰(light 값), 브랜드 원본 (레포 루트 기준)
const REPOSITORY_ROOT = join(CLIENT_ROOT, "..");
const APP_COLOR_FILE = join(REPOSITORY_ROOT, "app/lib/presentation/design/tokens/passql_colors.dart");
const BRAND_COLOR_FILE = join(REPOSITORY_ROOT, "brand/brand-colors.json");
// 웹 토큰 > 앱 PassqlColors 필드 (불투명 색만, light 값 / inverse 는 앱 dark 값)
const APP_LIGHT_FIELD_BY_WEB_TOKEN: Readonly<Record<string, string>> = {
  "brand": "accent",
  "on-brand": "onAccent",
  "surface": "background",
  "surface-card": "card",
  "text-primary": "label",
  "text-secondary": "secondaryLabel",
  "semantic-success": "correct",
  "semantic-success-text": "correctText",
  "semantic-error": "wrong",
  "semantic-error-text": "wrongText",
  "semantic-warning": "warning",
};
const APP_DARK_FIELD_BY_WEB_TOKEN: Readonly<Record<string, string>> = {
  "surface-inverse": "card",
  "text-inverse": "label",
  "text-inverse-secondary": "secondaryLabel",
};

// Tailwind 내장 특수 색
const BUILT_IN_COLOR_NAMES = new Set(["transparent", "current", "inherit"]);
// 색이 아닌 같은 접두사 유틸리티·프로젝트 글자 클래스 (text-h1 등 typography.css)
const NON_COLOR_UTILITY_NAMES = new Set([
  "xs", "sm", "base", "lg", "xl", "2xl", "3xl", "4xl", "5xl",
  "left", "center", "right", "justify", "start", "end",
  "wrap", "nowrap", "balance", "pretty", "ellipsis", "clip",
  "h1", "h2", "body", "caption", "code", "mono",
  "collapse", "separate", "none", "solid", "dashed", "dotted", "double", "hidden",
]);
// 테두리 방향 (border-t, border-b-0 등)
const BORDER_SIDE_PATTERN = /^[tblrxyse](-\d+)?$/;
// 색 클래스 후보: 접두사-이름(/투명도)
const COLOR_CLASS_PATTERN =
  /(?<![\w-])(?:[a-z-]+:)*(border-[tblrxyse]|bg|text|border|fill|stroke|divide|ring|outline|decoration|placeholder)-([a-z](?:[a-z0-9-]*[a-z0-9])?)(?:\/\d+)?(?![\w-])/g;
const COLOR_VARIABLE_REFERENCE_PATTERN = /var\(--color-([a-z0-9-]+)/g;
// hex 색: 6·8자리, 또는 영문자가 섞인 3·4자리 (#462 같은 이슈 번호 제외)
const HEX_COLOR_PATTERN = /#(?:[0-9a-fA-F]{6}(?:[0-9a-fA-F]{2})?|(?=[0-9]*[a-fA-F])[0-9a-fA-F]{3,4})\b/g;

/** 폴더 > 확장자가 맞는 파일 경로 전체 (테스트 파일 제외) */
function listSourceFiles(directory: string, extensions: readonly string[]): string[] {
  return readdirSync(directory).flatMap((entryName) => {
    const entryPath = join(directory, entryName);
    if (statSync(entryPath).isDirectory()) return listSourceFiles(entryPath, extensions);
    const isTestFile = /\.test\.tsx?$/.test(entryName);
    return extensions.some((extension) => entryName.endsWith(extension)) && !isTestFile ? [entryPath] : [];
  });
}

/** tokens.css·theme.css 의 --color-이름 정의 > 이름 집합 */
function collectDefinedColorNames(): Set<string> {
  const definitionSource = readFileSync(TOKEN_FILE, "utf-8") + readFileSync(THEME_FILE, "utf-8");
  return new Set([...definitionSource.matchAll(/--color-([a-z0-9-]+)\s*:/g)].map((match) => match[1]));
}

/** tokens.css 의 --text-이름 글자 크기 정의 > 이름 집합 (text-micro 등은 색 클래스 아님) */
function collectDefinedFontSizeNames(): Set<string> {
  const tokenSource = readFileSync(TOKEN_FILE, "utf-8");
  return new Set([...tokenSource.matchAll(/--text-([a-z0-9-]+)\s*:/g)].map((match) => match[1]));
}

/** tokens.css --color-이름: #RRGGBB > 대문자 hex (불투명 값만) */
function readWebTokenHex(tokenName: string): string | undefined {
  const tokenSource = readFileSync(TOKEN_FILE, "utf-8");
  return tokenSource.match(new RegExp(`--color-${tokenName}:\\s*(#[0-9a-fA-F]{6});`))?.[1].toUpperCase();
}

/** passql_colors.dart light·dark 블록 > 필드: #RRGGBB (Color(0xAARRGGBB) 에서 불투명 RGB) */
function readAppColorHexByField(paletteName: "light" | "dark"): Record<string, string> {
  const appSource = readFileSync(APP_COLOR_FILE, "utf-8");
  const paletteBlock = appSource.match(new RegExp(`static const ${paletteName} = PassqlColors\\(([\\s\\S]*?)\\);`))?.[1] ?? "";
  return Object.fromEntries(
    [...paletteBlock.matchAll(/(\w+):\s*Color\(0x[0-9a-fA-F]{2}([0-9a-fA-F]{6})\)/g)]
      .map((match) => [match[1], `#${match[2].toUpperCase()}`]),
  );
}

/** 일치 위치 > "파일:줄 일치문자열" */
function toLocation(filePath: string, source: string, index: number, text: string): string {
  const lineNumber = source.slice(0, index).split("\n").length;
  return `${relative(CLIENT_ROOT, filePath)}:${lineNumber} ${text}`;
}

describe("디자인 토큰 규칙", () => {
  const definedColorNames = collectDefinedColorNames();
  const definedFontSizeNames = collectDefinedFontSizeNames();

  it("tokens.css 밖 CSS 에 hex 색이 없다", () => {
    const violations = listSourceFiles(STYLES_ROOT, [".css"])
      .filter((filePath) => filePath !== TOKEN_FILE)
      .flatMap((filePath) => {
        const source = readFileSync(filePath, "utf-8");
        return [...source.matchAll(HEX_COLOR_PATTERN)].map((match) => toLocation(filePath, source, match.index, match[0]));
      });
    expect(violations).toEqual([]);
  });

  it("var(--color-*) 참조는 모두 정의된 토큰이다", () => {
    const violations = listSourceFiles(SOURCE_ROOT, [".css", ".ts", ".tsx"]).flatMap((filePath) => {
      const source = readFileSync(filePath, "utf-8");
      return [...source.matchAll(COLOR_VARIABLE_REFERENCE_PATTERN)]
        .filter((match) => !definedColorNames.has(match[1]))
        .map((match) => toLocation(filePath, source, match.index, match[0]));
    });
    expect(violations).toEqual([]);
  });

  it("화면 코드의 색 클래스(bg-·text-·border- 등)는 모두 정의된 토큰이다", () => {
    const violations = listSourceFiles(SOURCE_ROOT, [".ts", ".tsx"]).flatMap((filePath) => {
      const source = readFileSync(filePath, "utf-8");
      return [...source.matchAll(COLOR_CLASS_PATTERN)]
        .filter((match) => {
          const colorName = match[2];
          const isKnownName = definedColorNames.has(colorName)
            || BUILT_IN_COLOR_NAMES.has(colorName)
            || NON_COLOR_UTILITY_NAMES.has(colorName)
            || definedFontSizeNames.has(colorName)
            || BORDER_SIDE_PATTERN.test(colorName);
          return !isKnownName;
        })
        .map((match) => toLocation(filePath, source, match.index, match[0]));
    });
    expect(violations).toEqual([]);
  });

  it("웹 색 토큰은 앱 passql_colors.dart 값과 같다", () => {
    const appLightHexByField = readAppColorHexByField("light");
    const appDarkHexByField = readAppColorHexByField("dark");
    // 필드 이름이 바뀌어 비교가 비는 경우도 실패로 잡음
    const toComparison = (fieldByToken: Readonly<Record<string, string>>, appHexByField: Record<string, string>) =>
      Object.entries(fieldByToken).map(([tokenName, fieldName]) => ({
        tokenName,
        web: readWebTokenHex(tokenName),
        app: appHexByField[fieldName],
      }));
    const comparisons = [
      ...toComparison(APP_LIGHT_FIELD_BY_WEB_TOKEN, appLightHexByField),
      ...toComparison(APP_DARK_FIELD_BY_WEB_TOKEN, appDarkHexByField),
    ];
    const mismatches = comparisons.filter(({ web, app }) => !web || !app || web !== app);
    expect(mismatches).toEqual([]);
  });

  it("브랜드 색은 brand/brand-colors.json accent.light 와 같다", () => {
    const brandColors = JSON.parse(readFileSync(BRAND_COLOR_FILE, "utf-8")) as { accent: { light: string } };
    expect(readWebTokenHex("brand")).toBe(brandColors.accent.light.toUpperCase());
  });
});
