---
type: issue
id: ISS-0325
created: 2026-10-18
topics: [notification]
symptoms: [공지 바텀시트, notice_body_sheet.dart, 게시일 없음, 공지 목록 없음, AppNotice publishedAt]
root_cause: "공지를 작은 바텀시트로만 보여주고 서버 응답에 게시일이 없었다"
status: resolved
resolution: "[[ISS-0325-notice-detail-list-screens-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/529"
---

# ISS-0325: 공지사항 상세·목록 화면 (바텀시트 대체)

GitHub #529 (원본: 이슈 본문과 댓글).

## 증상
홈 공지 배너나 알림함 공지를 누르면 작은 바텀시트에 제목과 본문 한두 줄만 뜬다(`notice_body_sheet.dart`). 게시일·구분(중요) 표시가 없고 긴 본문은 읽기 어렵다. 공지 상세·지난 공지 목록으로 이어지지 않는다. 서버 응답(`AppNotice`)에 게시일이 없다.

## 재현 조건
홈 공지 배너 또는 알림함 공지 항목 탭.

## 조사 기록
- 2026-10-18: PR #534 머지(GitHub #530과 공동), deploy 병합.

## 근본 원인
위 증상 그대로(원본에 별도 원인 서술 없음).
