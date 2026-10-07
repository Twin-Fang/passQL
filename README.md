<div align="center">

<img src="https://raw.githubusercontent.com/Twin-Fang/passQL/gh-pages/icon/mark.png" width="96" alt="passQL" />

# passQL

**읽는 SQL 공부는 끝. 이제 직접 실행하며 합격하세요.**

SQLD·SQLP 수험생을 위한 AI 실행형 SQL 학습 서비스 — 문제은행이 아니라, 실행형 훈련기입니다.

AI가 함정 오답을 만들고, 실행형 문제는 모든 선택지를 **PostgreSQL 샌드박스**에서 실제로 실행해 정답이 하나인지 검증합니다.
<sub>`NVL`·`SYSDATE` 같은 Oracle 함수는 PostgreSQL 문법으로 자동 변환합니다. 변환할 수 없는 Oracle 전용 문법은 개념 문제로 출제합니다.</sub>

[**웹에서 바로 써보기**](https://passql.vercel.app/)

[![Web](https://img.shields.io/badge/Web-Live-2ea44f)](https://passql.vercel.app/)
[![API Docs](https://img.shields.io/badge/API-Swagger-85EA2D)](https://api.passql.suhsaechan.kr/docs/swagger-ui/index.html)
[![License](https://img.shields.io/badge/license-source--available-lightgrey)](LICENSE)

**문제 192개** (직접 실행하는 실행형 93 · 개념형 99) · **SQLD 출제 토픽 9개**
<sub>운영 DB 기준, 2026-10-08 측정</sub>
<!-- TODO: 스토어 공개 후 배지 추가
 · [Google Play](PLAY_STORE_URL) · [App Store](APP_STORE_URL) -->

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/gh-pages/shots/home.jpg" width="200" alt="홈" /></td>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/gh-pages/shots/questions.jpg" width="200" alt="문제 목록" /></td>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/gh-pages/shots/detail.jpg" width="200" alt="문제 풀이와 실행 결과" /></td>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/gh-pages/shots/rank.jpg" width="200" alt="오늘의 순위" /></td>
  </tr>
  <tr align="center">
    <td>홈</td><td>문제</td><td>직접 실행·채점</td><td>오늘의 순위</td>
  </tr>
</table>

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

## 로컬에서 돌려보기

스택별 실행 방법은 각 폴더의 안내를 따릅니다.

| 스택 | 폴더 | 안내 |
|---|---|---|
| Web | `client/` | [client/CLAUDE.md](client/CLAUDE.md) |
| Backend | `server/` | [server/CLAUDE.md](server/CLAUDE.md) |
| AI Server | `ai/` | [ai/CLAUDE.md](ai/CLAUDE.md) |
| App | `app/` | [app/CLAUDE.md](app/CLAUDE.md) |

```bash
# Web (client/.env.example 을 복사해 .env 작성)
cd client && npm install && npm run dev

# AI Server (ai/CLAUDE.md 의 환경변수 필요)
cd ai && uvicorn src.main:app --reload

# App (app/.env 에 BACKEND_BASE_URL 필요)
cd app && flutter run -d <기기>
```

Backend(Spring)는 PostgreSQL·Redis·Qdrant와 Gemini API 키가 필요합니다. 설정은 [server/CLAUDE.md](server/CLAUDE.md)를 따릅니다.

---

<!-- AUTO-VERSION-SECTION: DO NOT EDIT MANUALLY -->
## 최신 버전 : v0.0.244 (2026-10-07)

[전체 버전 기록 보기](CHANGELOG.md) · [Admin](https://api.passql.suhsaechan.kr/admin/questions) · [API Docs](https://api.passql.suhsaechan.kr/docs/swagger-ui/index.html)

---

## License

passQL is source-available software, not open source.

You may use, modify, and study this project only for personal, non-commercial purposes in a local, non-production environment.

Commercial use, hosted service use, production use, and organizational use are prohibited without prior written permission.

For licensing inquiries: chan4760@naver.com, ghd0106@naver.com
