---
type: completion-report
id: ISS-0175
created: 2026-10-07
topics: [community]
status: resolved
resolves: "[[ISS-0175-app-feedback-write-and-history]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/330"
---

# ISS-0175 완료 리포트: 채팅형 건의사항 화면 `/settings/feedback`

GitHub #330 구현 댓글(2026-10-02)과 2026-10-07 확인 댓글 기준.

## 해결 방법
- 설정에 "건의사항" 진입 카드, 화면 `/settings/feedback` 신설.
- 채팅형: 내 건의를 오래된 순 말풍선, 처리 상태(대기/확인됨/반영됨) 색·라벨 구분.
- 입력: 500자 표시, 공백 제외 1자 이상일 때만 전송, 앞뒤 공백 제거.
- 전송 실패 시 사유 표시·입력 유지, 목록 로딩 실패 시 다시 시도.
- 서버에 새 처리 상태가 추가돼도 깨지지 않게 모르는 값은 대기로 처리.

검증: 2026-10-02 테스트 66개(13개 추가), `POST /feedback`, `GET /feedback/me` 계약 테스트. 2026-10-07 테스트 147개, 실계정 E2E·TestFlight/Play 비공개 테스트 확인(GitHub #347, #348).

## 근본 원인 (확정)
해당 없음 (기능 추가).

## 재발 방지
모르는 상태값 기본 처리(대기), 계약 테스트.

## 교훈
원본에 적혀 있지 않다.
