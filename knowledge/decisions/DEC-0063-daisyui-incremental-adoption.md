---
type: decision
id: DEC-0063
created: 2026-04-12
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0092-home-daisyui-pilot]]", "[[ISS-0092-home-daisyui-pilot-report]]"]
---

# DEC-0063: daisyUI 클래스는 Home.tsx 파일럿부터 1:1 대체 가능한 요소만 순차 적용하고 passQL 전용 클래스는 유지

## 문제 정의 (Context)
daisyUI 5와 passql 테마가 있는데 컴포넌트가 수동 커스텀 클래스만 써 유지보수 부담이 있었다 (GitHub #167).

## 결정 (Decision)
- Home.tsx를 파일럿으로 카드·버튼·스켈레톤·뱃지를 daisyUI 클래스로 교체하고, 다른 페이지는 후속 이슈에서 순차 적용한다.
- daisyUI 대체 대상에서 제외: `badge-topic`(daisyUI 기본 variant와 시각 구분 필요), 시맨틱 카드 `error-card`·`modal-card`(좌측 4px border 구조를 daisyUI card로 표현 불가), typography 클래스(`text-heading` 등).
- daisyUI base scale을 디자인 시스템 Surface 계층에 매핑: `base-200` `#FAFAFA` 페이지, `base-100` `#FFFFFF` 카드, `base-300` `#E5E7EB` 테두리.

## 검토한 대안 (Alternatives)
논의 기록 없음. (전면 일괄 교체 여부를 비교한 기록은 없고, 작업 범위를 Home.tsx로 한정했다고만 적었다.)

## 결과 (Consequences)
**긍정**
- daisyUI 클래스가 passql 테마 변수(`--radius-box`, `--color-primary` 등)를 자동 참조해 클래스가 줄어든다(작업 댓글).

**부정**
- 전환 후 `badge-topic` 색 오염, 카드 배경 fallback 등 시각 회귀가 생겨 추가 수정이 필요했다.
- daisyUI `card` 기본 `overflow-hidden`으로 내부 요소 clipping 확인 필요.

## 영향 범위 (Scope)
`src/styles/theme.css`, `src/pages/Home.tsx`, `components.css`의 기존 커스텀 클래스(`card-base` 등), 이후 다른 페이지.

## 출처 (References)
- GitHub #167 이슈 본문과 작업 댓글 (2026-04-12)
- [[ISS-0092-home-daisyui-pilot]]
