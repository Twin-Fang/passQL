---
type: issue
id: ISS-0266
created: 2026-10-15
topics: [dev-workflow]
symptoms: [GlobalExceptionHandler, enum 밖 문자열 에러 코드, ErrorCode, SSE 오류 형식, 컨트롤러 Repository 직접 사용, 설정 키 리터럴, ArchUnit]
root_cause: "서버 오류 응답이 문자열 코드·직접 만든 Map·ErrorCode enum으로 섞여 앱·웹이 같은 오류를 다르게 해석했고, 계층·설정 키 규칙이 강제되지 않았다"
status: resolved
resolution: "[[ISS-0266-server-error-code-unify-archunit-report]]"
related: ["[[DEC-0118-single-source-commonization-rules]]", "[[ISS-0264-architecture-audit-commonization-refactor]]"]
source: "https://github.com/Twin-Fang/passQL/issues/460"
---

# ISS-0266: 서버 에러 코드가 enum 밖 문자열로 섞이고 컨트롤러가 Repository를 직접 씀

GitHub #460 (원본: 이슈 본문과 구현 보고서). 상위 GitHub #458.

## 증상
- `GlobalExceptionHandler`가 enum 밖 문자열 코드 8종을 낸다. SSE·관리자 응답 형식이 제각각.
- 컨트롤러가 Repository를 직접 쓴다. 설정 키 리터럴이 흩어져 있다.
- enum 파싱, 페이지 처리, 미리보기 길이가 곳마다 다르다.
- 안 쓰는 템플릿과 레거시 quiz 화면이 남아 있다.

## 재현 조건
해당 없음 (구조 문제).

## 조사 기록
- 2026-10-15: 기준 — 상위 #458, 동작은 바꾸지 않고 구조만.

## 근본 원인
frontmatter `root_cause`와 같음. (참고: 볼트의 `DEC-0013`은 `CustomException` + 중앙 `ErrorCode` 단일 패턴을 이미 정해 두었다 — 원본은 이를 언급하지 않는다.)
