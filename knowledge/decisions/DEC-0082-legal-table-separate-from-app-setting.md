---
type: decision
id: DEC-0082
created: 2026-04-24
reviewed: null
topics: [store-release, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0152-legal-domain-terms-modal]]", "[[ISS-0152-legal-domain-terms-modal-report]]"]
---

# DEC-0082: 약관(이용약관·개인정보처리방침)은 `AppSetting`이 아닌 독립 `legal` 테이블에서 관리한다

## 문제 정의 (Context)
약관 콘텐츠가 `AppSetting` key-value에 저장돼 시스템 설정과 도메인이 혼재했고, 로그인 화면에서는 약관을 볼 수 없었다(GitHub #283).

## 결정 (Decision)
약관은 독립 `legal` 테이블(`type` TERMS_OF_SERVICE | PRIVACY_POLICY, `title`, Markdown `content`, `status` PUBLISHED | DRAFT)로 분리하고, 관리자 화면에서 편집·게시한다. 앱은 공개 API `GET /api/meta/legal/{type}`(인증 불필요)로 조회한다.

## 검토한 대안 (Alternatives)
- `AppSetting` key-value에 두는 기존 방식: 시스템 설정과 도메인이 혼재한다는 이유로 분리(이슈 본문).
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 관리자가 약관을 직접 편집·게시할 수 있다.

**부정**
- 배포 후 관리자가 약관을 작성해 PUBLISHED로 전환해야 모달에 표시된다.

## 영향 범위 (Scope)
`V0_0_159__add_legal_table.sql`, PQL-Domain-Meta `Legal`/`LegalRepository`/`LegalService`, `AdminLegalController`, `admin/legal.html`, `SecurityConfig`(`/api/meta/**` GET permitAll), 클라이언트 `src/api/legal.ts`, `Login.tsx`.

## 출처 (References)
- GitHub #283 이슈 본문, 구현 완료 리포트(2026-04-24, PR #285), 구현 보고서(2026-04-25)
