---
type: issue
id: ISS-0261
created: 2026-10-15
topics: [design-system]
symptoms: [ThemeMode.system 고정, 화면 모드 선택 없음, 라이트 다크 선택, 시트가 탭바 뒤에 깔림, PqGroupedSection 높이]
root_cause: "앱 테마가 `ThemeMode.system`으로 고정돼 기기 설정과 다르게 고를 방법이 없었다"
status: resolved
resolution: "[[ISS-0261-app-theme-mode-setting-report]]"
related: ["[[ISS-0256-app-apple-style-redesign-dark-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/455"
---

# ISS-0261: 앱에서 라이트/다크/시스템 화면 모드를 고를 수 없음

GitHub #455 (원본: 이슈 본문, 구현 보고서, 배포 댓글).

## 증상
앱 테마가 `ThemeMode.system`으로 고정. 작업 중 공통 컴포넌트 문제 2개도 드러남: 그룹 목록이 시트 안에서 남은 높이를 다 채움, 탭 화면에서 연 시트가 하단 탭바 뒤에 깔림.

## 재현 조건
해당 없음 (기능 부재). 시트 문제: 설정 등 탭 화면에서 `showPqSheet`로 시트를 열면 아래 항목이 탭바에 가려짐.

## 조사 기록
- 2026-10-15: 제안 — 설정에 '화면' 그룹·'화면 모드' 줄, 하단 시트로 `시스템 설정 따르기`/`라이트`/`다크`, 기본값 시스템, `shared_preferences` 기기 저장(서버 저장 없음), `runApp` 전에 저장값을 읽어 깜빡임 없이 표시.

## 근본 원인
frontmatter `root_cause`와 같음. 시트 문제는 `PqGroupedSection` 바깥 `Column` 기본값(max), `showPqSheet`가 최상위 Navigator를 쓰지 않음(리포트).
