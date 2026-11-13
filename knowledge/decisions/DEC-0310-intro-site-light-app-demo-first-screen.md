---
type: decision
id: DEC-0310
created: 2026-11-13
reviewed: null
topics: [design-system, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0516-intro-site-light-demo-store-urls]]", "[[DEC-0139-intro-site-generated-from-src]]", "[[DEC-0294-intro-site-self-hosted-own-domain]]"]
---

# DEC-0310: 소개 사이트는 밝은 화면으로 고정하고, 첫 화면은 앱 사용 흐름 재생 + 스크롤 공부 순서(시안 D)로 만든다

## 문제 정의 (Context)
소개 사이트가 기기 다크 모드를 따라 어둡게 보였고, 첫 화면이 정적이라 앱이 하는 일이 바로 보이지 않았다. 사용자가 밝은 화면과 애니메이션, 이룸 사이트 개편 때 준 피드백 반영을 요청했다(GitHub #1057).

## 결정 (Decision)
- `color-scheme: light` 고정, 다크 토큰 블록 제거, `theme-color` 한 벌.
- 머리·바닥에 브랜드 가로 로고(`brand/logo_horizontal.png` > `icon/logo.png`, `build_icons.py` 생성).
- 첫 화면: 기기 틀 안 앱 문제 풀이 화면(앱 라이트 토큰으로 HTML 재현)이 문제 > 보기 선택 > SQL 실행 결과 > 정답 > AI 해설을 반복 재생, 아래 단계 칩 진행 막대.
- 그 아래 스크롤 공부 순서 5단계(개념 > 문제 > 실행 > 정답 > 해설), 고정 폰 화면이 단계에 맞춰 바뀜(개념 단계만 실제 캡처).
- 이룸 피드백: 스토어 버튼 같은 폭·높이, 기기에 맞는 버튼만, 모바일 한 줄·아래쪽 앱 받기 띠, 겹친 그림·세로 강조선 금지, 제목 옆 아이콘, 움직임 줄이기면 전부 정지.
- 첫 화면 구역은 첫 화면 > 휘장 > 이야기 > 후기 > 시험 정보 > 최신 경향 > 요금 > FAQ > 다운로드로 줄이고, 주제 띠·숫자·고민·기능·학습 흐름·범위·화면 모음은 뺀다.

## 검토한 대안 (Alternatives)
- 시안 A(플레이 데모만): 사용자가 "A가 맞아 보인다"면서 B와 섞자고 함 > 합본으로.
- 시안 B(SQL 타이핑 + 스크롤 스토리만): 합본의 아래 구역으로 흡수.
- 시안 C(벤토 타일 6칸 미세 애니메이션): 고르지 않음, 이유는 논의 기록 없음.
- 실제 앱 캡처를 그대로 쓰기: 캡처가 전부 다크라 밝은 사이트와 맞지 않아 HTML 재현으로.

## 결과 (Consequences)
**긍정**
- 첫 화면에서 앱이 하는 일이 움직임으로 보인다. 화면 크기·기기별 버튼 처리가 이룸 사이트와 같은 기준이 된다.

**부정**
- 재생 폰은 실제 앱 캡처가 아닌 재현이라 앱 화면이 바뀌면 `site_content.DEMO_*`·`demo.css` 를 함께 고쳐야 한다.
- 뺀 구역의 CSS·옛 문구 상수가 남아 있다(동작 영향 없음).

## 영향 범위 (Scope)
gh-pages `_src/site_demo.py`·`site_home.py`·`site_head.py`·`site_content.py`·`build_icons.py`, `demo.css`·`demo.js`·`style.css`·`site.js`.

## 출처 (References)
- GitHub #1057 이슈 본문·보고서 댓글, 시안 기록(pro-ui-design 결정 d)
