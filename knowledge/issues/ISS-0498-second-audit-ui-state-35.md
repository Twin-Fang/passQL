---
type: issue
id: ISS-0498
created: 2026-11-12
topics: [practice, community, notification, auth-member, design-system]
symptoms: ["풀고 와도 잠김", "복사 메뉴 영어", "세션 만료 무안내", "번호판", "알림함 뒤로 가기 홈", "작성 중 글 사라짐", "선택지 생성 실패 막다른 길", "메모 펜 버튼 가림"]
root_cause: "상태 갱신·로케일·오류 처리·이탈 확인이 화면마다 빠져 있었고, 문구·날짜·오류 문구가 공통 원본 없이 흩어져 있었다"
status: resolved
resolution: "[[ISS-0498-second-audit-ui-state-35-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/995"
---

# ISS-0498: 2차 전체 점검 UI·UX·상태 처리 정리 35건

GitHub #995.

## 증상
문제 풀이·커뮤니티·알림·설정·계정·웹을 흐름 순서로 점검해 31건 + 실기기 3건(홈 시험 임박 문구 3번, 메모 펜 버튼이 보기 가림, '✨ 1' 의미 불명) + 비교표 세트 체험 반영.

## 근본 원인
상태 갱신·오류·이탈 처리를 화면마다 직접 만들고 공통 지점이 없었다.
