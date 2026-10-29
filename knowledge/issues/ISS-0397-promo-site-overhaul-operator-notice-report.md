---
type: completion-report
id: ISS-0397
created: 2026-10-26
topics: [store-release]
status: resolved
resolves: "[[ISS-0397-promo-site-overhaul-operator-notice]]"
related: ["[[ISS-0400-business-info-display-kollylab]]"]
source: "https://github.com/Twin-Fang/passQL/issues/650"
---

# ISS-0397 완료 리포트: 홍보 사이트 전면 재설계 배포

GitHub #650 리포트 댓글(2026-10-26) 기준.

## 해결 방법
홍보 사이트를 재설계해 배포(gh-pages `b173875a`). 문구는 기존처럼 `site_content.py` 한 곳에서 관리하고 빌드 스크립트가 페이지를 만든다.
- 구성: 첫 화면(시험 D-day 63회, 방문 날짜 기준 계산), 수험생 고민 4가지, 기능 카드 10개, 학습 흐름(매일 5문제 > AI 해설 > 오답 노트 > 합격 준비도), 최신 경향(제58~62회), 시험 범위 9개 주제, 갤러리 7장, 무료·Pro 비교(가격 없음), FAQ 7개, 푸터 KOLLYLAB(콜리랩).
- 파일: `_src/site_content.py`(문구·운영자 표기 상수), `_src/site_home.py`(신규), `style.css`(토큰 한 곳, 라이트·다크), `site.js`(D-day·등장 효과·갤러리), `shots/` 캡처 7장(WebP).
- 계정 삭제 안내의 앱 경로를 "내 프로필 > 설정"으로 수정.

## 근본 원인 (확정)
원본에 적혀 있지 않다 (옛 문구·수치가 남아 있던 콘텐츠 정비).

## 재발 방지
- 문제 총 개수 같은 수치는 일부러 넣지 않음(GitHub #636, #660).
- 결제를 켜기 전 숨기려면 `IS_PRO_PLAN_VISIBLE = False`, Play 공개 뒤 `IS_PLAY_STORE_PUBLIC = True`.
- 확인: 데스크톱 1440·모바일 390, 라이트·다크 캡처, 콘솔 에러 없음, 약관·방침·계정 삭제·SQLD/SQLP·404 페이지 200, 운영 주소 새 문구. 1차 댓글 기준 실제 기기 Safari는 확인하지 못함.

## 교훈
(원본에 없음, 볼트 정리) 앱의 수치·문구(문제 수, 세트 문제 수, 운영자)를 바꾸면 gh-pages 홍보 사이트와 스토어 홍보 이미지도 같이 점검한다.
