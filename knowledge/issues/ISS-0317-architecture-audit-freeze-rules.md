---
type: issue
id: ISS-0317
created: 2026-10-17
topics: [dev-workflow]
symptoms: [아키텍처 감사, 내부 예외 메시지 노출, "/api/meta/tags 엔티티 반환", 커밋 전 비동기 색인, 손타입 api.ts 불일치, AdMob 로더 중복, SharedPreferences 직접 사용, 동기 Redis]
root_cause: "4개 스택에 규칙 위반이 쌓였고 새 위반을 막는 자동 검사가 없었다"
status: resolved
resolution: "[[ISS-0317-architecture-audit-freeze-rules-report]]"
related: ["[[DEC-0145-frozen-architecture-rule-ledger]]"]
source: "https://github.com/Twin-Fang/passQL/issues/517"
---

# ISS-0317: 아키텍처 감사 후속 — 동결 규칙과 스택별 상위 문제 수정

GitHub #517 (원본: 이슈 본문과 댓글).

## 증상
4개 스택 아키텍처 감사 결과(`docs/architecture/audits/2026-10-18_passQL_4개_스택_아키텍처_감사.md`):
- server: 내부 예외 메시지가 응답 message로 노출(8개 파일), `/api/meta/tags`가 JPA 엔티티(`ConceptTag`, createdBy 포함) 반환, rollback-only 뒤 흐름 계속(`AdminDailyChallengeService`), 커밋 전 비동기 색인(`QuestionGenerateService`), 샌드박스 실행 흐름 6곳 복사, 컨트롤러의 Client 직접 주입 3곳.
- client: `types/api.ts` 손타입 13개가 생성본과 어긋남(규칙 문서 api-guide.md가 원인), 죽은 코드, 저장 키 사본, 임의 px 클래스.
- app: AdMob 로더 3벌 준비 단계 복사, core↔data 순환, SharedPreferences 직접 사용 5곳.
- ai: async 경로의 동기 Redis, 외부 호출 재시도 없음.
- 공통: 규칙 문서의 없는 파일 참조(`pq_colors.dart`), 낡은 숫자.

## 재현 조건
해당 없음 (리팩토링).

## 조사 기록
- 2026-10-17: PR #526 머지, deploy `8c62076f`, 운영 실측.

## 근본 원인
원본에 적혀 있지 않다(감사 결과 나열만 있음).
