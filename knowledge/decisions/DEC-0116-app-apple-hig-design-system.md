---
type: decision
id: DEC-0116
created: 2026-10-13
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0256-app-apple-style-redesign-dark-mode]]", "[[ISS-0256-app-apple-style-redesign-dark-mode-report]]"]
---

# DEC-0116: 앱은 Apple(iOS HIG) 스타일 단일 디자인 시스템으로 iOS·Android 같은 모양, 다크 모드 포함

## 문제 정의 (Context)
화면마다 따로 만들어져 색·모서리·간격·아이콘·결과 화면이 제각각이고 다크 모드가 없었다 (GitHub #450).

## 결정 (Decision)
"AI가 만든 티가 나지 않는" Apple(iOS HIG) 스타일 단일 디자인 시스템을 앱 전 화면에 적용한다. iOS와 Android는 같은 모양. 기능·API·화면 이동은 바꾸지 않는다. 웹은 이번 범위가 아니며 앱 기준이 확정된 뒤 따로 맞춘다.
- 의미 기반 색 토큰(라이트/다크 한 쌍), Apple 글자 크기 단계, 간격 7단계, 모서리 4종
- 강조색 Apple systemIndigo, 정답/오답 색 각 1종
- 그림자 대신 배경 밝기 대비로 카드 구분, 반투명 블러(글래스)는 탭 바·상단 바·하단 버튼 영역·시트에만
- 아이콘은 Cupertino 아이콘 하나로 통일 (FontAwesome·ScreenUtil 제거)
- 공용 컴포넌트로 중복 위젯 정리, 결과 화면 3개를 한 틀로
- 다크 모드는 시스템 설정 따름

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음. (원본: 이 디자인이 포함된 빌드로 App Store 1.0 출시.)

**부정**
- 웹과 앱 디자인이 당분간 다르다(웹은 범위 밖).

## 영향 범위 (Scope)
`app/` 전 화면, 디자인 토큰·테마, 공용 컴포넌트, 하단 탭 바, 결과 화면, 로그인·스플래시.

## 출처 (References)
- GitHub #450 이슈 본문 「해결 방안」(2026-10-13), 완료 처리 댓글(2026-10-16)
