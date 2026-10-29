---
type: issue
id: ISS-0009
created: 2026-04-07
topics: [auth-member]
symptoms: ["member 도메인 없음", member_uuid, 닉네임, PQL-Domain-Member, "익명 사용자", suh-random-engine]
root_cause: "PRD 데이터 모델과 멀티모듈 구조에 사용자 식별 주체인 member 도메인이 없었다 (기능 이슈)"
status: resolved
resolution: "[[ISS-0009-member-domain-module-entity-report]]"
related: ["[[DEC-0012-nickname-via-suh-random-engine]]", "[[DEC-0013-single-custom-exception-error-code]]", "[[DEC-0014-explicit-soft-delete-filter]]"]
source: "https://github.com/Twin-Fang/passQL/issues/6"
---

# ISS-0009: Member 도메인 모듈 신규 생성 및 확장 가능한 Entity 설계

GitHub #6 (원본: 이슈 본문과 댓글).

## 증상
- PRD 데이터 모델에는 `submission`, `execution_log` 같은 활동 테이블만 있고 `member` 도메인이 없었다.
- 로그인 없이 동작하지만 사용자별 진도·제출 이력을 추적하려면 백엔드가 발급한 `member_uuid`와 닉네임이 필요했다.
- 멀티모듈(`PQL-Domain-Meta`, `PQL-Domain-Question`, `PQL-Domain-Submission`, `PQL-Domain-AI`)에 Member가 없어 다른 도메인이 회원을 참조할 때 의존성이 꼬일 수 있었다.
- 익명 사용자 전제이지만 SNS 로그인·계정 연동·관리자 권한 확장 여지가 필요했다.
제안: `PQL-Domain-Member` 신설, 확장 컬럼(인증 수단·권한·상태·탈퇴·행동 추적) 선반영, 닉네임은 `me.suhsaechan:suh-random-engine:1.1.0`의 `SuhRandomKit`으로 생성. API 3종(`POST /api/members/register`, `GET /api/members/me?memberUuid=`, `POST /api/members/me/regenerate-nickname`). 범위 외: OAuth 실연동, 어드민 권한 API, 탈퇴 API·개인정보 파기 정책.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-07: 닉네임 랜덤엔진 라이브러리 저장소 공유.
- 2026-04-07: `## 개요` 리포트 댓글 (아래 리포트).

## 근본 원인
해당 없음 (기능 이슈).
