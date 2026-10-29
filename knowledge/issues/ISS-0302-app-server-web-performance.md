---
type: issue
id: ISS-0302
created: 2026-10-16
topics: [ops-infra, practice]
symptoms: [느림, 통계 화면 AI 코멘트 대기, 샌드박스 Hikari 풀 매번 생성, "async 안 동기 Gemini 호출", 트랜잭션 안 외부 AI 호출, N+1, 웹 첫 번들 1MB, queryKey accessToken, isSubmitting 해제 안 됨, 히트맵 요일 어긋남]
root_cause: "화면마다 로딩 방식이 제각각이었고, 서버는 샌드박스 실행마다 커넥션 풀을 만들고 트랜잭션 안에서 외부 AI를 호출했으며, AI 서버는 이벤트 루프를 막는 동기 호출을 했다(감사 결과 앱 21·웹 13·서버 10항목)"
status: resolved
resolution: "[[ISS-0302-app-server-web-performance-report]]"
related: ["[[ISS-0300-app-motion-system-reveal-badges]]", "[[ISS-0301-ai-explanation-persist-pregenerate]]"]
source: "https://github.com/Twin-Fang/passQL/issues/497"
---

# ISS-0302: 앱·서버·웹 전반의 성능 저하 (감사 결과)

GitHub #497 (원본: 이슈 본문, 감사 결과 1·2 댓글, 구현 보고서 댓글).

## 증상
- 사용 중 느리고 답답함. 화면마다 데이터 로딩 방식이 제각각.
- 통계 화면이 진행 현황, 토픽 분석, AI 코멘트 3개를 모두 받아야 그려짐. AI 해설 시트를 다시 열 때마다 재요청.

## 재현 조건
해당 없음(전반 성능 개선).

## 조사 기록
- 2026-10-16 감사 1(앱·웹, origin/main 기준): 앱 높음 A1~A7(첫 화면 전 앱 설정 대기 최대 4초, 시작 초기화 9개 순차, `ShellRoute` 탭 재생성, 다음 문제 지연 로딩, 제출 성공 시 `isSubmitting` 미해제 버그, 홈 API 6개 대기, 통계 AI 대기), 중간 A8~A21(풀이마다 홈 6개·통계 3개 무효화, 히트맵 첫 칸 34일 전이라 요일 어긋남 버그, 결과 화면이 해설 요청에 정답 키 전송 버그 등). 웹 W1~W13(라우트 분할 없음, 227KB 로고, queryKey에 accessToken, staleTime 0, gcTime < AI staleTime, `refetchQueries`, 타이머 정리 누락·렌더 중 setState·응답 겹침 버그, 운영 console 로그 11곳).
- 2026-10-16 감사 2(서버·AI, `be840588` 기준): S1 샌드박스 실행마다 Hikari 풀 생성, S2 AI 서버 async 안 동기 Gemini 호출·worker 1개, S3 `@Transactional` 안 외부 AI·샌드박스 호출, S4 직접 Gemini 호출에 시간 제한·서킷 없음(Python 15초 후 Java fallback 이중 과금, retry가 사실상 꺼져 있음은 원본: 추정), S5 `QuestionService.getQuestion` N+1, S6 진행률 1회 쿼리 약 10개, S7 `HomeService.getToday` N+1, S8 세트 조회 인덱스 단일 컬럼, S9 `PrefetchService`는 호출하는 컨트롤러가 없는 죽은 코드, S10 AI 작업 큐 50개·topic-analysis만 UTC.
- 같은 댓글의 AI 비용 메모: LLM 호출 경로 목록, 토큰 사용량 미기록, `app_setting`의 `ratelimit.execute.per_minute`·`ratelimit.submit.per_minute`는 코드에서 읽지 않음(GitHub #498 크레딧 설계 근거로 적음).

## 근본 원인
frontmatter `root_cause`와 같음.
