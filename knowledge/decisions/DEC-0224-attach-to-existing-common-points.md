---
type: decision
id: DEC-0224
created: 2026-10-31
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0433-second-architecture-audit-followup]]", "[[ISS-0433-second-architecture-audit-followup-report]]", "[[DEC-0118-single-source-commonization-rules]]"]
---

# DEC-0224: 사본 정리는 새 공통 지점을 만들기보다 기존 공통 위치에 붙이고, 호출부 동작이 다른 곳은 대상에서 뺀다

## 문제 정의 (Context)
2차 감사(GitHub #759)에서 남은 문제 대부분은 공통 지점이 이미 있는데도 쓰지 않고 따로 만든 사본이었다.

## 결정 (Decision)
- 공통 지점은 기존 위치에 붙인다: UUID 파싱은 기존 `UuidUtils`(`parseOrEmpty`), 다크 판정은 기존 `PassqlThemeContext`, 오류 보고는 기존 `crash_reporter`(`reportIfUnexpectedFailure`).
- 호출부 사정에 따라 일부는 그대로 둔다: UUID 파싱 7곳 중 공백 정리를 이미 마친 호출부만 바꾸고, 형식 오류일 때 예외를 던져야 하는 `MemberNotificationQueryService.parseUuid`는 뺐다.
- 기존 동작은 바꾸지 않는다: `getBooleanOrDefault`는 형식이 틀린 값을 지금처럼 `false`로 처리하고 경고 로그만 더한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
서버 `UuidUtils`와 호출부, `AppSettingService`; 앱 `passql_theme.dart`·`crash_reporter`와 catch 7곳.

## 출처 (References)
- GitHub #759 리포트 댓글 「핵심 구현」
- [[ISS-0433-second-architecture-audit-followup-report]]
