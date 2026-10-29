---
type: decision
id: DEC-0150
created: 2026-10-18
reviewed: null
topics: [community]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0323-question-opinion-community]]", "[[ISS-0323-question-opinion-community-report]]"]
---

# DEC-0150: 커뮤니티 1차는 문제별 의견만 — 자동 닉네임, 신고·차단·관리자 숨김 필수, 풀이 전에는 의견을 볼 수 없다

## 문제 정의 (Context)
수험생끼리 의견을 나눌 곳이 없었고, 이슈 본문은 문제별 의견·자유 게시판·시험 후기를 예로 들었다 (GitHub #525).

## 결정 (Decision)
사용자 선택(2026-10-18) 범위:
- 1차 범위: 문제별 의견(각 문제 아래 짧은 글, 좋아요).
- 작성자 표시: 자동 닉네임(실명·이메일 비노출).
- 필수 포함: 신고, 작성자 차단, 관리자 숨김.
- 풀이 전에는 의견을 볼 수 없다.
- 제외(후속): 대댓글, 이미지, 알림, 자유 게시판, 시험 후기. (이미지는 같은 날 단계 계획에 따라 구현됐다.)
- 저장 구조는 범용 `community_post`(게시판 종류 + 대상)로 두어 다른 게시판은 enum 값 추가로 같은 API·신고·차단·숨김을 쓴다. 새 DB는 늘리지 않는다(기존 PostgreSQL·Redis).

## 검토한 대안 (Alternatives)
- 자유 게시판·시험 후기: 1차에서 제외(후속). 제외 이유는 원본에 없다.
- 그 밖의 논의 기록 없음.

원본 이유: 신고·차단·숨김은 App Store 가이드라인 1.2 UGC 요건. 풀이 전 비공개는 정답 노출 방지(설계 댓글은 풀이 유도도 적음).

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
서버 커뮤니티 API·스키마, 앱·웹 커뮤니티 화면, 관리자 신고 화면.

## 출처 (References)
- GitHub #525 "범위 확정", "설계 확정" 댓글 (2026-10-18)
- [[ISS-0323-question-opinion-community]]
