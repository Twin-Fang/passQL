---
type: completion-report
id: ISS-0253
created: 2026-10-08
topics: [design-system, practice]
status: resolved
resolves: "[[ISS-0253-topic-card-design-request]]"
related: ["[[DEC-0114-topic-card-option-a]]"]
source: "https://github.com/Twin-Fang/passQL/issues/447"
---

# ISS-0253 완료 리포트: 별도 시안 없이 A안으로 확정·구현, 디자인 요청 종료

GitHub #447 확정 댓글(2026-10-08) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
구현 GitHub #446, main `bbc114c`. 토픽별 색 아이콘 칩(44px), 화살표 오른쪽 위 고정, 서브토픽 개수 알약. 카드 비율 1.4 고정은 없애고 글자 배율만큼 카드 높이가 커진다.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
글자 200%·긴 이름 잘림 해소(코드 렌더 확인). 토픽별 색 9개는 코드에 정의(앱 색 토큰으로 옮기는 정리는 따로 가능). 웹 카테고리 버튼은 건드리지 않음. 디자이너 시안이 나오면 새 이슈로 다시 다듬는다.

## 교훈
(원본에 없음, 볼트 정리) 큰 글자·긴 이름·0개 같은 "디자이너가 보통 안 그리는 상태"를 요청서에 미리 넣으면 확정이 빠르다.
