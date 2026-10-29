---
type: decision
id: DEC-0173
created: 2026-10-24
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0363-app-wide-ui-ux-cleanup]]", "[[ISS-0363-app-wide-ui-ux-cleanup-report]]"]
---

# DEC-0173: (사용자 지시) 테스트 코드는 저장소에 새로 올리지 않고, 변경으로 깨진 옛 테스트만 정리한다

## 문제 정의 (Context)
GitHub #602 UI/UX 정리 중 문구·구조가 바뀌어 옛 테스트가 깨졌다. 진행 댓글에 "테스트 정책 (사용자 지시)"로 적혔다.

## 결정 (Decision)
- 테스트 코드는 저장소에 새로 올리지 않는다.
- 이번 변경으로 문구·구조가 달라져 깨진 옛 테스트만 삭제한다(예: `report_flow_test.dart` 전체, `app_shell_test.dart` 전체, 순위 보기 2건, MY 제목 1건, 닉네임 재생성 2건, 화면 모드 시트 1건).
- 변경 영역 관련 테스트 파일만 골라 실행한다. 레이아웃 검사 같은 확인용 검사는 임시 파일로 돌리고 저장소에 올리지 않는다.
- 리포트: "낡은 테스트를 정리해 전체를 10개 미만 수준으로 유지했습니다." 아키텍처 규칙 테스트(`design_system_rules_test` 포함)는 통과 대상으로 남는다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 1차 CI에서 옛 테스트 5건이 깨져 정리 후 재통과했다.
- 적용 범위가 이 이슈 한정인지 앱 전체 정책인지 원본에 적혀 있지 않다. 같은 날 GitHub #609는 "탭 화면 테스트 40개 통과"를 적었다. "10개 미만"의 단위(파일 수인지 건수인지)도 원본에 없다.

## 영향 범위 (Scope)
`app/test/` (앱 테스트). 서버·웹 적용 여부는 원본에 없음.

## 출처 (References)
- GitHub #602 진행 댓글 「테스트 정책 (사용자 지시)」, 리포트 댓글(2026-10-24)
- [[ISS-0363-app-wide-ui-ux-cleanup]]
