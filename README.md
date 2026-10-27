<div align="center">

<img src="https://raw.githubusercontent.com/Twin-Fang/passQL/gh-pages/icon/mark.png" width="96" alt="passQL" />

# passQL

### 책 없이, 앱 하나로 SQLD

최신 출제 경향을 반영한 문제를 풀고, 보기 SQL을 **직접 실행**해 보고, 틀린 이유는 **AI 해설**로 바로 확인하세요.

<a href="https://apps.apple.com/kr/app/id6762165005"><img src="https://img.shields.io/badge/App_Store-다운로드-0D96F6?style=for-the-badge&logo=apple&logoColor=white" alt="App Store" /></a>
<a href="https://passql.vercel.app/"><img src="https://img.shields.io/badge/Web-바로_써보기-5E5CE6?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Web" /></a>
<img src="https://img.shields.io/badge/Google_Play-준비_중-3DDC84?style=for-the-badge&logo=googleplay&logoColor=white" alt="Google Play 준비 중" />

<br/>

[![API Docs](https://img.shields.io/badge/API-Swagger-85EA2D)](https://api.passql.suhsaechan.kr/docs/swagger-ui/index.html)
[![License](https://img.shields.io/badge/license-source--available-lightgrey)](LICENSE)

<br/>

<img src="https://raw.githubusercontent.com/Twin-Fang/passQL/main/app/docs/store/promo/feature-graphic.png" width="720" alt="passQL" />

<br/><br/>

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/main/app/docs/store/promo/ios-6.3/01.png" width="150" alt="책 없이 앱 하나로 SQLD" /></td>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/main/app/docs/store/promo/ios-6.3/02.png" width="150" alt="최신 출제 경향" /></td>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/main/app/docs/store/promo/ios-6.3/03.png" width="150" alt="주제별 문제" /></td>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/main/app/docs/store/promo/ios-6.3/04.png" width="150" alt="SQL 직접 실행" /></td>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/main/app/docs/store/promo/ios-6.3/05.png" width="150" alt="AI 해설" /></td>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/main/app/docs/store/promo/ios-6.3/06.png" width="150" alt="합격 준비도" /></td>
    <td><img src="https://raw.githubusercontent.com/Twin-Fang/passQL/main/app/docs/store/promo/ios-6.3/07.png" width="150" alt="오늘의 세트" /></td>
  </tr>
</table>

<sub>스토어 이미지 원본과 생성 도구: <a href="app/docs/store">app/docs/store</a></sub>

</div>

---

## 한눈에 보기

| | |
|---|---|
| **문제** | SQLD 출제 토픽 9개를 주제별로 정리, 실행형 문제와 개념 문제 |
| **최신 경향** | 최근 회차 출제 유형을 분석해 문제에 반영, '최신 경향' 표시로 바로 골라 풀기 |
| **검증** | 실행형 문제는 모든 선택지를 PostgreSQL 샌드박스에서 실제로 실행해 정답이 하나인지 확인 |
| **플랫폼** | iOS · Android · Web, Google·Apple·카카오·네이버·GitHub 로그인 |

---

## 핵심 기능

<table>
  <tr>
    <td width="50%" valign="top">
      <h4>최신 출제 경향 그대로</h4>
      최근 회차 시험의 출제 유형을 분석해 문제에 반영합니다. 과목별 비중과 늘어난 유형을 한눈에 보고, '최신 경향' 문제부터 풀 수 있습니다.
    </td>
    <td width="50%" valign="top">
      <h4>주제별 문제와 개념 TOP 10</h4>
      데이터 모델링부터 서브쿼리·그룹 함수까지 SQLD 전 범위를 주제와 챕터로 나눴습니다. 자주 나오는 개념은 TOP 10으로 먼저 잡습니다.
    </td>
  </tr>
  <tr>
    <td valign="top">
      <h4>보기 SQL 직접 실행</h4>
      선택지 SQL을 실제로 실행해 결과 표를 보여 줍니다. 외우지 않고 왜 정답인지 눈으로 확인합니다.
    </td>
    <td valign="top">
      <h4>AI 해설과 오답 노트</h4>
      내가 고른 답이 왜 틀렸는지, 정답과 무엇이 다른지 AI가 한국어로 짚어 줍니다. 틀린 문제는 오답 노트에 모입니다.
    </td>
  </tr>
  <tr>
    <td valign="top">
      <h4>합격 준비도</h4>
      정확도·학습 범위·최신 경향 대비를 합쳐 준비도를 계산합니다. 학습 달력, 연속 학습일, 시험 D-day를 함께 보여 줍니다.
    </td>
    <td valign="top">
      <h4>오늘의 세트와 순위</h4>
      매일 모든 회원이 같은 5문제를 풀고 순위를 겨룹니다. 점수는 서버가 제출 기록으로 검증합니다.
    </td>
  </tr>
</table>

### 이렇게 만들어집니다

AI가 정답 SQL을 실행하고, 그 결과를 보고 수험생이 헷갈리기 쉬운 지점(잘못된 JOIN 조건, GROUP BY 누락, NULL 처리 실수)을 겨냥한 오답을 만듭니다. 각 선택지 SQL은 문제마다 임시로 만드는 **PostgreSQL 샌드박스 DB**에서 실행해 결과를 비교하고, 정답이 딱 1개일 때만 저장합니다.
<sub>`NVL`·`SYSDATE` 같은 Oracle 함수는 PostgreSQL 문법으로 자동 변환합니다. 변환할 수 없는 Oracle 전용 문법은 개념 문제로 출제합니다.</sub>

관리자 화면에서는 토픽·난이도·스키마를 넣으면 AI가 문제 초안과 오답 선택지를 만들고, 대량 가져오기·내보내기와 샌드박스 일괄 검증을 지원합니다.

---

## 누구를 위한 서비스인가

- 수험서를 다 볼 시간이 없는 SQLD 수험생
- 기출 유형이 바뀌어 최신 경향이 궁금한 사람
- SQL을 처음 배우는 비전공자·신입 개발자
- 이동 중 짧은 시간에 문제를 풀고 싶은 사람

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
## 최신 버전 : v1.56.0 (2026-10-27)

[전체 버전 기록 보기](CHANGELOG.md) · [Admin](https://api.passql.suhsaechan.kr/admin/questions) · [API Docs](https://api.passql.suhsaechan.kr/docs/swagger-ui/index.html)

---

## License

passQL is source-available software, not open source.

You may use, modify, and study this project only for personal, non-commercial purposes in a local, non-production environment.

Commercial use, hosted service use, production use, and organizational use are prohibited without prior written permission.

For licensing inquiries: chan4760@naver.com
