---
type: completion-report
id: ISS-0213
created: 2026-10-07
topics: [practice]
status: resolved
resolves: "[[ISS-0213-topic-card-zero-subtopics]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/368"
---

# ISS-0213 완료 리포트: 활성 서브토픽이 있을 때만 "N개 서브토픽" 표시

GitHub #368 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
`TopicCard`: 활성 서브토픽이 1개 이상일 때만 "N개 서브토픽" 표시, 없으면 문구 대신 이동 힌트 화살표.

## 근본 원인 (확정)
0개 문구 미처리 (서버 데이터 변경 없음).

## 재발 방지
위젯 테스트 2건(0개 숨김 / 활성 1개 표시) 통과, 분석 이슈 없음.

## 교훈
(원본에 없음, 볼트 정리) 개수 문구는 0일 때 숨기는 것을 기본으로 둔다.
