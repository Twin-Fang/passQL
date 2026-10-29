---
type: cluster
topic: design-system
created: 2026-10-29
members: 108
status: active
related: []
---

# 클러스터: design-system

## 이 주제는
디자인 토큰·공통 UI 컴포넌트·폰트·테마

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 33개, 열린 이슈 2개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0017-fullscreen-result-screen]] — 제출 결과 화면은 풀스크린 1종으로 통일 (bottom sheet 변형 미채택)
- [[DEC-0057-confirm-modal-bottom-sheet-all-sizes]] — `ConfirmModal`은 데스크톱도 화면 너비 100% 바텀시트 단일 레이아웃
- [[DEC-0059-ai-question-terminology]] — 사용자 화면의 "문제"를 "AI문제"로 통일하고 lucide `Sparkles`를 AI 표시 전용 아이콘으로 쓴다
- [[DEC-0061-no-inline-style-rule]] — 프론트에서 인라인 `style` 속성 절대 금지 — Tailwind 유틸리티 또는 `components.css` 커스텀 클래스만
- [[DEC-0063-daisyui-incremental-adoption]] — daisyUI 클래스는 Home.tsx 파일럿부터 1:1 대체 가능한 요소만 순차 적용하고 passQL 전용 클래스는 유지
- [[DEC-0064-force-light-passql-theme]] — 웹은 `data-theme="passql"`로 라이트 테마를 고정한다 (OS 다크모드 무시)
- [[DEC-0066-css-variable-for-dynamic-styles]] — 런타임 동적 스타일 값은 CSS 변수 주입 패턴으로 — 인라인 style 금지 규칙의 예외
- [[DEC-0069-settings-tab-rows-only-subpages]] — 설정 탭은 row 목록만 — 기능(건의사항 등)은 탭바 없는 서브페이지로
- [[DEC-0071-settings-flat-grouped-list]] — 설정 화면은 카드 대신 iOS grouped 스타일 flat 리스트 (전체 너비 border-y + divide-y, 가로형 row)
- [[DEC-0074-shared-markdowntext-component]] — AI 텍스트·해설·지문은 공용 `MarkdownText`로 렌더링하고 `useAiText`는 쓰지 않는다
- [[DEC-0114-topic-card-option-a]] — 앱 토픽 선택 카드는 별도 시안 없이 보드의 A안(토픽별 색 + 큰 칩)으로 간다
- [[DEC-0116-app-apple-hig-design-system]] — 앱은 Apple(iOS HIG) 스타일 단일 디자인 시스템으로 iOS·Android 같은 모양, 다크 모드 포함
- [[DEC-0120-pq-prefix-to-passql]] — 앱 디자인 시스템 접두사 `Pq`를 `Passql...`로 풀어 쓴다
- [[DEC-0121-unified-brand-color]] — 앱·웹 브랜드 색을 하나로 — `#5856D6`(다크 `#5E5CE6`), 웹 토큰은 앱 light 값에 맞춘다
- [[DEC-0124-brand-folder-generated-assets]] — 브랜드 자산 원본은 레포 루트 `brand/` 하나, 플랫폼 사본은 스크립트로만 생성하고 CI 해시 검사
- [[DEC-0136-motion-via-tokens-only]] — 앱 모션은 `PassqlMotion` 토큰과 공통 연출 컴포넌트로만 쓰고, 외부 애니메이션 패키지는 넣지 않는다
- [[DEC-0168-text-only-color-tokens]] — 글자에는 브랜드 `accent` 대신 글자 전용 토큰(`accentText` 등)을 쓴다
- [[DEC-0170-sheet-no-close-x-centered-title]] — 앱 공통 바텀시트는 닫기 X 없이 제목을 가운데 둔다 (`hasCloseButton` 옵션 폐지)
- [[DEC-0171-four-tabs-merge-stats-my-profile]] — 하단 탭을 홈 / 문제 / 토론 / 내 프로필 4개로 — 기록과 MY를 `내 프로필`로 합치고 설정은 톱니바퀴로 여는 push 화면
- [[DEC-0172-flexible-layout-no-fixed-sizes]] — 기기 크기·글자 크기 대응은 고정 높이·폭 없이 내용에 맞춰 자라는 레이아웃으로, 기기별 분기는 쓰지 않는다
- [[DEC-0180-social-login-disabled-opacity-only]] — 소셜 로그인 버튼은 비활성일 때 회색으로 바꾸지 않고 투명도만 낮춘다 (브랜드 색 유지)
- [[DEC-0186-card-radius-equals-button-even-tokens]] — 앱 둥글기는 짝수 토큰만 쓰고, 카드(`lg`)는 동심 공식 대신 버튼과 같은 12로 맞춘다
- [[DEC-0189-home-section-layout-single-cta]] — 앱 홈은 카드 대신 좌우 끝까지 닿는 구간(면 + 회색 띠)으로 나누고, 채운 버튼은 「오늘의 세트 풀기」 하나만 둔다 (다른 탭은 카드 유지)
- [[DEC-0192-readiness-activity-rings]] — 앱 홈 합격 준비도는 겹친 링 3개(정확도·범위·최신성) + 범례로, 색은 기존 앱 토큰
- [[DEC-0198-cards-for-pick-lists-sections-for-reports]] — 앱에서 고르는 목록은 카드, 위에서 아래로 읽는 리포트는 구간 — 문제 탭은 최신 경향·개념 TOP 10만 구간으로
- [[DEC-0205-pro-benefits-single-source]] — 앱 이용권 혜택 목록은 `pro_benefits.dart` 한 곳을 원본으로 쓰고, 실제 잠금이 있는 기능만 보인다
- [[DEC-0206-topic-accuracy-list-with-octagon-chart]] — 앱 영역별 정답률은 목록을 기본으로 두고 같은 자리에서 8각 차트로 바꿔 본다 (레이더·막대 두 장 통합, `fl_chart` 제거)
- [[DEC-0207-pass-ticket-upright-float-shadow]] — passQL PASS 탑승권은 시트에서도 기울이지 않고 정방향으로 두고, 띄움 그림자만 쓴다
- [[DEC-0208-pass-ticket-fields-unified]] — 프로필·정보 시트 탑승권 칸은 승객 · 남은 날 · 시험일, 떼는 칸 글자는 "사용 중"으로 통일하고 바코드 폭은 그 글자 폭에 맞춘다
- [[DEC-0209-pass-ticket-label-size-only]] — 탑승권 정보 칸은 라벨만 12 → 11로 줄이고 값은 13을 유지한다
- [[DEC-0210-benefit-icons-reuse-app-icons]] — 이용권 혜택 아이콘은 앱에서 같은 기능에 이미 쓰는 아이콘으로 통일한다
- [[DEC-0211-benefit-colors-per-benefit]] — 혜택 아이콘 색은 혜택마다 다른 색으로 두고, 출제 경향 불꽃만 문제 탭 불꽃 색(`warning`)을 쓴다
- [[DEC-0212-keep-benefit-icon-row-in-ticket]] — 탑승권 안의 혜택 아이콘 줄은 유지한다 (세 곳 모양 통일)
- [[DEC-0215-tab-bar-icons-custom-drawn-exception]] — 하단 탭 바 아이콘만 직접 그린 아이콘(선택 시 같은 윤곽 강조색 채움, 일부 움직임). DEC-0116 아이콘 통일의 조건부 예외

## 대체된 결정 (역사)
- [[DEC-0018-four-tab-bottom-navigation]] → null
- [[DEC-0022-design-md-single-source-of-truth]] → DEC-0121
- [[DEC-0101-bottom-tab-icons-only]] → DEC-0157
- [[DEC-0157-community-bottom-tab]] → DEC-0167
- [[DEC-0167-five-tabs-with-text-labels]] → DEC-0171

## 관련 이슈
- [[ISS-0430-app-bottom-tab-bar-icon-motion]] (resolved, GitHub #755) — 앱 하단 탭 바 아이콘 위 여백과 선택 애니메이션
- [[ISS-0394-device-size-layout-audit]] (open, GitHub #646) — 기기 크기별 화면·폰트·UX 문제 점검
- [[ISS-0426-app-community-tab-list-redesign]] (open, GitHub #741) — 앱 토론 탭 첫 화면·의견 화면을 게시판 목록·댓글 모양으로 개편
- [[ISS-0008-react-client-initial-setup]] (resolved, GitHub #5) — React Client 초기 프로젝트 구성
- [[ISS-0011-screen-spec-api-mapping]] (resolved, GitHub #8) — 전체 화면 명세 및 API 매핑
- [[ISS-0012-design-system-screen-ui]] (resolved, GitHub #9) — 디자인 시스템 기반 전체 화면 UI 구현
- [[ISS-0017-design-md-light-design-system]] (resolved, GitHub #20) — Design.md 기반 디자인 시스템 정비 및 적용
- [[ISS-0069-questions-detail-page-ui-polish]] (resolved, GitHub #120) — Questions / QuestionDetail 페이지 UI 개선
- [[ISS-0075-fixed-bottom-action-buttons]] (resolved, GitHub #131) — 제출·액션 버튼 fixed bottom 전 화면 통일
- [[ISS-0078-schema-viewer-ui-rounded-unify]] (resolved, GitHub #135) — SchemaViewer UI 개선 및 전체 rounded 통일
- [[ISS-0081-confirm-modal-desktop-layout-broken]] (resolved, GitHub #142) — "풀이를 그만할까요?" 확인 모달이 데스크톱에서 깨짐
- [[ISS-0085-ai-question-terminology-sparkles]] (resolved, GitHub #149) — 서비스 전반 "문제" → "AI문제" 용어 통일 및 Sparkles 아이콘
- [[ISS-0087-mobile-header-team-modal]] (resolved, GitHub #157) — 모바일 홈 상단 헤더 및 팀 모달 구현
- [[ISS-0090-practice-result-screen-redesign]] (resolved, GitHub #161) — 문제 풀이 결과 화면 UI 전면 개선
- [[ISS-0091-stagger-fadein-tab-sections]] (resolved, GitHub #162) — 홈 및 탭 전환 시 섹션별 스태거 페이드인 애니메이션
- [[ISS-0092-home-daisyui-pilot]] (resolved, GitHub #167) — Home.tsx daisyUI 컴포넌트 클래스 적용 (파일럿)
- [[ISS-0094-topic-category-card-ui]] (resolved, GitHub #169) — AI문제 풀기 카테고리 카드 UI 개선
- [[ISS-0096-choicecard-confirmmodal-daisyui-buttons]] (resolved, GitHub #175) — ChoiceCard · ConfirmModal 버튼을 daisyUI 클래스로 전환
- [[ISS-0097-stats-page-ui-overhaul]] (resolved, GitHub #176) — 통계 페이지 UI 전면 개선
- [[ISS-0098-applayout-nav-daisyui-classes]] (resolved, GitHub #179) — AppLayout 네비게이션에 daisyUI 클래스 적용
- [[ISS-0101-questions-page-tailwind-utilities]] (resolved, GitHub #183) — Questions.tsx 커스텀 CSS를 Tailwind 유틸리티로 교체
- [[ISS-0104-card-base-to-tailwind-utilities]] (resolved, GitHub #187) — 남은 `card-base` 커스텀 CSS를 Tailwind 유틸리티로 교체
- [[ISS-0105-answer-feedback-screen-ui-overhaul]] (resolved, GitHub #189) — 단일 문제 결과 화면(AnswerFeedback) UI 전면 개선
- [[ISS-0106-error-state-ui-overhaul]] (resolved, GitHub #190) — 에러 상태 UI 전면 개선 (ErrorFallback·홈 인라인 에러·버튼 통일)
- [[ISS-0112-settings-screen-ui-content-boost]] (resolved, GitHub #198) — 설정 화면 UI 개선 — 콘텐츠 보강과 시각적 완성도
- [[ISS-0114-ai-report-padding-button-unify]] (resolved, GitHub #205) — AI 리포트 화면 좌우 패딩 이상과 버튼 스타일 공통화
- [[ISS-0116-feedback-settings-subpage-split]] (resolved, GitHub #209) — 건의사항을 설정 서브페이지로 분리
- [[ISS-0118-settings-flat-list-redesign]] (resolved, GitHub #211) — Settings 페이지 flat 스타일 리디자인
- [[ISS-0123-stem-card-choice-card-distinction]] (resolved, GitHub #224) — 지문 카드와 선택지 카드 시각적 구분
- [[ISS-0131-markdown-rendering-ai-text]] (resolved, GitHub #237) — AI 피드백·해설·지문의 Markdown 서식이 깨져 보임
- [[ISS-0136-result-card-correct-wrong-colors]] (resolved, GitHub #251) — 결과 화면 정답/오답 카드 구분이 불분명
- [[ISS-0150-tailwind4-spacing-namespace-login-layout]] (resolved, GitHub #277) — Tailwind 4 `@theme --spacing-*` 충돌로 로그인 페이지 레이아웃 파괴
- [[ISS-0157-star-rating-shows-three-stars]] (resolved, GitHub #292) — `StarRating` 컴포넌트가 난이도 5점 만점을 별 3개로만 표시
- [[ISS-0164-home-section-title-css-unify]] (resolved, GitHub #307) — 홈 섹션 타이틀 CSS 통일 및 에러 상태 제목 누락
- [[ISS-0165-settings-logout-button-ux]] (resolved, GitHub #308) — 설정 페이지 로그아웃 버튼 UX 개선
- [[ISS-0170-app-icon-favicon-registration]] (resolved, GitHub #317) — 앱 아이콘 제작 및 GitHub·브라우저 등록
- [[ISS-0193-login-settings-redesign-wrong-notes]] (resolved, GitHub #348) — 로그인·설정 화면 디자인 개선 및 오답 노트 화면 분리
- [[ISS-0211-nickname-sheet-infinite-width]] (resolved, GitHub #366) — 닉네임 변경 시트가 열리지 않음 — 중복확인 버튼 무한 폭 제약으로 레이아웃 예외
- [[ISS-0212-bottom-tab-icons-only]] (resolved, GitHub #367) — 하단 탭 바 글자 제거 — 아이콘만 표시
- [[ISS-0230-web-react-router-default-error-screen]] (resolved, GitHub #397) — 없는 경로에서 React Router 개발자 에러 화면이 노출됨 (웹)
- [[ISS-0234-web-login-contrast-layout-shift]] (resolved, GitHub #401) — 로그인 화면 약관 링크·오류 문구 대비 부족과 오류 표시 시 레이아웃 밀림 (웹)
- [[ISS-0237-gh-pages-mobile-layout-meta]] (resolved, GitHub #404) — 소개 페이지(gh-pages) 모바일 레이아웃 깨짐과 메타 누락
- [[ISS-0241-admin-mobile-horizontal-overflow]] (resolved, GitHub #409) — 관리자 모바일 폭에서 문제·건의사항·신고 화면 가로 넘침
- [[ISS-0252-app-topic-card-icons]] (resolved, GitHub #446) — 앱 토픽 선택 카드에 토픽별 아이콘이 없음
- [[ISS-0253-topic-card-design-request]] (resolved, GitHub #447) — 앱 문제 탭 토픽 선택 카드 디자인 요청
- [[ISS-0256-app-apple-style-redesign-dark-mode]] (resolved, GitHub #450) — 앱 UI 일관성 붕괴 — Apple풍 디자인 시스템과 다크 모드로 전면 재디자인
- [[ISS-0259-dark-mode-logo-white-background]] (resolved, GitHub #453) — 다크 모드에서 passQL 로고가 흰 배경으로 보이고 로그인 로고가 텍스트로 대체됨
- [[ISS-0260-tab-bar-bottom-padding-reduce]] (resolved, GitHub #454) — 하단 탭바 아래 빈 공간이 지나치게 큼
- [[ISS-0261-app-theme-mode-setting]] (resolved, GitHub #455) — 앱에서 라이트/다크/시스템 화면 모드를 고를 수 없음
- [[ISS-0264-architecture-audit-commonization-refactor]] (resolved, GitHub #458) — 아키텍처 검수 — 같은 대상이 스택마다 사본이라 수정 누락 반복
- [[ISS-0265-brand-assets-single-source]] (resolved, GitHub #459) — 브랜드 자산 사본이 플랫폼마다 따로 있어 수정이 빠짐
- [[ISS-0267-app-component-layer-passql-rename]] (resolved, GitHub #461) — 앱 공통 컴포넌트 우회·역방향 의존·불명확한 `Pq` 이름
- [[ISS-0268-web-brand-color-token-lint]] (resolved, GitHub #462) — 웹 브랜드 색이 앱과 다르고 hex·인라인 style이 흩어짐, 약관 사본
- [[ISS-0291-remove-unused-fonts-register-code-font]] (resolved, GitHub #485) — 앱 미사용 폰트와 미등록 코드 폰트
- [[ISS-0292-text-scale-accessibility]] (resolved, GitHub #486) — 앱 글자 크기 확대 대응과 접근성 부족
- [[ISS-0300-app-motion-system-reveal-badges]] (resolved, GitHub #495) — 앱 모션 시스템 부재와 화면 연출 부족 (등장, 태그, AI 해설, AI 통계)
- [[ISS-0326-home-top-bar-redesign]] (resolved, GitHub #530) — 홈 상단 재설계 — 로고·알림 버튼 상단 바, 잘리는 환영 문구
- [[ISS-0340-progress-bar-grows-from-center]] (resolved, GitHub #552) — 진행 막대가 가운데서 자라고 회색 트랙이 안 보임
- [[ISS-0342-choice-card-layout-jump-table-font]] (resolved, GitHub #554) — 채점 후 보기 카드 레이아웃 점프와 결과 표 글꼴 다듬기
- [[ISS-0356-home-questions-tab-restructure]] (resolved, GitHub #574) — 홈, 문제 탭 재구성 — 출제 경향 분리 및 오답 노트 이동 (이후 앱 전체 발견성·접근성 개편으로 확장)
- [[ISS-0362-bottom-sheet-close-x-center-title]] (resolved, GitHub #601) — 바텀시트 닫기 X 제거와 제목 가운데 정렬
- [[ISS-0363-app-wide-ui-ux-cleanup]] (resolved, GitHub #602) — 앱 전체 UI/UX 정리 — 화면별 검수 결과와 개선안(기기 크기 대응 포함)
- [[ISS-0380-admin-global-search-badges-layout]] (resolved, GitHub #625) — 관리자 전역 검색·미처리 뱃지가 없고 다크모드가 OS를 따르지 않으며 CDN 장애 시 화면이 깨짐
- [[ISS-0402-login-buttons-bottom-disabled-state]] (resolved, GitHub #668) — 로그인 화면 버튼 하단 배치와 로그인 중 버튼 비활성 표시
- [[ISS-0404-remove-login-logout-transition]] (resolved, GitHub #672) — 로그인·로그아웃 화면 전환 애니메이션 제거
- [[ISS-0409-radius-tokens-nickname-edit-cleanup]] (resolved, GitHub #687) — 모서리, 닉네임 편집 정리 (앱)
- [[ISS-0413-app-home-ui-ux-redesign]] (resolved, GitHub #701) — 앱 홈 화면 UI/UX 개편
- [[ISS-0420-questions-tab-trend-section-layout]] (resolved, GitHub #726) — 문제 탭 경향 화면 구간 개편 (앱)
- [[ISS-0428-app-profile-tab-redesign]] (resolved, GitHub #749) — 앱 내 프로필 탭 UI/UX 개편 (정보 위계 재구성, passQL PASS 탑승권)
