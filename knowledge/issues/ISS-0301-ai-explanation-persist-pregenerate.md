---
type: issue
id: ISS-0301
created: 2026-10-16
topics: [ai, practice]
symptoms: [AI 해설 DB 미저장, Redis 24시간 캐시, Gemini 재호출, 해설 버튼 수 초 대기, rationale 중복 생성, 통계 AI 코멘트 대기, result_page 정답 키 전송]
root_cause: "AI 해설이 Redis에 24시간만 캐시되고 사용자가 버튼을 눌러야 생성됐다"
status: resolved
resolution: "[[ISS-0301-ai-explanation-persist-pregenerate-report]]"
related: ["[[DEC-0137-pregenerate-choice-explanations-db]]", "[[ISS-0302-app-server-web-performance]]"]
source: "https://github.com/Twin-Fang/passQL/issues/496"
---

# ISS-0301: AI 해설이 영구 저장되지 않고 오답 해설을 매번 기다려야 함

GitHub #496 (원본: 이슈 본문, 설계 근거 댓글, 구현 보고서 댓글).

## 증상
- AI 해설(오답 비교, SQL 오류)은 DB에 저장되지 않고 서버 Redis에 24시간만 캐시. 지나거나 Redis가 비면 Gemini 재호출(비용, 문구 변경).
- 앱은 해설을 보관하지 않아 시트를 다시 열면 서버에 요청하고 로딩을 기다림.
- 오답 해설은 버튼을 눌러야 생성돼 수 초씩 기다림.
- 선택지 생성 때 이미 `rationale`을 만들지만 심화 해설은 별도 호출이라 같은 정보를 두 번 만듦.
- 통계 화면은 AI 코멘트까지 받아야 그려짐.

## 재현 조건
선택지 오답 해설 버튼을 누를 때마다(대기), Redis 캐시 만료 후(재호출).

## 조사 기록
- 2026-10-16 09:47 서버 감사 댓글: 오답 해설 입력(`AiExplainService.java:136-163`)은 세트 생성 순간 모두 있고 회원마다 다른 값이 없다. Redis 캐시 키 `{문제}:{세트}:{고른 키}`도 회원과 무관. 현재 rationale은 temperature 0.9, 최대 1536 토큰이라 짧고 얕음.
- 같은 댓글이 함께 고칠 것으로 기록: 단건 결과 화면이 해설 요청에 정답 키를 보냄(`app/lib/presentation/pages/result/result_page.dart:119`), 고른 키 검증 없음, 실패 3회 후 샌드박스 미검증 세트가 OK로 저장·공유됨(`ChoiceSetGenerationService.java:191-199`), SQL 오류 해설 입력 검증 없음·캐시 키가 32비트 `hashCode`, 웹 `diffExplain`은 호출하는 곳 없음.
- 이슈 본문의 크레딧 연동("더 자세히" 심화 해설은 크레딧)은 구현 보고서에 언급이 없다. 크레딧 이슈 GitHub #498은 이후 취소됨.

## 근본 원인
frontmatter `root_cause`와 같음.
