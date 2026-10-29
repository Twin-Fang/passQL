---
type: completion-report
id: ISS-0401
created: 2026-10-26
topics: [question-bank, store-release]
status: resolved
resolves: "[[ISS-0401-hide-question-counts-exam-trend]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/660"
---

# ISS-0401 완료 리포트: 최신 경향 화면·콘텐츠·홍보 이미지에서 문제 수 제거

GitHub #660 리포트 댓글 기준 (커밋 `aaee6139` PR #661, `72360f26` PR #662, v1.51.0~1.51.1).

## 해결 방법
- 앱: `latest_trend_tab_view.dart` 머리 카드의 총 개수 줄 제거, `exam_trend_sections.dart` 과목별 비중에서 문항 수 제거, `main_shots.dart`·`questions_tab_test.dart` 갱신.
- 웹: `client/src/pages/ExamTrend.tsx`, `ExamTrend.test.tsx`.
- 서버 콘텐츠: `sqld-latest-trend.json` 분석 근거 문구에서 "250문항" 제거.
- 스토어 홍보 이미지: `app/docs/store/promo/{ios-6.9,ios-6.5,ios-6.3,android-phone}/02.png`, `source/03_trend.png` 재생성.

## 근본 원인 (확정)
화면과 콘텐츠가 보유량 수치를 표시했다.

## 재발 방지
- 서버 응답의 `latestTrendQuestionCount`는 남아 있고 화면에서만 쓰지 않는다. 응답에서 빼려면 GitHub #632처럼 옛 앱 호환 처리와 최소 버전 상향이 필요해 범위에서 뺐다.
- 다시 만든 홍보 이미지의 스토어 업로드는 GitHub #636과 함께 진행.

## 교훈
(원본에 없음, 볼트 정리) 화면에서 수치를 숨길 때 응답 필드 제거는 옛 앱 호환 비용이 따르므로 화면 미사용과 응답 제거를 분리해 판단한다.
