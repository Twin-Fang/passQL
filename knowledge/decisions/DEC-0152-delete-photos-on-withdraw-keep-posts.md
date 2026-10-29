---
type: decision
id: DEC-0152
created: 2026-10-18
reviewed: null
topics: [community, auth-member]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0323-question-opinion-community]]", "[[ISS-0323-question-opinion-community-report]]"]
---

# DEC-0152: 탈퇴 시 커뮤니티 글은 닉네임 익명화로 남기고, 사진은 저장소에서 지운다

## 문제 정의 (Context)
커뮤니티 글과 사진이 생기면서 탈퇴 회원의 게시물 처리 기준이 필요했다 (GitHub #525).

## 결정 (Decision)
탈퇴 시 글은 닉네임 익명화로 남기고, 개인정보가 담길 수 있는 사진은 저장소에서 삭제한다. 개인정보처리방침·이용약관에 익명화·삭제 기준을 넣었다.

## 검토한 대안 (Alternatives)
논의 기록 없음. 원본 이유: 글은 다른 이용자의 토론 맥락이라 익명화해 두지만, 사진은 개인정보 위험이 커서 남기지 않는다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
서버 탈퇴 흐름, 커뮤니티 이미지 객체, 약관. 탈퇴 시 닉네임 익명화·소프트 삭제를 정한 기존 결정 DEC-0095와 같은 방향.

## 출처 (References)
- GitHub #525 개요 댓글 "왜 이렇게 했는가", 머지·배포 댓글 (2026-10-18)
- [[ISS-0323-question-opinion-community]]
