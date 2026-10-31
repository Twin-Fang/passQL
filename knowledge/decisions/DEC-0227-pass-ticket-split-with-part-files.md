---
type: decision
id: DEC-0227
created: 2026-10-31
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0434-audit-followup-split-large-files]]", "[[ISS-0434-audit-followup-split-large-files-report]]", "[[ISS-0428-app-profile-tab-redesign]]"]
---

# DEC-0227: 앱 탑승권 컴포넌트(`passql_pass_ticket.dart`)는 `part` 파일로 나눠 내부 조각을 private으로 두고 공개 이름·import 경로를 유지한다

## 문제 정의 (Context)
`design/components/passql_pass_ticket.dart`가 650줄 이상, 클래스 9개가 한 파일에 있었다 (GitHub #762).

## 결정 (Decision)
- `pass_ticket/` 폴더의 `part` 파일 4개(본문, 떼는 칸, 효과, 도형)로 나눈다. 본 파일은 667 → 198줄.
- `part`를 쓴 이유(원본): 내부 조각 8개 클래스와 공유 상수를 private 그대로 두기 위해서.
- 공개 클래스 이름과 import 경로가 그대로라 다른 화면은 고치지 않는다.
- 같은 이슈의 `pro_offer_sheet.dart`는 섹션 위젯 파일 6개 + 이용권 계산 순수 클래스(`core/billing/pass_option_pricing.dart`)로 나눴다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 분리 전후 렌더 PNG(라이트·다크)가 픽셀 단위로 같았다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`app/lib/presentation/design/components/passql_pass_ticket.dart`와 `pass_ticket/` part 파일.

## 출처 (References)
- GitHub #762 리포트 댓글 「변경 사항」·「핵심 구현」·「검증」
- [[ISS-0434-audit-followup-split-large-files-report]]
