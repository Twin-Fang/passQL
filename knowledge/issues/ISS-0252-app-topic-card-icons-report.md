---
type: completion-report
id: ISS-0252
created: 2026-10-10
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0252-app-topic-card-icons]]"
related: ["[[DEC-0114-topic-card-option-a]]"]
source: "https://github.com/Twin-Fang/passQL/issues/446"
---

# ISS-0252 완료 리포트: 토픽 카드 A안 반영

GitHub #446 배포 완료 댓글(2026-10-10) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
A안(토픽별 색 아이콘 칩, 화살표 고정, 개수 알약, 글자 배율에 따라 커지는 카드 높이)을 `main`에 반영 (`bbc114c`).

## 근본 원인 (확정)
이슈 노트와 같음 (1.4 고정 비율 그리드).

## 재발 방지
글자 200%와 긴 이름에서 이름이 잘리던 결함 해결(코드 렌더 기준, 실기기 화면은 확인 못 함). 스토어 반영: iOS 빌드 0.7.0 심사 대기(#352), Android 내부 테스트 0.7.1 게시, 비공개(Alpha) 0.7.1 Google 검토 대기(#448).

## 교훈
(원본에 없음, 볼트 정리) 고정 가로세로 비율 그리드에 요소를 더하면 큰 글자 배율에서 잘림부터 확인한다.
