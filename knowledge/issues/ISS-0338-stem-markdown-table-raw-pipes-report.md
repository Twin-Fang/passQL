---
type: completion-report
id: ISS-0338
created: 2026-10-21
topics: [practice]
status: resolved
resolves: "[[ISS-0338-stem-markdown-table-raw-pipes]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/550"
---

# ISS-0338 완료 리포트: 앱은 표 문법만 직접 해석, 웹은 `remark-gfm` 추가

GitHub #550 리포트 댓글(`## 개요`, 2026-10-21) 기준. 커밋 b79c608d, v1.27.0.

## 해결 방법
- 앱: `stem_markdown_table.dart`가 지문 글을 `String`/`StemMarkdownTable` 순서 목록으로 나눈다(머리 줄 + `| --- |` 구분 줄이 있어야 표로 인정). `stem_text.dart`는 표 조각을 `ResultRowsTable.positional`로, 나머지는 기존 인라인 코드 글로 그린다. 앱에 마크다운 패키지를 새로 넣지 않았다(지문은 표·코드 펜스·인라인 코드 외 문법을 쓰지 않는다).
- 웹: `client/package.json`에 `remark-gfm` 추가, `MarkdownText.tsx`에서 `table`은 가로 스크롤 + `data-table`, `td` 글자가 `NULL`이면 NULL 표시.
- 표 안의 `NULL`은 null로 바꿔 GitHub #549와 같은 NULL 표기로 그린다.

## 근본 원인 (확정)
앱은 코드 펜스만 처리하고 웹은 GFM 표 확장이 없었다.

## 재발 방지
- 테스트: 앱 `stem_text_test`(파이프·구분 줄 미노출, NULL 칸), 웹 `MarkdownText.test.tsx`. iOS 시뮬레이터로 2026-10-21 오늘의 세트 1번(`SALES_Q`), 2번(7행 `EMP`) 확인. 웹 화면 실측은 로그인 제약으로 미실시.
- 구분 줄이 없는 파이프 글은 표로 보지 않는다(일반 `|` 문자 오인 방지).
- `package-lock.json` 루트 버전 줄은 CI 관리값이라 npm이 바꾼 값을 되돌려 두었다.
- 목록 미리보기(오답 노트 등)는 여전히 `[EMP] |...`처럼 파이프가 보인다 — 후속 GitHub #566.

## 교훈
(원본에 없음, 볼트 정리) 지문에 새 마크다운 문법이 들어가기 시작하면 앱·웹 렌더러와 목록 미리보기까지 함께 확인한다.
