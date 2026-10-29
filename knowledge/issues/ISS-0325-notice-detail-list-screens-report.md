---
type: completion-report
id: ISS-0325
created: 2026-10-18
topics: [notification]
status: resolved
resolves: "[[ISS-0325-notice-detail-list-screens]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/529"
---

# ISS-0325 완료 리포트: 공지 상세·목록 전체 화면, 게시일 `publishedAt`, 알림함 배지

GitHub #529·#530 공동 보고 댓글 기준 (2026-10-18, PR #534).

## 해결 방법
- 서버: 공지 응답에 `publishedAt`, 지난 공지 목록 API `/api/meta/notices`(페이지네이션), 계약 재생성.
- 앱: 공지 상세(중요 배지, 큰 제목, 게시일, 구분선, 마크다운 본문, "다른 공지 보기"), 공지 목록(중요 먼저, 미리보기 2줄). 홈 공지 배너·알림함·푸시 진입 모두 상세로. 알림함 세그먼트 숫자 배지 한 자리 원형·높이 고정, 선택 탭 배지만 주황.
- 운영 실측: `/api/meta/notices` 200, `publishedAt` 포함.

## 근본 원인 (확정)
이슈 노트 참조.

## 재발 방지
- `keepWordsTogether`는 `MarkdownLiteText` 전체에 적용 — 글자 비교 테스트는 `findTextContainingIgnoringWordJoiners`를 쓴다.
- 숫자 배지는 `PassqlCountBadge(isEmphasized:)` 하나로 통일, 새 배지는 이 컴포넌트를 쓴다.
- 남은 사용자 확인 항목은 GitHub #530 후속 리포트에서 확인됨. 여러 기기 검수는 GitHub #535.

## 교훈
(원본에 없음, 볼트 정리) 단어 결합 문자를 넣는 텍스트 처리를 도입하면 문자열 비교 테스트 헬퍼도 함께 바꿔야 한다.
