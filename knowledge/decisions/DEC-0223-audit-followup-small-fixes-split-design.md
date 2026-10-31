---
type: decision
id: DEC-0223
created: 2026-10-31
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0433-second-architecture-audit-followup]]", "[[ISS-0433-second-architecture-audit-followup-report]]", "[[ISS-0434-audit-followup-split-large-files]]", "[[DEC-0118-single-source-commonization-rules]]", "[[DEC-0145-frozen-architecture-rule-ledger]]"]
---

# DEC-0223: 감사 후속은 동작을 바꾸지 않는 작은 수정만 그 이슈에서 처리하고, 설계가 필요한 항목은 후속 이슈로, 제품 결정이 필요한 항목은 사용자 확인으로 나눈다

## 문제 정의 (Context)
2차 아키텍처 감사(GitHub #759)에서 스캐너 수치를 소스로 확인한 뒤, 오류 보고 누락·사본·큰 파일·제품 동작 차이가 함께 나왔다.

## 결정 (Decision)
- 찾은 항목을 수정 규모로 나눈다: 작음·동작 그대로 → 그 이슈(#759)에서 반영 / 설계 필요 → 후속 이슈(#762) / 제품 결정 필요 → 사용자 확인.
- 반영한 작은 수정은 규칙 테스트·계약 테스트·CI로 확인한다.
- 이번에 후속으로 넘긴 것: `pro_offer_sheet.dart`·`passql_pass_ticket.dart` 분리, 서버 Oracle 변환 3벌·선택지 생성 재시도 루프 3벌 통합, `components.css` 분할. 사용자 확인으로 넘긴 것: 웹 제출 실패 시 연습(오답 기록)과 데일리·추천(홈 이동) 처리 차이.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음. (원본: 후속 이슈 #762가 같은 날 "동작은 그대로, 구조만 변경"으로 처리됐다.)

**부정**
- 웹 제출 실패 처리 차이는 #762에서도 범위에서 빠져 리포트 시점까지 미결로 남았다.

## 영향 범위 (Scope)
감사 후속 작업 방식(4개 스택). 점검 보고서 `docs/architecture/audits/2026-10-29_passQL_2차_아키텍처_감사.md`.

## 출처 (References)
- GitHub #759 이슈 본문 「해결 방안」, 리포트 댓글 흐름도와 주의사항
- [[ISS-0433-second-architecture-audit-followup]]
