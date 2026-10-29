---
type: completion-report
id: ISS-0051
created: 2026-04-11
topics: [ci-deploy, practice]
status: resolved
resolves: "[[ISS-0051-vercel-generate-choices-405]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/94"
---

# ISS-0051 완료 리포트: 정상 작동 확인 (수정 내용 기록 없음)

GitHub #94 댓글 "정상 작동 확인 완료"(2026-04-11, 영상 첨부) 기준.

## 해결 방법
원본에 적혀 있지 않다. 이슈 본문의 예상 동작은 `VITE_API_BASE_URL` 미설정 시에도 `<API 서버>/api`를 기본값으로 쓰고, `generateChoices()`도 다른 API처럼 `BASE_URL` 기반으로 요청하는 것이다.

## 근본 원인 (확정)
이슈 노트와 같다(이슈 본문 기준).

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 로컬은 되는데 배포본에서 405·404가 나면 요청 URL이 프론트 도메인으로 가는지(공통 `BASE_URL`을 우회한 하드코딩 경로)부터 본다.
