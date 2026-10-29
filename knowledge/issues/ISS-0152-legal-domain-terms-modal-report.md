---
type: completion-report
id: ISS-0152
created: 2026-04-24
topics: [store-release, auth-member, admin]
status: resolved
resolves: "[[ISS-0152-legal-domain-terms-modal]]"
related: ["[[DEC-0082-legal-table-separate-from-app-setting]]"]
source: "https://github.com/Twin-Fang/passQL/issues/283"
---

# ISS-0152 완료 리포트: `legal` 독립 도메인과 로그인 약관 모달

GitHub #283 구현 완료 리포트(2026-04-24, PR #285)와 구현 보고서(2026-04-25) 기준.

## 해결 방법
- 백엔드: `V0_0_159__add_legal_table.sql` — `type`(TERMS_OF_SERVICE | PRIVACY_POLICY), `title`, `content`(Markdown), `status`(PUBLISHED | DRAFT), 초기 데이터 삽입. PostgreSQL 문법(TIMESTAMP, UUID, ON CONFLICT 멱등성).
- `Legal` 엔티티, `LegalRepository`, `LegalService`(PQL-Domain-Meta). 공개 API `GET /api/meta/legal/{type}`(인증 불필요).
- `AdminLegalController` — `PUT /{type}`(내용), `PUT /{type}/status`(상태). `admin/legal.html`(Markdown textarea, PUBLISHED/DRAFT 토글, CSRF 토큰), 사이드바 "약관 관리".
- 프론트: `src/api/legal.ts` `fetchLegal(type: LegalType)`, `Login.tsx` 약관 링크 → daisyUI 반응형 모달(모바일 하단 시트, 데스크톱 중앙) → `MarkdownText` 렌더링, 로딩·에러 처리.
- 코드 리뷰 반영: `SecurityConfig`의 `/api/meta/**` GET `permitAll()` 누락 수정, `LegalUpdateRequest` `@NotBlank`, `AdminLegalController` `@Valid`.

## 근본 원인 (확정)
약관 전용 도메인 부재.

## 재발 방지
구현 보고서 주의사항: 배포 후 관리자 화면에서 약관을 작성하고 PUBLISHED로 전환해야 모달에 표시된다. 이 화면의 관리자 CSRF 처리는 이후 [[ISS-0001-admin-fetch-csrf-header-missing]]에서 "#283에서 `legal.html`만 고쳤다"로 언급된다.

## 교훈
논의 기록 없음.
