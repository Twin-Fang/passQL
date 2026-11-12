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
| 화면 배경색 | 테마(`scaffoldBackgroundColor`)가 정함. `Scaffold(backgroundColor:)` 로 같은 값을 다시 넣지 않는다 |
| 글 속 인라인 코드 크기 | `PassqlTypography.inlineCodeOf(주변 스타일)` |
| 토픽 아이콘·색 | `topic_appearance.dart` (PassqlColors 와 같은 색은 토큰을 참조) |
| 로고 자산 | `components/passql_logo.dart` (자산 파일 원본은 브랜드 담당 영역) |

## 2. 공통 컴포넌트 (무엇을 한 번에 처리하는가)

| 컴포넌트 | 처리하는 것 |
|---|---|
| `PassqlButton` (+Variant, Size) | 모든 버튼. 비활성·로딩(`isLoading`)·폭(`isFullWidth`) |
| `PassqlPressable` | 누르는 동안 흐려지고 살짝 작아지는 피드백 (잉크 물결 대신). `semanticLabel` 이 있으면 그 문구만 읽음(자식 글자 덮음), `hasMinimumTouchTarget` 으로 누르는 영역 44 |
| `PassqlSemanticButton` | 누르는 요소의 스크린리더 정보(라벨·탭 동작·선택·링크). 화면에서 `Semantics(button + excludeSemantics)` 직접 사용 금지 (규칙 테스트) |
| `PassqlSegmentedControl` / `PassqlSegment` | 회색 트랙 + 선택 알약 세그먼트 (문제 탭 보기·알림함 탭). 칸마다 탭·선택 시맨틱, 누르는 높이 44 |
| `PassqlLoadingSemantics` | 로딩 자리(스피너·스켈레톤 묶음)를 '불러오는 중' 한 번으로 읽힘. 화면 스켈레톤 묶음은 이것으로 감쌈 |
| `PassqlCard` | 그림자 없는 카드, 제목·우측 요소, 바깥 높이 채움(`shouldChildFillHeight`, 2열 높이 맞춤) |
| `PassqlMarqueeText` | 한 줄 흐르는 글자(마퀴, 홈 공지 #701): 넘칠 때만 멈춤 > 흐름 반복(`isAlwaysScrolling` 이면 짧아도 흐름, 홈 공지 #756), 속도·멈춤·간격은 `PassqlMotion.marquee*`, 동작 줄이기면 말줄임, 스크린리더는 전체 문장 한 번 |
| `PassqlBarChart` / `PassqlBarChartBar` | 세로 막대 차트 (프로필 학습 통계, #909): 바닥선 + 막대(강조 몫은 강조색, 나머지는 옅은 강조색) + 아래 축 글자(칸보다 길면 양옆으로 넘침). 값은 최댓값 기준 비율, 처음 그릴 때 자람(동작 줄이기면 정지), 스크린리더는 `semanticLabel` 한 문장 |
| `PassqlActivityRings` | 바깥에서 안쪽으로 겹친 진행 링 (홈 합격 준비도 정확도·범위·최신성, #701). 링마다 비율·색, 가운데 글자 선택. 링은 스크린리더에서 숨기고 쓰는 쪽이 범례와 묶어 읽힘 |
| `PassqlSection` / `PassqlSectionGap` / `PassqlSectionHeader` / `PassqlSectionLink` | 홈식 구간: 좌우 끝까지 닿는 card 면(좌우 md·위아래 lg)과 구간 사이 md 높이 background 띠. 제목 줄은 높이 44 고정 title3(+ 앞 아이콘·오른쪽 요소), 오른쪽 이동 링크는 글자 + › 한 모양 (#701). `isCompactTitle`: 작은 타일 + 15pt 제목 (문제 탭 경향 구간, #726) |
| `PassqlGroupedSection` / `PassqlListRow` / `PassqlCheckRow` / `PassqlIconTile` | iOS 설정 앱식 목록 묶음·행·선택 행·아이콘 타일 (`isCompact`: 26pt 구간 제목용, #726). 묶음 머리글 오른쪽 요소는 `headerTrailing` (크레딧 내역 날짜별 남은 수, #974) |
| `PassqlNavBar` / `PassqlNavButton` / `PassqlLargeTitleScrollView` | 상단 바(제목 글자 대신 가운데 위젯 `middle` 가능), 뒤로/닫기 버튼, 탭 화면 틀(탭 첫 화면은 제목과 오른쪽 요소가 한 줄인 고정 바, 뒤로 갈 수 있는 화면은 접히는 큰 제목, #971) |
| `PassqlBrandBarScrollView` | 홈 탭 화면 틀: 로고 또는 `leading`(왼쪽)·trailing(오른쪽) 한 줄 고정 바, 내용이 밑으로 지나가면 글래스 + 헤어라인 (#530) |
| `PassqlTabBar` / `PassqlTabIcon` (+`PassqlTabIconKind`) | 하단 탭 바: 아이콘 + 라벨, 하단 여백 기준 `PassqlTabBar.bottomPaddingOf`. 아이콘은 직접 그림(비선택 선, 선택은 같은 윤곽을 강조색으로 채우고 체크·말풍선 사이 틈·집게 둘레만 뚫음), 새로 선택될 때만 아이콘 일부가 움직임(동작 줄이기면 정지, #755) |
| `PassqlTabBarWithBottomStrip` | 탭 바 아래 한 줄 띠(광고, #527): 순서 탭 바 > 띠(위 헤어라인·표면색 `backgroundOf`·높이 `PassqlSize.bottomStrip`) > 홈 인디케이터 여백. 내용은 `AdNativeStripSlot` 이 채움 |
| `PassqlBottomActionBar` / `PassqlGlass` | 하단 고정 버튼 영역, 흐림 바탕(고정 크롬 전용) |
| `showPassqlSheet` | 모달 시트(손잡이·제목·키보드 여백). 닫기 X 없음: 손잡이 드래그·바깥 탭·뒤로가기·본문 버튼으로 닫힘 |
| `showPassqlConfirmDialog` | 취소/확인 확인 창, `isDestructive` 로 파괴적 스타일 |
| `showPassqlBlockingProgress` | 진행 중 화면 잠금 창 |
| `PassqlLoadingIndicator` (+`PassqlLoadingSize`) | 모든 로딩 스피너 (인라인·섹션·화면 잠금 3단계) |
| `PassqlRefreshControl` | 당겨서 새로고침 sliver (#772): 당긴 만큼 켜지는 웨이브 점, 끝까지 당기면 손 뗄 때까지 물결, 손 떼는 순간 화면 전체 빛. 동작 줄이기면 켜진 점만 |
| `PassqlGlow` | 원에서 화면 끝까지 번지는 보라 빛 (개념 다 맞힘 점수판·새로고침 공용) |
| `PassqlStatusView` / `PassqlSkeletonBox` | 로딩·빈·오류 상태 한 모양, 스켈레톤 조각 |
| `PassqlSliverFillStatus` | 스크롤 화면 남은 높이를 채우는 상태 자리. 탭 바·광고 띠 뒤(extendBody) 높이를 빼고 보이는 영역 가운데에 둠 (#741). 스크롤 화면 안 상태 뷰는 `SliverFillRemaining` 대신 이것으로 |
| `PassqlTextSkeleton` | 글 문단 자리(줄 N개 한 블록, 반짝임 1개, 동작 줄이기면 정지) — AI 해설 대기 (#521) |
| `PassqlListSkeleton` | grouped 목록 로딩 자리(행 N개, 머리글) — 토픽·순위·오답 노트 |
| `PassqlStatusScaffold` | 상태만 보여 주는 화면 틀(상단 바 + 가운데 본문) |
| `PassqlResultMark` / `PassqlScoreHeader` / `PassqlResultScaffold` | 정답/오답 표시, 점수 고리, 결과 화면 3종 공통 틀 |
| `PassqlChoiceCard` (+`PassqlChoiceState`) | 선택지 카드의 선택·채점 모양 (내용은 `ChoiceItemCard` 가 채움) |
| `PassqlCodeBlock` | SQL 표시 블록. 키워드 강조색(`highlightedKeywords`, 공통 목록 `sqlKeywords`)·문자열 정답색(`shouldColorStringLiterals`) 선택 |
| `PassqlQueryResultTable` / `PassqlQueryResultRow` | 푼 문제를 SQL 실행 결과처럼: 코드 블록 > 결과 표(이름·정답/오답 배지·오답만 `다시 ›`, 행 차례 등장) > `N rows selected · 정답 M`, 행 상한 넘으면 접기 (#999). 결과 화면 3종은 `SolvedQuestionResultTable` 로 씀 |
| `PassqlQueryStatusLine` | SQL 실행 결과 한 줄(성공 ✓ 정답색·경고 ! 주황): 첫 문제 완료 `1행 수정됨`, 크레딧 소진 `0 rows` (#999) |
| `PassqlMemoScope` / `PassqlMemoCanvas` / `PassqlMemoController` | 풀이 화면 메모 (#904): 틀(펜 버튼·도구 막대·켬 안내)은 문항 영역을, 층(Canvas)은 스크롤 내용을 감쌈. 켬이면 한 손가락 그리기·두 손가락 스크롤, 끔이면 메모는 흐리게 남고 터치는 전부 아래로. 컨트롤러는 화면 State 가 들고 응시 동안만 메모리에 (문항별 획·되돌리기). 틀 밖의 층은 내용만 그림 |
| `PassqlCallout` (+`PassqlCalloutKind`) | 강조 상자: 옅은 의미색 바탕 + 왼쪽 막대 + 아이콘·라벨 한 줄 + 내용 (강조·주의·외울 것 3종). 개념 학습 한 줄 핵심·자주 틀리는 점·시험 포인트 (#835), 꼭 외울 것 카드 (#876) |
| `PassqlBadge` (+`PassqlBadgeKind`) / `PassqlLatestTrendBadge` / `PassqlProgressBar` | 의미별 캡슐 태그(주제·보조·완료·연속·중요·AI·최신 경향·외울 것, 아이콘·테두리), '최신 경향' 배지(문구 원본, #523), 진행 막대 |
| `PassqlSegmentedProgress` (+`PassqlProgressSegmentState`) / `showPassqlRewardCelebration` | 풀이 상단 칸 N개 진행 바(맞힘 correct·틀림 wrong·지금 칸 accent 숨쉬기, 채점 칸 한 번 튐, #999). 크레딧 보상 창: 동전 팝·빛·불꽃 > +N > 이유 > `UPDATE` 한 줄·실행 결과 > 오늘 크레딧 이전 > 이후 + 기본(accent)·보너스(correct) 게이지. 동작 줄이기면 마지막 모습만 |
| `PassqlReveal` / `passqlRevealInOrder` | 처음 그려질 때 페이드 + 위로 8px, 순번별 지연(상한 8) (#495) |
| `PassqlScrollReveal` | 스크롤로 화면에 들어올 때 한 번 페이드 + 위로, 순번별 지연 (개념 레슨 블록, #848). 스크롤 영역 밖이면 바로 등장, 동작 줄이기면 정지 |
| `PassqlScrollProgress` | 스크롤로 들어오면 0 > 1 로 한 번 진행하는 그림 틀 (선 긋기·칠하기·빠지기, 개념 그림 블록 #853). 동작 줄이기면 처음부터 1 |
| `PassqlFadeSwitcher` | 로딩 > 내용 같은 상태 교체 페이드 (상태마다 다른 key) |
| `PassqlPageDots` | 넘김 페이지 점: 현재 페이지만 강조색 알약으로 늘어남 (홈 출제 경향 캐러셀·온보딩) |
| `PassqlPageSlideSwitcher` | 본문 교체(다음 문제) 옆으로 미끄러짐 + 페이드 (항목마다 다른 key) |
| `PassqlPopIn` | 톡 튀어나오는 등장 (반짝이, 결과 마크) |
| `PassqlAiHeader` | AI 내용 머리: 반짝이 팝 + 제목 미끄러짐 |
| `PassqlLogo` | 라이트/다크 워드마크 |
| `PassqlAvatar` | 원형 프로필 사진: 이미지 주소 > 원형 자르기(표시 크기로 디코딩), 없음·불러오는 중·실패면 이름 첫 글자 원 (#908) |
| `PassqlNotificationBellButton` | 홈 상단 종 아이콘(강조색) + 안 읽은 개수 배지(빨강 `countBadge`, 10 이상 9+, #756). 알림함 진입은 이 버튼으로만 (규칙 테스트) |
| `PassqlLockedPreview` | 잠긴 기능 묶음: 흐린 가짜 미리보기 + 가운데 한 줄(해요체 문장) + 알약 `PRO로 보기`, 영역 전체 탭 > `onUnlock` (#576). 프로 안내 시트는 `widgets/pro/pro_offer_sheet.dart` 의 `showProOfferSheet` |
| `PassqlPassTicket` (+`PassqlPassTicketTier`, `PassqlPassTicketField`) / `PassqlPassUsageGauge` | passQL PASS 탑승권 (#749): 본문(제목·경로·정보 칸·혜택 아이콘·footer) + 절취선 + 떼는 칸. 무료 회색·프로 그라데이션, 빛줄기·홀로그램·기울기 선택, 동작 줄이기면 효과 정지. 사용량 게이지는 빛이 지나감. 내 프로필·이용권 구매 시트·정보 시트가 쓴다 |
| `PassqlCreditIcon` | 크레딧 아이콘 에셋(번개 동전, #971). 무료 한도 표시는 이 아이콘 + 숫자로만 (상단 알약 `RemainingSolvesPill`, 프로필 오늘 크레딧, 세트 보너스 줄) |
| `PassqlPlanChip` | 등급 칩: 무료 회색 `FREE`(탭 가능) · 프로 보라 `PRO`(탭 없음) (#576) |
| `PassqlTextScaleLimit` | 시스템 글자 크기 상한(`MaterialApp.builder` 한 곳에서 앱 전체 적용, #486) |
| `PassqlNavLeading` / `PassqlTabItem` | 상단 바 왼쪽 버튼 종류(없음·뒤로·닫기), 탭 바 항목 |

## 3. 화면 코드 규칙 (규칙 테스트가 강제)

화면(`lib/presentation/pages`, `widgets`, `flows`)은 토큰과 컴포넌트만 조합한다.

- 색은 `context.passqlColors` 의 의미 이름으로만 고른다. `Color(0x...)`, `Colors.white/black` 금지
- 읽는 글자색: 강조 글자는 `accentText`(accent 는 채움·테두리), 주황 글자는 `warningText`, 노랑(외울 것) 글자는 `memorizeText`(형광펜 `memorizeHighlight` 위 글자는 `label`, #876), 진한 의미색 채움 위 글자는 `onSemantic`, 보조 글자는 `secondaryLabel`. `tertiaryLabel` 은 비활성·장식(쉐브론) 전용, 기능 아이콘은 `iconSecondary`. 대비 기준은 글자 4.5·아이콘 3 (라이트·다크). 자동 검사는 외울 것 색만(`test/presentation/design/memorize_color_contrast_test.dart`), 그 밖의 새 색 토큰은 라이트·다크 캡처로 확인 (전체 대비 테스트는 #680 에서 삭제)
- 간격·크기·글자는 토큰으로. 필요한 토큰이 없으면 토큰을 먼저 추가하고, 한 파일에서만 쓰는 배치 숫자는 이름 있는 상수로 둔다
- 자산은 컴포넌트로(`PassqlLogo`). `Image.asset(` 금지
- 흐림(`ImageFilter.blur(`)은 `PassqlLockedPreview`·`PassqlGlass` 로만. 화면 직접 사용 금지
- 시트는 `showPassqlSheet`, 확인 창은 `showPassqlConfirmDialog`, 로딩은 `PassqlLoadingIndicator`, 당겨서 새로고침은 `PassqlRefreshControl`. `showModalBottomSheet(`, `showCupertinoDialog(`, `CupertinoActivityIndicator(`, `CupertinoSliverRefreshControl(` 직접 사용 금지
- 시트 파일(`*_sheet.dart`·`*_dock.dart`)에 닫기 X 아이콘(`CupertinoIcons.xmark*`, `Icons.close*`) 금지. 비모달 해설 시트(`AiExplanationDock`)도 접힘에서 끌어 내리면 닫힘, 스크린리더는 제목의 '해설 닫기' 동작 (#699)
- 이동 경로는 `AppRoutes` (`lib/router/app_routes.dart`). `context.go('/...')`, `push('/...')` 문자열 금지
- 아이콘은 `CupertinoIcons` (이모지 금지). 예외: 하단 탭 바는 부품별 움직임 때문에 `PassqlTabIcon`(Lucide 계열 선 아이콘 직접 그림, #755)
- 애니메이션 시간·곡선은 `PassqlMotion` 토큰으로. `Curves.`, `duration: Duration(` 직접 사용 금지. 동작 줄이기(`PassqlMotion.isReduced`)는 공통 컴포넌트가 처리한다

강제 위치: `test/architecture/design_system_rules_test.dart`. 예외가 꼭 필요하면 테스트 안 `_allowedUsages` 에 파일·패턴·이유를 적는다.

## 4. 새 컴포넌트를 만들 때

- 같은 UI 가 3곳째 생기면 `components/` 에 `passql_<이름>.dart` 로 만들고 `design.dart` 에 export 한다
- 파일 하나에 주된 타입 하나, 파일명 = 타입명. boolean 속성은 `is/has/can/should` 로 시작
- 색·크기는 토큰에서 가져온다. 컴포넌트 안에서만 쓰는 규격 숫자는 이름 있는 상수 + 한 줄 주석
- 라이트·다크 양쪽에서 확인한다 (pro-launch 캡처, 기능 테스트는 두지 않음 #680)

## 5. 화면 원칙 (2026-11-12 사용자 피드백에서 굳힌 것, #963·#966·#971)

새 화면을 만들거나 고칠 때 아래를 먼저 지킨다. 어기는 시안은 보여 주기 전에 고친다.

### 5.1 정보는 한 번만, 필요한 곳에만
- 같은 값(크레딧 수, 받은 보너스, 시험 D-day)을 한 화면에 두 번 적지 않는다. 늘 보여야 하는 값은 상단 바 한 곳, 자세한 것은 눌러서 여는 시트
- 가격을 설득하는 덧말(하루 약 N원, 월 환산, "가장 많이 골라요", 다른 상품 권유 줄)을 붙이지 않는다. 가격·줄 그은 정가·할인율만
- 목록 행 오른쪽에 상태 글자·칩을 여러 개 쌓지 않는다. 행은 아이콘·제목·한 줄 설명·화살표

### 5.2 접지 않고 한 번에
- 비교는 표로 한 번에 보인다 (무료·프로 비교표). "N가지 더 보기·접기"로 숨기지 않는다
- 표의 왼쪽 제목은 짧은 명사(문제, 광고, 해설). 줄바꿈 없이 한 화면에 들어가게 줄 수와 줄 높이를 정한다

### 5.3 일반적인 앱의 자리 규칙
- 상단 바: 왼쪽 로고(또는 화면 제목), 오른쪽 재화(크레딧 아이콘 + 숫자)·알림. 재화를 누르면 받는 방법과 구매가 한 시트에
- 부족할 때만 모달: 크레딧이 0일 때 안내 시트, 평소에는 방해하지 않는다
- 서로 다른 기능은 다른 구간으로 나눈다 (오늘의 세트와 랜덤 풀기를 한 카드에 넣지 않는다)
- 상태 배지(완료 등)는 값의 오른쪽 끝에 둔다

### 5.4 한 단어, 한 아이콘
- 무료 한도는 `크레딧`으로만 부른다 ("남은 문제", "문제 더 받기", "+N문제" 금지). 랜덤 풀기 1문제 = 크레딧 1개
- 같은 뜻에는 같은 아이콘 하나. 혜택마다 색이 다른 알록달록한 타일 대신 한 색 픽토그램
- 잠금 문구는 명사 나열(`A · B · C`) 대신 해요체 한 문장, 버튼은 `PRO로 보기`
- 은유를 쓸 때도 낯선 말은 피한다 (탑승권의 `승객` 대신 `수험생`)

### 5.5 카드 구성
- 고르는 카드(이용권)는 나란히 놓고 값(가격)을 가장 크게, 선택 표시는 오른쪽 위
- 받는 방법 카드(크레딧 더 받기)는 아이콘 원 > 이름 > 수량 > 상태 한 줄. 받은 것은 초록, 지금 할 수 있는 것은 강조색
- 한 시트 안 카드들은 같은 머리 구성(아이콘 타일 + 제목 + 한 줄 설명)을 쓴다
- 흰 구간 면 위에 흰 카드를 또 얹지 않는다 (카드 안 카드 금지). 구간 면 위에서는 테두리·옅은 바탕으로만 묶는다

### 5.6 시안을 보여 줄 때
- 지금 화면을 실제 코드로 렌더해 먼저 보고, 그 위에서 바꾼 것을 다시 렌더해 나란히 보여 준다 (HTML 로 새로 그린 그림은 실제와 달라 보인다)
- 라이트·다크 둘 다, 스크롤 없이 한 화면에 들어가는지, 글자가 줄바꿈으로 깨지지 않는지 확인한 뒤에 보여 준다
- 에셋(`Image.asset`)은 테스트 렌더에서 `precacheImage` 로 미리 불러와야 그림에 찍힌다

