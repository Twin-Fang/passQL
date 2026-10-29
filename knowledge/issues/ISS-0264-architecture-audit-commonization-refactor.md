---
type: issue
id: ISS-0264
created: 2026-10-15
topics: [dev-workflow, design-system]
symptoms: [사본 따로 관리, 수정 누락 반복, 브랜드 색 7곳, "#4F46E5 vs #5856D6", API 타입 수작업, enum 밖 에러 코드 8종, VALIDATION_ERROR, 역방향 의존, 컨트롤러 Repository 직접 사용, 규칙 문서 불일치]
root_cause: "로고·색·에러 코드·API 타입·약관·설정 키·규칙 문서가 스택·플랫폼마다 사본으로 따로 관리돼 한 곳을 고치면 나머지가 빠졌다"
status: resolved
resolution: "[[ISS-0264-architecture-audit-commonization-refactor-report]]"
related: ["[[DEC-0118-single-source-commonization-rules]]", "[[DEC-0119-legal-urls-on-github-pages]]", "[[DEC-0120-pq-prefix-to-passql]]", "[[DEC-0121-unified-brand-color]]", "[[DEC-0122-remove-python-ai-stubs]]", "[[DEC-0123-openapi-contract-single-source]]"]
source: "https://github.com/Twin-Fang/passQL/issues/458"
---

# ISS-0264: 아키텍처 검수 — 같은 대상이 스택마다 사본이라 수정 누락 반복

GitHub #458 (원본: 이슈 본문, 소유자 결정 댓글, 구현·진행 보고 댓글 5개).

## 증상
같은 대상이 스택과 플랫폼마다 사본으로 관리돼 한 곳을 고치면 나머지가 빠진다(GitHub #453 로고 누락). 검수 보고서 `docs/reports/2026-10-15-architecture-audit.md` 기준:
- 운영 관리자 화면과 OG 이미지에 옛 흰 배경 로고
- 브랜드 색 정의 7곳 이상, 웹 #4F46E5 / 앱 #5856D6
- API 타입을 세 스택이 각자 손으로 작성
- 서버가 enum 밖 에러 코드 8종을 내고 앱은 그중 `VALIDATION_ERROR`를 모름
- 규칙 문서(.claude/rules)가 실제 코드와 다름
- 앱 core가 presentation을 import(역방향), 서버 컨트롤러가 Repository 직접 사용

## 재현 조건
해당 없음 (구조 문제).

## 조사 기록
- 2026-10-15: 4개 스택 검수·보고서 작성, 소유자 결정 5건(브랜드 색·약관 URL·`Pq` 접두사·AI 미구현 3개·안 쓰는 파일 삭제), 묶음별 하위 이슈 GitHub #459~#463.
- 2026-10-15~16: 운영 점검 후속 이슈 27건(#464~#490)을 4차로 통합·배포, 이어 5차(#491 알림함), 버전 1.1.0.
- 2026-10-16: 남은 일(서버 큰 클래스 분리, 웹 페이지 분리, API 계약) 마무리, #492(Gemini 키 암호화)·#493(OpenAPI 타입 생성) 하위 이슈 분리.

## 근본 원인
frontmatter `root_cause`와 같음.
