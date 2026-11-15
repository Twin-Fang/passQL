---
type: decision
id: DEC-0319
created: 2026-11-16
reviewed: null
topics: [progress-stats, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0521-sqld-exam-guide-and-yearly-stats]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]"]
---

# DEC-0319: 합격률은 연도별 공식 값만 수치로 싣고, 회차별 합격률은 확인된 전언(61회 약 26%)만 "수험생 전언, 비공식"으로 표시한다

## 문제 정의 (Context)
사용자가 회차별 합격률이 커뮤니티에 비공식으로 다 공유돼 있다며 통계에 넣기를 원했다. 조사해 보니 공식 회차별 수치는 발표되지 않고, 커뮤니티에도 확정 수치는 61회 하나뿐이었다 (GitHub #1077).

## 결정 (Decision)
- 연도별 접수자·응시자·합격자·합격률은 PQI 공식 값을 출처·확인일과 함께 싣는다.
- 회차별 합격률은 추정치를 만들지 않는다. 확인된 전언(61회 약 26%, 출처 3곳 수치 일치)만 "수험생 전언, 비공식" 배지와 함께 표시하고, 나머지 회차는 체감 난이도 한 줄만 둔다.
- 소개 사이트 합격률 FAQ 답변("숫자를 싣지 않는다")을 공식 연도별 수치와 통계 페이지 안내로 바꾼다.

## 검토한 대안 (Alternatives)
- 체감 후기("30%쯤")를 수치로 표기: 근거 없는 숫자라 탈락.
- 합격률을 계속 싣지 않음: 공식 출처를 확보했고 사용자 요청이 있어 탈락.

## 결과 (Consequences)
**긍정**
- 공식·비공식이 화면에서 구분돼 신뢰를 잃지 않는다.

**부정**
- 회차별 그래프는 만들 수 없다. 더 얻으려면 데이터자격검정센터 문의가 유일한 경로다.

## 영향 범위 (Scope)
`sqld-exam-guide.json` `roundNotes`(isOfficial), 앱 `exam_round_note_timeline.dart`, 소개 사이트 `site_exam_stats.py`·`site_content.py` 합격률 FAQ.

## 출처 (References)
- GitHub #1077 회차별 합격률 조사 댓글, 보고서 댓글 (2026-11-14, 2026-11-16)
- [[ISS-0521-sqld-exam-guide-and-yearly-stats]]
