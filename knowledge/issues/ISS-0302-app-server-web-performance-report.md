---
type: completion-report
id: ISS-0302
created: 2026-10-16
topics: [ops-infra, practice]
status: resolved
resolves: "[[ISS-0302-app-server-web-performance]]"
related: ["[[ISS-0300-app-motion-system-reveal-badges]]", "[[ISS-0301-ai-explanation-persist-pregenerate]]"]
source: "https://github.com/Twin-Fang/passQL/issues/497"
---

# ISS-0302 완료 리포트: 샌드박스 단일 연결, 트랜잭션 밖 AI·SQL 실행, Gemini 제한, 웹 번들 1,036KB → 175KB, 앱 미리 받기·부분 갱신

GitHub #497 구현 보고서 댓글 기준 (Spring `38894084999`, AI `38894084977`, Vercel `38894085051`). 같은 시간 다른 세션의 AdMob 연동(GitHub #506)과 충돌 두 곳은 양쪽 변경을 모두 살려 합침.

## 해결 방법
- 서버·AI:
  - 샌드박스 SQL 실행: 실행마다 Hikari 풀 생성 → `SandboxPool.openConnection`으로 연결 1개만.
  - 답안 제출: 채점·저장만 짧은 트랜잭션, SQL 실행은 밖에서. AI 코멘트·추천의 클래스 단위 트랜잭션 제거.
  - Gemini 직접 호출: 호출 30초 제한, 동시 8건(자리 대기 20초).
  - AI 서버: `client.aio` 비동기 호출, 키가 바뀔 때만 클라이언트 생성, 30초 제한.
  - 제출 인덱스 `(member_uuid, question_uuid, submitted_at DESC)`, 마이그레이션 `V0_10_51`.
- 웹: 라우트 지연 로딩·라이브러리 청크 분리(메인 JS 1,036KB(gzip 312KB) → 175KB(gzip 56KB)), 로고 227KB → 35KB(생성기에 웹용 높이 120px 규칙, `--check` 27개 일치), 쿼리 키 토큰 → 회원 UUID, 전역 gcTime 30분·AI 코멘트 staleTime과 같게, `refetchQueries` → `invalidateQueries`, AI 코멘트는 데이터 있을 때만·마지막 제출 때 미리, 버그 3건(카운트업 타이머 누수, 렌더 중 setState, AI 오류 해설 응답 겹침), 운영 console 로그 제거, 동작 줄이기 대응, 해설 시트 진입 연출.
- 앱: 시작 시 Firebase 뒤 독립 초기화 5개·보안 저장소 키 4개 동시 처리, 챕터 다음 문제 미리 받기·`PassqlPageSlideSwitcher`, 풀이 후 학습 현황·통계·오답 수만 재조회, 새로고침 실패 시 데이터 유지, 스켈레톤(`PassqlListSkeleton`, `QuestionSolvingSkeleton`), SQL 실행 결과 자동 스크롤, 정답·오답 햅틱, 오늘의 세트 순위 완료 응답으로 표시, 히트맵 첫 칸을 그 주 일요일로·오늘 칸 강조, SSE 대기 75초 분리·GET 연결 오류 1회 재시도, 설정 오답 수만 조회(`size: 1`).
- 검증: 서버 전체(기존 실패 1개 제외), AI pytest 31개, 웹 tsc 0·eslint 0·vitest 48개, 앱 analyze 0·테스트 332개. 운영 실측: 웹 메인 JS 175,393B, 로고 35,218B, flyway `0.10.51`·인덱스 `idx_submission_member_question_submitted` 생성, AI `/health` ok.

## 근본 원인 (확정)
감사 결과(이슈 노트 조사 기록)와 같음.

## 재발 방지
남은 것(원본):
- 앱 점검·강제 업데이트 확인(첫 화면 전 최대 4초 대기)은 화면 깜빡임 위험이 있어 이번에 바꾸지 않음.
- 순위·알림 목록 지연 생성은 sliver용 묶음 컴포넌트가 필요해 다음으로.
- 운영 요청 로그(`[req]`)가 info 수준이라 거의 남지 않아 엔드포인트별 실제 지연 수치를 집계하지 못함. 느린 요청만 따로 남기는 기준을 다음에 정하면 좋다.
- 원본은 이슈 본문에서 "바꾸기 전과 후에 주요 화면 진입 시간과 API 응답 시간을 비교"를 계획했으나, 리포트의 전후 수치는 웹 번들·로고 크기뿐이고 API 지연 수치는 위 이유로 집계하지 못했다.

## 교훈
(원본에 없음, 볼트 정리) 서버 응답이 느리면 `@Transactional` 안에서 외부 AI·샌드박스를 호출하는지, 샌드박스가 매번 커넥션 풀을 만드는지부터 본다.
