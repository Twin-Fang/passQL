---
type: completion-report
id: ISS-0286
created: 2026-10-15
topics: [admin]
status: resolved
resolves: "[[ISS-0286-admin-ui-common-fetch-toast]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/480"
---

# ISS-0286 완료 리포트: `@AdminPage` 메뉴 정보, `admin-fetch.js` 공통 요청·토스트, 템플릿 분리

GitHub #480 구현 보고서 댓글 기준 (3차 통합 main `c46b9e6`, 0.13.0).

## 해결 방법
- 메뉴 정보: 컨트롤러 24곳 반복을 `@AdminPage(menu = AdminMenu.X)` 한 줄로. `AdminPageModelInterceptor`가 모델에 넣음(직접 넣은 값이 있으면 유지).
- `static/js/admin/admin-fetch.js`: CSRF, JSON 요청, 서버 오류 메시지 해석(`AdminApi`), 토스트·새로고침 후 토스트·위험 동작 확인 창(`AdminUi`). `alert()` 약 48곳, `confirm()` 6곳 교체.
- 리다이렉트 후 저장 토스트는 `AdminFlash.TOAST_MESSAGE` 하나.
- 템플릿 분리: 문제 목록 566 > 254줄, 직접 등록 479 > 218, 신고 상세 358 > 106, 회원 상세 328 > 175(`fragments/*`, `static/js/admin/*.js`).
- 프롬프트 저장을 `PromptTemplateSaveRequest`로(활성 체크 해제 시 null 저장 실패도 해결).
- 함께 고친 기존 버그: 문제 직접 등록, AI 생성 저장, 단건 비활성화 폼의 CSRF 토큰 누락 403.
- 검증: 서버 전체 108개 중 107개 통과, 운영 관리자 화면 200·콘솔 오류 0.

## 근본 원인 (확정)
이슈 본문과 같음. CSRF 403은 폼 전송이 토큰을 싣지 않았던 것.

## 재발 방지
새 관리자 화면은 `@AdminPage`와 `admin-fetch.js`를 쓴다(원본의 구성 기준, 별도 규칙 문구는 원본에 없음).

## 교훈
(원본에 없음, 볼트 정리) 관리자 화면 403은 공통 fetch를 거치지 않는 폼 전송·직접 요청인지부터 본다.
