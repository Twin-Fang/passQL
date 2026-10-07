<div align="center">

# passQL

**읽는 SQL 공부는 끝. 이제 직접 실행하며 합격하세요.**

> AI가 정답 실행결과를 보고 함정 오답을 역설계합니다.
> 당신은 SQLD 시험과 동일한 Oracle SQL 환경에서 직접 실행하며 검증합니다.

<!-- AUTO-VERSION-SECTION: DO NOT EDIT MANUALLY -->
## 최신 버전 : v0.0.237 (2026-10-07)

[전체 버전 기록 보기](CHANGELOG.md)

[**Live Demo**](https://passql.vercel.app/) · [**Admin**](https://api.passql.suhsaechan.kr/admin/questions) · [**API Docs**](https://api.passql.suhsaechan.kr/docs/swagger-ui/index.html)

</div>

---

## passQL은 무엇인가

**SQLD·SQLP 자격증을 위한, AI 기반 실행형 SQL 학습 서비스**입니다. 웹과 모바일 앱(Android/iOS)으로 제공합니다.

- AI가 정답 SQL의 실행 결과를 보고 **함정 오답 선택지를 만들고**, 샌드박스 DB에서 **직접 실행해 검증**한 문제만 저장합니다.
- 틀리면 AI가 에러 원인과 오답 이유를 **한국어로 해설**합니다.
- 최근 틀린 문제를 분석해, **의미적으로 유사한 약점 유형을 추천**합니다.
- **Google/Apple 로그인**으로 어느 기기에서든 학습 기록이 이어집니다.

한 줄로: **문제은행이 아니라, 실행형 훈련기입니다.**

---

## 핵심 기능

### AI 오답 역설계 + Sandbox 검증

AI가 정답 SQL을 실행하고, 그 결과를 보고 수험생이 헷갈리기 쉬운 지점(잘못된 JOIN 조건, GROUP BY 누락, NULL 처리 실수)을 겨냥한 오답을 만듭니다. 각 선택지 SQL은 격리된 **PostgreSQL 샌드박스 DB**에서 실제로 실행해 실행 결과를 비교하고, 정답이 딱 1개일 때만 저장합니다. 샌드박스는 문제를 풀 때마다 임시로 만들어지고 채점 후 삭제됩니다.

### 자유 SQL 실습

선택지 외에 내가 쓴 SQL도 실행해 "이건 왜 안 되지?"를 바로 확인합니다.

### AI 해설

에러 메시지 한국어 설명, 정답 SQL과의 차이 비교, 취약 개념 재설명을 AI가 제공합니다.

### 개인화 약점 추천

최근 틀린 문제를 벡터로 바꿔(bge-m3, Qdrant) 의미적으로 가까운 문제를 추천합니다.

### 오늘의 세트와 리더보드

매일 모든 회원이 같은 10문제를 풀고 순위를 겨룹니다. 점수는 서버가 제출 기록으로 검증합니다.

### 학습 통계

토픽별 정답률(레이더 차트), 합격 준비도, 학습 히트맵, 연속 학습일, 시험 일정 D-day, 오답 노트.

### 관리자 AI 출제 인터페이스

관리자 화면에서 토픽·난이도·스키마를 입력하면 AI가 문제 초안과 오답 선택지를 생성합니다. 대량 JSON 가져오기·내보내기와 샌드박스 일괄 검증을 지원합니다.

---

## 누구를 위한 서비스인가

- SQLD·SQLP 수험생
- SQL을 처음 배우는 비전공자·신입 개발자
- 실무 SQL을 다시 잡는 현업 개발자

---

## 아키텍처

<img width="1459" height="825" alt="image" src="https://github.com/user-attachments/assets/236105cb-1ed8-4dc5-824f-231ddb05e6f6" />

---

## 기술 스택

| 레이어 | 기술 |
|---|---|
| **Web** | React 19 · TypeScript · Vite (Vercel) |
| **App** | Flutter · Riverpod · go_router · Firebase Auth |
| **Backend** | Spring Boot 3 · Java 21 |
| **AI Server** | FastAPI · Google Gemini API |
| **SQL Sandbox** | PostgreSQL (문제별 임시 DB) |
| **Vector Search** | bge-m3 · Qdrant |
| **Database** | PostgreSQL · Redis |
| **Infra / CI** | Synology NAS · Docker · GitHub Actions |

---

## License

passQL is source-available software, not open source.

You may use, modify, and study this project only for personal, non-commercial purposes in a local, non-production environment.

Commercial use, hosted service use, production use, and organizational use are prohibited without prior written permission.

For licensing inquiries: chan4760@naver.com, ghd0106@naver.com
