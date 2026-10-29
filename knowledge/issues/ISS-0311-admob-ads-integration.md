---
type: issue
id: ISS-0311
created: 2026-10-16
topics: [ads]
symptoms: [광고 없음, google_mobile_ads, AdMob, 배너, 네이티브, 전면, ATT, app-ads.txt]
root_cause: ""
status: open
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/506"
---

# ISS-0311: AdMob 광고 연동 (배너·네이티브·전면)

GitHub #506 (원본: 이슈 본문과 댓글). 이슈는 열려 있다(라벨 작업중).

## 증상
앱에 광고 수익 수단이 없다. `google_mobile_ads` 패키지, AdMob 앱 ID, 광고 단위가 없고 AdMob 콘솔에 passQL 앱·광고 단위도 없다.

제안: elum의 AdMob 구조 기준(앱 ID는 `.env` 주입, 비면 Google 테스트 앱 ID / `AdPlacement` enum, 디버그·프로필은 테스트 단위 강제, 릴리스에서 값이 비면 광고 안 띄움 / 첫 광고 요청 때 SDK 초기화). 배치는 학습 흐름을 끊지 않는 곳만, 풀이·채점·로그인·탈퇴 근처·법적 고지는 제외. 광고 SDK import는 ads 모듈 안에서만.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-10-16: 개인정보처리방침 광고 고지 초안 댓글. PR #510 머지 — 탭 하단 적응형 배너, 문제 탭 네이티브, 결과 화면 전면(3분 간격, 하루 최대 3회), `ad_placement_rules_test.dart`, `google_mobile_ads` 9.0.0 고정(9.1.0은 iOS `use_frameworks!` 빌드 실패). ATT는 앱 시작 직후(elum이 첫 광고 요청 때 묻다가 App Review 2.1로 리젝된 경험). UMP(EU 동의)는 넣지 않음. 스토어 배포 안 함.
- 2026-10-17: AdMob 콘솔에 앱 2개·광고 단위 10개 생성, `ENV_FILE`·`app/.env`에 키 12개 추가(기존 키 보존), 방침에 광고 고지 반영(시행일 2026-10-17), gh-pages `privacy.html`·`terms.html`을 운영 API 본문에서 생성(`_src/site_legal.py`), `app-ads.txt` 배포.
- 2026-10-17: 실제 광고 단위 포함 첫 빌드 — iOS 1.13.0 TestFlight·심사 제출, Android versionCode 307 내부·비공개 테스트. Android 프로덕션은 프로덕션 출시 권한 부족으로 보고 미제출.
- 이후 배치는 GitHub #527(탭바 아래 한 줄 띠)·#522(인라인 카드)로 바뀌었다.

## 근본 원인
해당 없음 (기능 추가, 진행 중).
