// 디자인 토큰 강제 lint (#462): 화면 코드의 색 하드코딩·인라인 style 차단
// 범위: 이 규칙 + 기존 코드가 disable 주석으로 참조하는 react-hooks/exhaustive-deps (일반 스타일 규칙은 미도입)
import tseslint from "typescript-eslint";
import reactHooks from "eslint-plugin-react-hooks";

const TOKEN_GUIDE = "색은 src/styles/tokens.css 토큰 클래스(bg-brand 등)만 사용";

// 색 하드코딩 4종: hex, Tailwind 임의 색값, Tailwind 기본 팔레트, white·black
const HEX_COLOR_PATTERN = String.raw`/#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?\b|^#[0-9a-fA-F]{3,4}$/`;
const ARBITRARY_COLOR_PATTERN = String.raw`/\[(#|rgba?\(|hsla?\(|oklch\()/`;
const PALETTE_COLOR_PATTERN = String.raw`/\b(bg|text|border|ring|fill|stroke|from|via|to|outline|divide|decoration|caret|accent)-(slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-[0-9]{2,3}\b|\b(bg|text|border|fill|stroke)-(white|black)\b/`;

/** 문자열 패턴 > 문자열·템플릿 리터럴 검사 selector 2개 */
function restrictStringPattern(pattern, message) {
  return [
    { selector: `Literal[value=${pattern}]`, message },
    { selector: `TemplateElement[value.raw=${pattern}]`, message },
  ];
}

const HEX_COLOR_RESTRICTIONS = restrictStringPattern(HEX_COLOR_PATTERN, `hex 색 금지. ${TOKEN_GUIDE}`);
const CLASS_COLOR_RESTRICTIONS = [
  ...restrictStringPattern(ARBITRARY_COLOR_PATTERN, `Tailwind 임의 색값([#...]) 금지. ${TOKEN_GUIDE}`),
  ...restrictStringPattern(PALETTE_COLOR_PATTERN, `Tailwind 기본 팔레트 색 금지. ${TOKEN_GUIDE}`),
];
const INLINE_STYLE_RESTRICTION = {
  selector: "JSXAttribute[name.name='style']",
  message: "인라인 style 금지. 토큰 클래스 또는 useCssVariables(런타임 값) 사용",
};

export default tseslint.config(
  { ignores: ["dist/**", "node_modules/**", "coverage/**"] },
  {
    files: ["src/**/*.{ts,tsx}"],
    languageOptions: { parser: tseslint.parser },
    linterOptions: { reportUnusedDisableDirectives: "warn" },
    plugins: { "react-hooks": reactHooks },
    rules: {
      "react-hooks/exhaustive-deps": "warn",
      "no-restricted-syntax": ["error", ...HEX_COLOR_RESTRICTIONS, ...CLASS_COLOR_RESTRICTIONS, INLINE_STYLE_RESTRICTION],
    },
  },
  {
    // 규칙 검증 테스트: 위반 예시 문자열을 일부러 담음 > 화면 코드가 아니라 제외
    files: ["src/test/designLintRules.test.ts"],
    rules: { "no-restricted-syntax": "off" },
  },
  // 허용 예외 2건 (그 외 예외 추가 금지)
  {
    // Google 로고: 제공사 지정 4색이라 토큰 대상 아님 > hex 만 허용
    files: ["src/components/SocialLoginIcons.tsx"],
    rules: {
      "no-restricted-syntax": ["error", ...CLASS_COLOR_RESTRICTIONS, INLINE_STYLE_RESTRICTION],
    },
  },
  {
    // 단어 fade-in: 단어마다 순번 --i 주입, 단어 수만큼 ref 를 둘 수 없음 > style 만 허용 (client/CLAUDE.md 예외)
    files: ["src/components/MarkdownText.tsx"],
    rules: {
      "no-restricted-syntax": ["error", ...HEX_COLOR_RESTRICTIONS, ...CLASS_COLOR_RESTRICTIONS],
    },
  },
);
