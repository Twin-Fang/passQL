---
type: issue
id: ISS-0467
created: 2026-11-07
topics: [ops-infra, security, practice, ai, admin]
symptoms: ["AI 코멘트 남의 세션 LLM 호출", "AI 코멘트 요청 제한 없음", "OSIV 켜짐", "외부 호출 중 DB 커넥션 점유", "커넥션 풀 고갈", "X-Forwarded-For 맨 앞 값", "설정 캐시 TTL 없음", "커밋 전 캐시 쓰기", "예외 원문 응답 노출", "Map 요청 본문 500", "내린 보기 묶음 채점", "비활성 문제 열림", "무료 제출 샌드박스 실행", "재색인 읽기 전용 트랜잭션", "개념 진행 저장 잠금 없음", "선택지 정책 목록 누락", "ZoneId 사본", AiCommentService, MemberApiRateLimitRule, AppSettingService, GlobalExceptionHandler, SubmissionService, ChoiceSetResolver, QuestionVectorIndexService]
root_cause: "OSIV 기본값이 켜져 있어 트랜잭션 분리(#497)가 무력했고, AI 코멘트·보기 묶음·설정 캐시·요청 본문 처리에 소유·상태·커밋 시점·검증 확인이 빠져 있었다"
status: resolved
resolution: "[[ISS-0467-server-audit-llm-limit-osiv-choice-set-cache-report]]"
related: ["[[DEC-0268-server-osiv-off]]", "[[ISS-0302-app-server-web-performance]]", "[[ISS-0464-admin-prompt-key-single-source]]", "[[ISS-0458-server-side-free-limit-pro-gating]]", "[[ISS-0468-web-audit-cross-tab-reissue-logout]]"]
source: "_sources/issues/ISS-0467-server-audit-llm-limit-osiv-choice-set-cache.md"
---

# ISS-0467: 서버 전체 점검 수정 — LLM 호출 제한, DB 커넥션 점유, 내린 보기 묶음 채점, 설정 캐시, 예외 원문 노출

GitHub #879 (https://github.com/Twin-Fang/passQL/issues/879). 2026-11-07 서버 전체 점검(읽기 전용)에서 원본을 열어 확인. 공개 레포라 우회 재현 절차는 적지 않는다.

## 증상
- (high) AI 코멘트 API가 없는 세션·다른 회원의 세션이어도 LLM 을 부르고 캐시하며 요청 제한이 없음 (`AiCommentService`, `MemberApiRateLimitRule`). 결제가 꺼진 동안은 전원이 프로라 누구나 비용을 일으킬 수 있음.
- (high, 조건부) Open-Session-In-View 기본값(켜짐) — LLM·샌드박스 호출 동안 DB 커넥션을 쥐어 #497 트랜잭션 분리([[ISS-0302-app-server-web-performance]])가 무력. 동시 요청 몇 건으로 풀 고갈 가능.
- (med, 조건부) 요청 제한 키가 X-Forwarded-For 맨 앞 값 > 프록시 동작에 따라 로그인·재발급 IP 제한이 약해질 수 있음.
- (med) 설정 캐시(Redis) TTL 없음, 커밋 전에 캐시를 먼저 씀 (`AppSettingService`) > 롤백 시 캐시에만 새 값, 마이그레이션 값 변경 미반영.
- (med) 예외 원문을 응답에 넣음 (`GlobalExceptionHandler`) > 내부 클래스 이름이 화면에 보임.
- (med) 요청 본문을 `Map` 으로 받아 필드가 빠지면 500 (`AiController`, `QuestionController`).
- (med) 비활성 문제·내린 보기 묶음(DISABLED·REPORTED)도 열리고 채점됨 (`QuestionService`, `SubmissionService`).
- (low-med) 무료 회원 제출도 샌드박스를 실행한 뒤 결과를 버림, 재색인이 읽기 전용 트랜잭션 안에서 AI 를 순차 호출, 개념 진행 저장에 잠금 없음.
- 관리자(#875 후속, [[ISS-0464-admin-prompt-key-single-source]]와 같은 유형): 문제 등록 선택지 정책 목록에 `CURATED_ONLY`·`RESULT_MATCH` 없음(JSON 불러오기 시 `AI_ONLY` 로 바뀔 수 있음), 설정 카테고리 필터 누락.
- 정리: `ZoneId.of("Asia/Seoul")` 사본 14곳, UUID 파싱 사본 5곳, 죽은 코드(`evictCache` 등), server/CLAUDE.md 와 실제가 어긋난 문장.

## 재현 조건
각 항목의 서버 코드 경로를 열어 확인 (점검 기록). 이전 감사(2026-11-02)에서 예외 원문·Map 본문이 미해결로 남아 있었다.

## 조사 기록
- 2026-11-07: 서버 전체 점검(내부)에서 발견, 같은 날 PR #892 로 수정.

## 근본 원인
OSIV 기본값(켜짐)을 명시적으로 끄지 않아 서비스 계층의 트랜잭션 분리와 무관하게 요청 내내 커넥션이 묶였다. AI 코멘트는 세션 소유를, 문제·채점 경로는 보기 묶음 상태를, 설정 캐시는 커밋 시점을, 컨트롤러는 요청 본문 검증을 확인하지 않았다.
