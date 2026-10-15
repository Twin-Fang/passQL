# passQL Client

## Tech Stack

- Vite + React 19 + TypeScript
- Tailwind CSS 4 + daisyUI 5
- Zustand (상태관리), fetch 래퍼 (API 클라이언트)
- React Router DOM (라우팅)

## Project Structure

- `src/api/` — API 클라이언트 및 엔드포인트 모듈
- `src/stores/` — Zustand 스토어
- `src/pages/` — 페이지 컴포넌트
- `src/components/` — 공용 컴포넌트
- `src/types/` — TypeScript 타입 정의
- `docs/` — 로컬 전용 기획 문서(.gitignore, 레포에 올리지 않음)

## Local Skills (`.agents/skills/`)

아래 스킬들을 작업 시 적극 참조할 것.

### vercel-react-best-practices

React 성능 최적화 69개 룰. 컴포넌트 작성, 리팩토링, 코드리뷰 시 반드시 참조.

- 우선순위: async(워터폴 제거) > bundle(번들 최적화) > server > client > rerender > rendering > js > advanced
- 개별 룰: `.agents/skills/vercel-react-best-practices/rules/` 하위 파일 참조

### frontend-design

프론트엔드 UI 구현 시 디자인 품질 가이드. 새 페이지/컴포넌트 작성 시 참조.

- 제네릭한 AI 스타일(Inter, 보라색 그라데이션 등) 금지
- Typography, Color, Motion, Spatial Composition 등 의도적 디자인 선택

## 금지 규칙

- **`git push` 절대 금지** — 어떤 상황에서도 원격에 push하지 않는다
- **커밋 시 Co-Authored-By 태그 금지** — 커밋 메시지에 절대 추가하지 않는다
- **파일 삭제 시 반드시 사용자 허락** — 확인 없이 파일을 삭제하지 않는다
- **모르면 모른다고 말하기** — 확실하지 않은 내용을 추측하지 않는다
- **답변은 항상 한국어로** — 코드/커맨드 제외 모든 응답은 한국어
- **코드 주석 필수** — 실무 수준의 간결한 한국어 주석 작성 (WHY 중심, 과하지 않게)
- **인라인 style 속성 절대 금지** — JSX에서 `style={{ ... }}` 사용 금지. 반드시 Tailwind CSS 유틸리티 클래스 또는 `src/styles/components.css`의 프로젝트 커스텀 클래스를 사용한다
  - **예외**: `MarkdownText.tsx`의 단어 fade-in span에서 CSS custom property(`--i`) 주입 목적으로만 허용. 런타임 동적 값을 CSS에 전달하는 유일한 수단이므로 이 케이스에 한해 인정한다
  - 그 외 런타임 값(진행률·위치·이동량)은 `useCssVariables(ref, { "--이름": 값 })` 훅으로 주입하고 클래스에서 `[width:var(--이름)]`처럼 읽는다. 진행 막대는 `ProgressBar`, 버튼 아래 말풍선은 `AnchoredPopover`
- **색 하드코딩 금지** — hex, `[#...]` 임의 색값, Tailwind 기본 팔레트(`gray-500` 등), `white`/`black` 클래스 금지. `src/styles/tokens.css` 토큰 클래스(`bg-brand`, `text-semantic-error-text` 등)만 쓴다. 필요한 색이 없으면 토큰을 먼저 추가한다
  - 토큰 값 원본은 앱 `app/lib/presentation/design/tokens/pq_colors.dart`의 light 값이다. `theme.css`(daisyUI)는 토큰 var 참조만 둔다
  - `npm run lint`(eslint `no-restricted-syntax`)와 `src/test/designTokens.test.ts`가 강제한다. 예외는 `eslint.config.js`에 이유와 함께 명시한 2건(Google 로고 색, MarkdownText `--i`)뿐이다
- **운영 주소는 `src/constants/siteUrls.ts` 한 곳** — API 기본 주소, 웹 주소(index.html og 태그는 `%PASSQL_SITE_URL%`), 공개 약관(GitHub Pages). 웹 `/legal/*.html`은 `vercel.json` redirects로 GitHub Pages로 이동한다

### web-design-guidelines

UI 코드 리뷰 및 접근성/UX 감사 시 사용.

- 가이드라인 소스: `https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md`
- WebFetch로 최신 룰 가져온 후 파일 대조

### find-skills

새로운 스킬이 필요할 때 `npx skills find [query]`로 검색.

## Rules (`.claude/rules/`)

### api-guide

API 연동 시 반드시 참조. 엔드포인트 스펙, 코드 패턴, 에러 처리 규칙 포함.

- 프론트는 백엔드(Spring)하고만 통신. AI 서버 직접 호출 금지.
- 새 API 추가 시 `apiFetch<T>()` 래퍼 필수, `fetch()` 직접 호출 금지.

## daisyUI 활용 원칙

- **daisyUI 컴포넌트를 최우선으로 사용한다** — 버튼(`btn`), 모달(`modal`), 로딩(`loading`), 배지(`badge`), 인풋(`input`), 카드(`card`) 등 daisyUI에 있는 컴포넌트는 반드시 daisyUI 클래스를 기반으로 구현한다
- Tailwind 유틸리티는 daisyUI로 커버되지 않는 세부 조정(색상, 간격, 크기 등)에만 보조적으로 사용한다
- 버튼을 만들 때 `<button className="btn ...">` 형태가 기본. 순수 Tailwind로 버튼을 처음부터 만들지 않는다

## Icon Policy

- 코드에서 이모지(emoji) 사용 절대 금지. UI 아이콘은 반드시 `lucide-react` 패키지 사용.
- `import { IconName } from "lucide-react"` 형태로 import.

## Git Conventions

모든 커밋 메시지는 아래 형식을 반드시 따른다. 이모지(이모티콘) 사용 금지.

```
{이슈제목} : {type} : {변경사항 설명} {이슈URL}
```

**type 목록**: `feat` / `fix` / `refactor` / `docs` / `chore` / `test` / `style`

**예시**:
```
소셜 로그인 구현 : feat : Google OAuth 연동 추가 https://github.com/Twin-Fang/passQL/issues/274
로그인 페이지 레이아웃 파괴 버그 : fix : tokens.css spacing 변수 충돌 해결 https://github.com/Twin-Fang/passQL/issues/277
```

- 이슈가 없는 경우 이슈 URL 생략 가능
- 이모지(특수기호 포함) 커밋 메시지 사용 금지

## Commands

```bash
npm run dev      # 개발 서버
npm run build    # 프로덕션 빌드 (tsc + vite build)
npm run preview  # 빌드 결과 미리보기
npm run lint     # 디자인 토큰 규칙 (색 하드코딩·인라인 style 차단)
npm test         # vitest (토큰·운영 주소 규칙 테스트 포함)
```
