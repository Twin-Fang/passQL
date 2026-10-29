---
type: decision
id: DEC-0161
created: 2026-10-20
reviewed: null
topics: [admin, ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0344-admin-dashboard-stats-ai-cost]]", "[[ISS-0344-admin-dashboard-stats-ai-cost-report]]"]
---

# DEC-0161: 방문자는 회원당 시간당 1행(`member_activity_hour`)으로 기록하고, 접속 중 수는 메모리에서 최근 5분 활동으로 센다

## 문제 정의 (Context)
`member.last_seen_at`은 내 정보 조회 때만 덮어쓰고 이력이 없어 방문자 수·접속 중 수를 알 수 없었다 (GitHub #557).

## 결정 (Decision)
- 방문자 기준: 하루에 1번 이상 인증된 API 요청을 보낸 회원.
- 인증된 `/api/**` 요청을 인터셉터가 받아, 이번 시간 첫 활동일 때만 `member_activity_hour`에 비동기 INSERT(회원당 시간당 1행, 400일 보관).
- 접속 중 수는 메모리의 마지막 활동 시각으로 최근 5분을 센다(단일 인스턴스 전제).
- 활동 기록 대기열이 넘치면 버린다.

## 검토한 대안 (Alternatives)
- `last_seen_at` 재사용: 이력이 없어 쓸 수 없다고 적었다.
- 그 밖은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 요청 지연을 막는다(대기열 초과 시 버리는 이유로 리포트가 적음). DB 쓰기는 회원당 시간당 1회.

**부정**
- 그 시간 방문 1건이 빠질 수 있다.
- 서버 재시작 후 온라인 수는 5분 안에 다시 찬다. 인스턴스를 늘리면 Redis 등 공유 저장소로 옮겨야 한다(리포트 주의사항).
- 과거 방문자는 0(배포 시점부터 쌓임).

## 영향 범위 (Scope)
`MemberActivityInterceptor`, `MemberActivityRecorder`, `MemberActivityHourService`, `MemberActivityCleanupScheduler`, `AsyncConfig`, `WebMvcConfig`, `member_activity_hour` 테이블.

## 출처 (References)
- GitHub #557 리포트 댓글(2026-10-20), 활동 기록 끝에서 끝 검증 댓글(2026-10-21)
- [[ISS-0344-admin-dashboard-stats-ai-cost]]
