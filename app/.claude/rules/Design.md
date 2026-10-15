# passQL 앱 디자인 시스템 (Passql)

앱 UI 는 Apple(iOS) 시스템 디자인을 따르는 자체 디자인 시스템 **Passql** 로만 만든다.
`Passql` 접두사는 "passQL 앱 디자인 시스템 소속"이라는 뜻이다. 디자인 시스템 밖의 클래스에는 붙이지 않는다.

**이 문서에는 값(hex, 숫자)을 적지 않는다.** 값의 원본은 코드이고, 문서는 어디를 보면 되는지만 가리킨다.
문서에 값을 복사하면 코드와 어긋난다(웹 문서를 복사해 둔 이전 판이 실제로 그랬다).

## 1. 계층과 원본 위치

```
lib/presentation/design/
├── design.dart                 # 배럴. 화면은 이 파일 하나만 import
├── passql_theme.dart           # PassqlTheme(라이트/다크 ThemeData), context.passqlColors, context.isDark
├── passql_haptics.dart         # PassqlHaptics (선택·정답·오답 햅틱)
├── topic_appearance.dart       # 토픽 코드 > 아이콘·색 (topicIconFor, topicColorFor)
├── tokens/                     # 값의 원본
│   ├── passql_tokens.dart      # 토큰 배럴
│   ├── passql_colors.dart      # PassqlColors: 의미 색 + 라이트/다크 값
│   ├── passql_typography.dart  # PassqlTypography: Apple Dynamic Type 단계 + 코드·긴 글 스타일
│   ├── passql_spacing.dart     # PassqlSpacing: 간격 단계
│   ├── passql_radius.dart      # PassqlRadius: 모서리
│   ├── passql_size.dart        # PassqlSize: 버튼·바·행 높이, 터치 영역, 로딩 반지름 등
│   ├── passql_icon_size.dart   # PassqlIconSize: 아이콘 크기 단계
│   └── passql_motion.dart      # PassqlMotion: 애니메이션 시간·곡선
└── components/                 # 3번 이상 쓰이는 UI (파일명 = 주된 타입명)
```

| 무엇이 궁금한가 | 원본 |
|---|---|
| 색 이름과 라이트/다크 값 | `lib/presentation/design/tokens/passql_colors.dart` |
| 글자 크기·굵기·줄 높이 | `lib/presentation/design/tokens/passql_typography.dart` |
| 간격·모서리·크기·아이콘 크기 | `tokens/passql_spacing.dart`, `passql_radius.dart`, `passql_size.dart`, `passql_icon_size.dart` |
| 다크 판정 | `passql_theme.dart` 의 `context.isDark` (다른 방법으로 판정하지 않는다) |
| 토픽 아이콘·색 | `topic_appearance.dart` (PassqlColors 와 같은 색은 토큰을 참조) |
| 로고 자산 | `components/passql_logo.dart` (자산 파일 원본은 브랜드 담당 영역) |

## 2. 공통 컴포넌트 (무엇을 한 번에 처리하는가)

| 컴포넌트 | 처리하는 것 |
|---|---|
| `PassqlButton` (+Variant, Size) | 모든 버튼. 비활성·로딩(`isLoading`)·폭(`isFullWidth`) |
| `PassqlPressable` | 누르는 동안 흐려지는 피드백 (잉크 물결 대신) |
| `PassqlCard` | 그림자 없는 카드, 제목·우측 요소 |
| `PassqlGroupedSection` / `PassqlListRow` / `PassqlCheckRow` / `PassqlIconTile` | iOS 설정 앱식 목록 묶음·행·선택 행·아이콘 타일 |
| `PassqlNavBar` / `PassqlNavButton` / `PassqlLargeTitleScrollView` | 상단 바, 뒤로/닫기 버튼, 큰 제목 탭 화면 틀 |
| `PassqlTabBar` | 하단 탭 바 (아이콘만, #367) |
| `PassqlBottomActionBar` / `PassqlGlass` | 하단 고정 버튼 영역, 흐림 바탕(고정 크롬 전용) |
| `showPassqlSheet` | 모달 시트(손잡이·제목·닫기·키보드 여백) |
| `showPassqlConfirmDialog` | 취소/확인 확인 창, `isDestructive` 로 파괴적 스타일 |
| `showPassqlBlockingProgress` | 진행 중 화면 잠금 창 |
| `PassqlLoadingIndicator` (+`PassqlLoadingSize`) | 모든 로딩 스피너 (인라인·섹션·화면 잠금 3단계) |
| `PassqlStatusView` / `PassqlSkeletonBox` | 로딩·빈·오류 상태 한 모양, 스켈레톤 조각 |
| `PassqlStatusScaffold` | 상태만 보여 주는 화면 틀(상단 바 + 가운데 본문) |
| `PassqlResultMark` / `PassqlScoreHeader` / `PassqlResultScaffold` | 정답/오답 표시, 점수 고리, 결과 화면 3종 공통 틀 |
| `PassqlChoiceCard` (+`PassqlChoiceState`) | 선택지 카드의 선택·채점 모양 (내용은 `ChoiceItemCard` 가 채움) |
| `PassqlCodeBlock` | SQL 표시 블록 |
| `PassqlBadge` / `PassqlProgressBar` | 캡슐 배지, 진행 막대 |
| `PassqlLogo` | 라이트/다크 워드마크 |

## 3. 화면 코드 규칙 (규칙 테스트가 강제)

화면(`lib/presentation/pages`, `widgets`, `flows`)은 토큰과 컴포넌트만 조합한다.

- 색은 `context.passqlColors` 의 의미 이름으로만 고른다. `Color(0x...)`, `Colors.white/black` 금지
- 간격·크기·글자는 토큰으로. 필요한 토큰이 없으면 토큰을 먼저 추가하고, 한 파일에서만 쓰는 배치 숫자는 이름 있는 상수로 둔다
- 자산은 컴포넌트로(`PassqlLogo`). `Image.asset(` 금지
- 시트는 `showPassqlSheet`, 확인 창은 `showPassqlConfirmDialog`, 로딩은 `PassqlLoadingIndicator`. `showModalBottomSheet(`, `showCupertinoDialog(`, `CupertinoActivityIndicator(` 직접 사용 금지
- 이동 경로는 `AppRoutes` (`lib/router/app_routes.dart`). `context.go('/...')`, `push('/...')` 문자열 금지
- 아이콘은 `CupertinoIcons` (이모지 금지)

강제 위치: `test/architecture/design_system_rules_test.dart`. 예외가 꼭 필요하면 테스트 안 `_allowedUsages` 에 파일·패턴·이유를 적는다.

## 4. 새 컴포넌트를 만들 때

- 같은 UI 가 3곳째 생기면 `components/` 에 `passql_<이름>.dart` 로 만들고 `design.dart` 에 export 한다
- 파일 하나에 주된 타입 하나, 파일명 = 타입명. boolean 속성은 `is/has/can/should` 로 시작
- 색·크기는 토큰에서 가져온다. 컴포넌트 안에서만 쓰는 규격 숫자는 이름 있는 상수 + 한 줄 주석
- 라이트·다크 양쪽에서 확인한다 (`test/design/dark_smoke_test.dart` 참고)
