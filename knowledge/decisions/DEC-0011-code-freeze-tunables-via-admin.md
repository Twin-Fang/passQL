---
type: decision
id: DEC-0011
created: 2026-04-06
reviewed: null
topics: [admin, dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0007-sqld-platform-prd-document]]", "[[ISS-0010-five-day-dev-roadmap]]"]
---

# DEC-0011: 코드 프리즈 이후 모든 가변 설정·콘텐츠 변경은 DB/관리자 UI(`app_setting`) 경유

## 문제 정의 (Context)
GitHub #2(PRD 작성)는 "코드 프리즈 원칙(D+6 이후 코드 수정 금지)"을 전제로 했다. GitHub #7(5일 로드맵)도 같은 원칙을 전제 조건으로 적었다.

## 결정 (Decision)
- 모든 가변 설정은 DB/관리자 UI 경유임을 명세에 명시한다 (#2).
- 모든 튜닝/콘텐츠 변경은 어드민 UI(Thymeleaf) 또는 DB에서 수행하고, 튜닝 파라미터는 `app_setting` 경유로 통일한다 (#7). 코드 프리즈 직전 점검 항목에 "모든 tunable이 `app_setting` 경유 (yml 하드코딩 없음)"이 있다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- #7: 코드 프리즈 이후 어드민 UI를 통한 콘텐츠 운영이 가능하다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`app_setting` 테이블과 `AppSettingService`, 관리자 설정 화면(`/admin/settings`), 프롬프트 템플릿 관리(`/admin/prompts`).

## 출처 (References)
- GitHub #2 이슈 본문 「해결 방안」, GitHub #7 이슈 본문 「전제 조건」·「D6」
- [[ISS-0007-sqld-platform-prd-document]], [[ISS-0010-five-day-dev-roadmap]]
