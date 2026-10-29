---
type: issue
id: ISS-0025
created: 2026-04-08
topics: [admin, auth-member]
symptoms: ["회원 관리 페이지 없음", "/admin/members", 제재, 정지, suspend_until, member_suspend_history]
root_cause: "관리자 페이지에 회원 관리 기능이 없어 회원 현황 파악·제재·해제를 할 수 없었다 (기능 이슈)"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/33"
---

# ISS-0025: 관리자 회원 관리 페이지

GitHub #33 (원본: 이슈 본문. 댓글 없음).

## 증상
관리자 페이지에 회원 관리가 없어 회원 현황 파악, 상태별(탈퇴·정지) 조회, 제재·해제를 직접 처리할 수 없었다.
제안: `/admin/members` 목록(닉네임 검색, 상태 `ACTIVE/DORMANT/SUSPENDED/WITHDRAWN`·역할 필터, 가입일·마지막 접속일 범위, 테스트 계정 포함/제외, 페이지네이션), `/admin/members/{memberUuid}` 상세(기본 정보, 사유+기간 제재 모달/해제, 제재 이력, 제출 이력, 일일 챌린지 참여). 기간 제재 자동 해제: `@Scheduled(fixedDelay = 60_000)` 1분 배치 + 접속(`getMe`) 시 `suspend_until` 체크.
작업 항목: `member.suspend_until DATETIME(6)`, `member_suspend_history` 테이블, `MemberSuspendHistory` 엔티티, `SuspendAction`(SUSPENDED / UNSUSPENDED), `MemberAdminService`, `AdminMemberController`, `admin/members/list.html`·`detail.html`, `V0_0_24__add_member_suspend.sql`, 사이드바 메뉴.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 댓글 없음. 완료 내용은 원본에 없다.

## 근본 원인
해당 없음 (기능 이슈).
