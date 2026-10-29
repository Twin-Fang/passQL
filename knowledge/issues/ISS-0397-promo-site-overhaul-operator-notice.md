---
type: issue
id: ISS-0397
created: 2026-10-25
topics: [store-release]
symptoms: ["홍보 페이지 옛 수치", "github.io", gh-pages, "운영자 표기", "오늘의 세트 10문제 문구", "약관 본문 불일치"]
root_cause: "홍보 사이트(gh-pages)에 문제 수·10문제 같은 옛 수치와 옛 운영자 표기가 남아 있었다"
status: resolved
resolution: "[[ISS-0397-promo-site-overhaul-operator-notice-report]]"
related: ["[[ISS-0400-business-info-display-kollylab]]", "[[ISS-0401-hide-question-counts-exam-trend]]"]
source: "https://github.com/Twin-Fang/passQL/issues/650"
---

# ISS-0397: 홍보 페이지(github.io) 전체 재정비와 약관 운영자 표기

GitHub #650 (원본: 이슈 본문과 댓글).

## 증상
홍보·약관 페이지가 `twin-fang.github.io/passQL`(gh-pages)에 있고 웹 `vercel.json`·`siteUrls.ts`가 이 주소를 가리킨다. 스토어 문구에서 문제 수 표기를 뺐고(GitHub #636) 오늘의 세트를 5문제로 줄였는데(GitHub #644) 소개 페이지에 예전 수치가 남았을 수 있다. 운영자를 콜리랩(KOLLYLAB)으로 바꿨지만(GitHub #638) 약관·방침의 운영자 표기는 확인 전.

## 재현 조건
해당 없음 (콘텐츠 정비 이슈).

## 조사 기록
- 2026-10-25 1차 결과 댓글: gh-pages `535558e9` 게시. 다크 히어로·다크 모드, 새 앱 캡처 5장(문제 총량이 보이는 화면 제외), "하루 5문제", 푸터 `© 2026 KOLLYLAB (콜리랩)`, 약관·방침은 빌드 스크립트가 운영 API 본문에서 재생성. 사용자 확인 필요 항목으로 약관 본문 변경 게시, 문의 이메일 불일치(사이트 vs LICENSE), 사업자 정보 표기 범위, `IS_PLAY_STORE_PUBLIC=False`를 남김.
- 남은 것(메인 레포): 스토어 홍보 이미지 1번·`01_home.png`에 "오늘의 10문제"가 박혀 있어 `tool/store_shots`로 재생성 필요. 소개 사이트 소스 `_src`는 gh-pages 브랜치에만 있다.

## 근본 원인
홍보 사이트 문구·이미지가 앱 변경(#636·#644·#638)을 따라가지 않았다. 원인 분석은 원본에 따로 적혀 있지 않다.
