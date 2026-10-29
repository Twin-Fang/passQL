---
type: issue
id: ISS-0286
created: 2026-10-15
topics: [admin]
symptoms: [pageTitle currentMenu 반복, "fetch 후 alert()", 공통 토스트 없음, 저장 성공 피드백 없음, 약관 게시 확인 창 없음, 300줄 넘는 템플릿, "@ModelAttribute 엔티티 직접 바인딩"]
root_cause: "관리자 화면마다 메뉴 정보·fetch·알림 처리를 각자 구현해 반복과 피드백 누락이 생겼다"
status: resolved
resolution: "[[ISS-0286-admin-ui-common-fetch-toast-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/480"
---

# ISS-0286: 관리자 화면 반복 코드와 저장/전환 피드백 부재

GitHub #480 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- `pageTitle`, `currentMenu`를 컨트롤러 24곳에서 반복.
- fetch 후 `alert()` 패턴이 12개 파일 24곳, 공통 토스트 없음.
- 설정 저장 성공 피드백 없음, 약관 게시 상태 전환에 확인 창 없음.
- 300줄 넘는 템플릿: `questions.html`(568), `question-register.html`(479), `report-detail.html`(362), `members/detail.html`(328).
- 프롬프트 저장이 엔티티를 `@ModelAttribute`로 직접 바인딩.
- 위치: `templates/admin/settings.html:199`, `legal.html:119`, `AdminPromptController.java:46,52`.

## 재현 조건
해당 없음(기능 개선).

## 조사 기록
- 2026-10-15: 구현 중 기존 버그 발견 — 문제 직접 등록, AI 생성 저장, 단건 비활성화 폼이 CSRF 토큰 없이 전송돼 403. 프롬프트 활성 체크 해제 시 null로 저장 실패.

## 근본 원인
frontmatter `root_cause`와 같음.
