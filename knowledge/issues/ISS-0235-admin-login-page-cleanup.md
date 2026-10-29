---
type: issue
id: ISS-0235
created: 2026-10-07
topics: [admin]
symptoms: ["관리자 로그인 모바일 여백 0", "로그인 실패 후 아이디 지워짐", "_csrf hidden input 두 번", "lucide@latest", "외부 스크립트 버전 미고정"]
root_cause: "`th:action` 자동 삽입과 수동 삽입이 겹쳐 `_csrf`가 두 번 렌더링됐고, 관리자 화면이 `lucide@latest`를 불러왔다 (나머지는 원본에 원인 없음)"
status: resolved
resolution: "[[ISS-0235-admin-login-page-cleanup-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/402"
---

# ISS-0235: 관리자 로그인 화면 정비 (모바일 여백·아이디 유지·중복 CSRF·외부 스크립트 버전 고정)

GitHub #402 (원본: 이슈 본문과 완료 댓글).

## 증상
- 폭 375에서 로그인 카드 좌우 여백 0.
- 로그인 실패 후 입력한 아이디가 지워짐.
- `_csrf` hidden input이 두 번 렌더링(`th:action` 자동 삽입 + 수동 삽입).
- 관리자 화면 전체가 `lucide@latest`(버전 미고정)를 불러와 외부 갱신 시 아이콘이 깨질 수 있음.

## 재현 조건
해당 없음 (기능 개선). 폭 375에서 관리자 로그인 화면.

## 조사 기록
- 2026-10-07: 대상 `templates/admin/login.html`, `templates/admin/layout.html`, `AdminLoginController`. 후속 제안(운영용 빌드 CSS 전환, `question-new`/`question-register`/미사용 `question-form` 정리)은 화면 구조 변경이라 별도 승인 후 진행으로 남김.

## 근본 원인
증상 목록에 적힌 것 외에는 원본에 적혀 있지 않다.
