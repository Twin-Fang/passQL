---
type: issue
id: ISS-0242
created: 2026-10-07
topics: [admin]
symptoms: ["Whitelabel Error Page", "/admin/sandbox", "없는 관리자 주소", "error.html 없음", "프레임워크 정보 노출"]
root_cause: "`templates/error.html`이 없어 Spring 기본 Whitelabel 화면이 나갔다"
status: resolved
resolution: "[[ISS-0242-admin-whitelabel-error-page-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/410"
---

# ISS-0242: 없는 관리자 주소에서 Whitelabel Error Page 노출

GitHub #410 (원본: 이슈 본문과 완료 댓글).

## 증상
관리자 영역에서 없는 주소(예: `/admin/sandbox`)로 가면 Spring 기본 "Whitelabel Error Page"가 그대로 노출된다. 관리자 메뉴로 돌아갈 길이 없고 프레임워크 정보가 드러난다.

## 재현 조건
관리자 로그인 후 `/admin/sandbox` 접속.

## 조사 기록
- 2026-10-07: 해결 방안 — `templates/error.html` 추가, JSON 요청(API)은 기존대로 JSON 응답 유지(Spring Boot가 Accept로 분기).

## 근본 원인
오류 템플릿 부재.
