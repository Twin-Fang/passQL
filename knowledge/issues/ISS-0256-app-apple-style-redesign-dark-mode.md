---
type: issue
id: ISS-0256
created: 2026-10-13
topics: [design-system]
symptoms: [UI 일관성 깨짐, 오답 빨강 4종, radius 15종, "BorderRadius.circular", ScreenUtil 혼용, FontAwesome Material 혼용, 결과 화면 3개 제각각, 안전 영역 무시, 다크 모드 없음]
root_cause: "디자이너 없이 화면마다 따로 만들어져 색·모서리·간격·아이콘·위젯이 통일되지 않았고 다크 테마가 없었다"
status: resolved
resolution: "[[ISS-0256-app-apple-style-redesign-dark-mode-report]]"
related: ["[[DEC-0116-app-apple-hig-design-system]]"]
source: "https://github.com/Twin-Fang/passQL/issues/450"
---

# ISS-0256: 앱 UI 일관성 붕괴 — Apple풍 디자인 시스템과 다크 모드로 전면 재디자인

GitHub #450 (원본: 이슈 본문과 완료 처리 댓글).

## 증상
디자이너 없이 화면마다 따로 만들어져 앱 UI 일관성이 깨져 있다. 원본 근거:
- 오답 빨강 4종: `AppColors.error`, `AppColors.red`, `AppColors.red900`, `Colors.red` 혼용 (`daily_set_result_page.dart`, `login_page.dart`, `settings_group.dart`)
- 모서리 radius 15종 이상: `BorderRadius.circular(숫자)` 90곳
- 간격 기준 없음, ScreenUtil 사용·미사용 파일 혼재
- 결과 화면 3개(단건·챕터·오늘의 세트)의 아이콘·버튼 높이(44/52)·모서리(12/14)·점수 글자·상단 바가 모두 다름
- 아이콘 라이브러리 2종(FontAwesome 35곳, Material 48곳)
- 중복 위젯(문제 풀이 화면 2개에 내부 위젯 5종, 오류 화면 6종, 카드 위젯 5종)
- 선택지에 채점 상태 없음, 하단 고정 버튼이 안전 영역 무시, 탭 바 아래 여백 과다, 로그인 버튼 쏠림, 스플래시 사각 배경 비침, 다크 모드 없음

## 재현 조건
앱 전 화면 (구조적 문제).

## 조사 기록
- 2026-10-13: 작업 9단계(토큰·테마 → 공용 컴포넌트 → 탭 바 → 문제 풀이 → 결과 화면 → 홈·통계·목록 → 설정 등 → 로그인·스플래시 → ScreenUtil·FontAwesome 제거). 완료 기준: 정답/오답 색 각 1종, 모서리 토큰 외 0건, 화면 코드 하드코딩 색·모서리·글자 스타일 0건, iOS·Android 라이트/다크 전 화면 캡처 비교.

## 근본 원인
frontmatter `root_cause`와 같음.
