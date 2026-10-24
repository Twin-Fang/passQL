/**
 * 관리자 차트 공통: Chart.js 기본값, daisyUI 테마 색, 테마 전환 시 다시 그리기, 일/월 토글, 포맷터, 블록 상태 표시, 코드 표시 이름
 * 페이지 JS 는 AdminChart·AdminDisplayLabels 만 사용 (Chart.js 미로드 화면에서도 포맷터·라벨·상태 표시는 동작)
 */
(function () {
    'use strict';

    // 차트 색 키 > daisyUI 5 테마 CSS 변수
    const THEME_COLOR_VARIABLE_BY_KEY = {
        primary: '--color-primary',
        secondary: '--color-secondary',
        accent: '--color-accent',
        neutral: '--color-neutral',
        info: '--color-info',
        success: '--color-success',
        warning: '--color-warning',
        error: '--color-error',
        baseContent: '--color-base-content',
        baseSurface: '--color-base-100'
    };
    // 변수를 못 읽을 때 대체 색 (daisyUI light 기본값 근사)
    const FALLBACK_COLOR_BY_KEY = {
        primary: '#605dff', secondary: '#f43098', accent: '#00d3bb', neutral: '#09090b',
        info: '#00bafe', success: '#00d390', warning: '#fcb700', error: '#ff637d',
        baseContent: '#18181b', baseSurface: '#ffffff'
    };
    // 축·범례 글자 크기 (px), 범례 색 상자 크기 (px)
    const CHART_FONT_SIZE_PIXELS = 11;
    const LEGEND_BOX_SIZE_PIXELS = 10;
    // 보조 글자·격자선 불투명도 (base-content 기준)
    const MUTED_TEXT_ALPHA = 0.7;
    const GRID_LINE_ALPHA = 0.08;
    const MILLISECONDS_PER_SECOND = 1000;
    const TOKEN_COUNT_PER_MILLION = 1000000;
    const TOKEN_COUNT_PER_THOUSAND = 1000;
    // 예산 사용률 경고·초과 기준 (%)
    const BUDGET_WARNING_PERCENT = 70;
    const BUDGET_EXCEEDED_PERCENT = 100;
    // 예산 알림 띠 표시 시작 기준 (%)
    const BUDGET_ALERT_PERCENT = 80;
    // 블록 상태 덮개 식별자 (data-role)
    const BLOCK_STATE_ROLE = 'block-state';

    // canvas > { chart, buildConfiguration } (테마 전환 시 같은 구성으로 다시 생성)
    const registeredChartByCanvas = new Map();
    // 블록 컨테이너 > 마지막 요청 번호 (늦게 온 이전 응답 무시용)
    const latestRequestSequenceByContainer = new WeakMap();
    const numberFormatterByFractionDigits = new Map();
    const usdFormatter = new Intl.NumberFormat('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    let colorProbeContext = null;

    function hasChartLibrary() {
        return typeof window.Chart === 'function';
    }

    // ── 테마 색 ──

    /** CSS 색(oklch 등) > [r, g, b] (1x1 canvas 에 칠해 읽음, Chart.js 가 oklch 를 해석하지 못해서) */
    function toRgbChannels(cssColor) {
        if (!colorProbeContext) {
            const probeCanvas = document.createElement('canvas');
            probeCanvas.width = 1;
            probeCanvas.height = 1;
            colorProbeContext = probeCanvas.getContext('2d', { willReadFrequently: true });
        }
        colorProbeContext.clearRect(0, 0, 1, 1);
        colorProbeContext.fillStyle = '#000000';
        colorProbeContext.fillStyle = cssColor;
        colorProbeContext.fillRect(0, 0, 1, 1);
        const pixel = colorProbeContext.getImageData(0, 0, 1, 1).data;
        return [pixel[0], pixel[1], pixel[2]];
    }

    /** 현재 테마 색 묶음: 키별 rgb 문자열 + translucent(키, 불투명도) + 보조 글자·격자선 색 */
    function readThemeColors() {
        const rootStyle = getComputedStyle(document.documentElement);
        const channelsByKey = {};
        Object.keys(THEME_COLOR_VARIABLE_BY_KEY).forEach(colorKey => {
            const variableValue = rootStyle.getPropertyValue(THEME_COLOR_VARIABLE_BY_KEY[colorKey]).trim();
            channelsByKey[colorKey] = toRgbChannels(variableValue || FALLBACK_COLOR_BY_KEY[colorKey]);
        });
        const translucent = (colorKey, alpha) => {
            const channels = channelsByKey[colorKey] || channelsByKey.primary;
            return 'rgba(' + channels.join(', ') + ', ' + alpha + ')';
        };
        const colors = { translucent };
        Object.keys(channelsByKey).forEach(colorKey => { colors[colorKey] = 'rgb(' + channelsByKey[colorKey].join(', ') + ')'; });
        colors.mutedText = translucent('baseContent', MUTED_TEXT_ALPHA);
        colors.gridLine = translucent('baseContent', GRID_LINE_ALPHA);
        return colors;
    }

    /** Chart.js 전역 기본값 (폰트·범례·선·막대·글자색, 테마 전환마다 다시 적용) */
    function applyChartDefaults(colors) {
        const defaults = window.Chart.defaults;
        defaults.locale = 'ko-KR';
        defaults.font.family = getComputedStyle(document.body).fontFamily || 'system-ui, sans-serif';
        defaults.font.size = CHART_FONT_SIZE_PIXELS;
        defaults.color = colors.mutedText;
        defaults.borderColor = colors.gridLine;
        defaults.maintainAspectRatio = false;
        defaults.interaction.mode = 'index';
        defaults.interaction.intersect = false;
        defaults.plugins.legend.labels.boxWidth = LEGEND_BOX_SIZE_PIXELS;
        defaults.plugins.legend.labels.boxHeight = LEGEND_BOX_SIZE_PIXELS;
        defaults.elements.bar.borderRadius = 4;
        defaults.elements.line.borderWidth = 2;
        defaults.elements.line.tension = 0.3;
        defaults.elements.point.radius = 0;
        defaults.elements.point.hoverRadius = 4;
    }

    // ── 차트 생성·다시 그리기 ──

    /**
     * 차트 1개 그리기: 기존 차트 제거 > buildConfiguration(테마 색) 으로 생성 > 테마 전환 대상 등록
     * 데이터가 바뀔 때마다 다시 호출 (일/월 토글 포함), Chart.js 미로드 시 예외 > loadBlock 오류 덮개
     */
    function renderChart(canvasElement, buildConfiguration) {
        if (!canvasElement) return null;
        if (!hasChartLibrary()) throw new Error('차트 라이브러리를 불러오지 못했습니다.');
        destroyChart(canvasElement);
        const colors = readThemeColors();
        applyChartDefaults(colors);
        const chart = new window.Chart(canvasElement, buildConfiguration(colors));
        registeredChartByCanvas.set(canvasElement, { chart, buildConfiguration });
        return chart;
    }

    function destroyChart(canvasElement) {
        const registered = registeredChartByCanvas.get(canvasElement);
        if (registered) registered.chart.destroy();
        registeredChartByCanvas.delete(canvasElement);
    }

    /** 테마 전환 > 등록된 차트 전부 새 색으로 다시 생성 */
    function redrawAllCharts() {
        if (!hasChartLibrary() || registeredChartByCanvas.size === 0) return;
        const colors = readThemeColors();
        applyChartDefaults(colors);
        registeredChartByCanvas.forEach((registered, canvasElement) => {
            registered.chart.destroy();
            registered.chart = new window.Chart(canvasElement, registered.buildConfiguration(colors));
        });
    }

    // layout.html themeToggle 이 <html data-theme> 를 바꿈 > 다음 프레임에 다시 그리기 (변수 반영 후)
    new MutationObserver(() => requestAnimationFrame(redrawAllCharts))
        .observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });

    // ── 일/월 토글 ──

    /**
     * 토글 버튼 묶음 연결: [data-range] 버튼 클릭 > btn-active 이동 > onRangeSelected(range)
     * 연결 즉시 현재 선택(btn-active, 없으면 첫 버튼)으로 1회 호출
     */
    function bindRangeToggle(groupElement, onRangeSelected) {
        if (!groupElement) return;
        const rangeButtons = Array.from(groupElement.querySelectorAll('button[data-range]'));
        const selectRange = (selectedButton) => {
            rangeButtons.forEach(button => {
                const isSelected = button === selectedButton;
                button.classList.toggle('btn-active', isSelected);
                button.setAttribute('aria-pressed', String(isSelected));
            });
            onRangeSelected(selectedButton.dataset.range);
        };
        rangeButtons.forEach(button => button.addEventListener('click', () => {
            if (!button.classList.contains('btn-active')) selectRange(button);
        }));
        const initialButton = rangeButtons.find(button => button.classList.contains('btn-active')) || rangeButtons[0];
        if (initialButton) selectRange(initialButton);
    }

    // ── 포맷터 (null·NaN > '-') ──

    function isMissingNumber(value) {
        return value === null || value === undefined || value === '' || Number.isNaN(Number(value));
    }

    /** 숫자 > 천 단위 구분 (소수 자리 최대 fractionDigits) */
    function formatNumber(value, fractionDigits = 0) {
        if (isMissingNumber(value)) return '-';
        if (!numberFormatterByFractionDigits.has(fractionDigits)) {
            numberFormatterByFractionDigits.set(fractionDigits,
                new Intl.NumberFormat('ko-KR', { maximumFractionDigits: fractionDigits }));
        }
        return numberFormatterByFractionDigits.get(fractionDigits).format(Number(value));
    }

    /** USD > $1,234.56 (0 초과 0.01 미만은 < $0.01) */
    function formatUsd(value) {
        if (isMissingNumber(value)) return '-';
        const amount = Number(value);
        if (amount > 0 && amount < 0.01) return '< $0.01';
        return '$' + usdFormatter.format(amount);
    }

    /** 밀리초 > 850ms / 1.8s */
    function formatMilliseconds(value) {
        if (isMissingNumber(value)) return '-';
        const milliseconds = Number(value);
        if (milliseconds < MILLISECONDS_PER_SECOND) return formatNumber(Math.round(milliseconds)) + 'ms';
        return formatNumber(milliseconds / MILLISECONDS_PER_SECOND, 1) + 's';
    }

    /** 백분율 > 61.2% */
    function formatPercent(value, fractionDigits = 1) {
        if (isMissingNumber(value)) return '-';
        return formatNumber(value, fractionDigits) + '%';
    }

    /** 토큰 수 > 1.92M / 41.2K / 980 */
    function formatTokenCount(value) {
        if (isMissingNumber(value)) return '-';
        const tokenCount = Number(value);
        if (tokenCount >= TOKEN_COUNT_PER_MILLION) return formatNumber(tokenCount / TOKEN_COUNT_PER_MILLION, 2) + 'M';
        if (tokenCount >= TOKEN_COUNT_PER_THOUSAND * 10) return formatNumber(tokenCount / TOKEN_COUNT_PER_THOUSAND, 1) + 'K';
        return formatNumber(tokenCount);
    }

    /** 서버 LocalDateTime 문자열 > yyyy-MM-dd HH:mm */
    function formatDateTime(localDateTimeText) {
        if (!localDateTimeText) return '-';
        return String(localDateTimeText).replace('T', ' ').substring(0, 16);
    }

    /** 서버 LocalDateTime 문자열 > HH:mm:ss */
    function formatTime(localDateTimeText) {
        if (!localDateTimeText) return '-';
        return String(localDateTimeText).substring(11, 19);
    }

    /** 예산 사용률 > progress 값·색 (70% 이상 경고, 100% 이상 초과) */
    function renderBudgetProgress(progressElement, budgetUsedPercent) {
        if (!progressElement) return;
        const usedPercent = Number(budgetUsedPercent) || 0;
        progressElement.value = Math.min(usedPercent, BUDGET_EXCEEDED_PERCENT);
        progressElement.className = 'progress ' + (usedPercent >= BUDGET_EXCEEDED_PERCENT ? 'progress-error'
            : usedPercent >= BUDGET_WARNING_PERCENT ? 'progress-warning' : 'progress-success');
    }

    /** 예산 사용률 알림 띠 (80% 이상 경고, 100% 이상 초과, 미만이면 숨김, 예산 0 이하면 숨김) */
    function renderBudgetAlert(alertElement, messageElement, budgetUsedPercent, monthlyBudgetUsd, estimatedCostUsd) {
        if (!alertElement) return;
        const usedPercent = Number(budgetUsedPercent) || 0;
        const isExceeded = usedPercent >= BUDGET_EXCEEDED_PERCENT;
        alertElement.hidden = !(Number(monthlyBudgetUsd) > 0) || usedPercent < BUDGET_ALERT_PERCENT;
        alertElement.classList.toggle('alert-error', isExceeded);
        alertElement.classList.toggle('alert-warning', !isExceeded);
        messageElement.textContent = (isExceeded ? 'AI 월 예산을 초과했습니다. ' : 'AI 월 예산에 가까워지고 있습니다. ')
            + formatUsd(estimatedCostUsd) + ' / ' + formatUsd(monthlyBudgetUsd) + ' (' + formatPercent(usedPercent) + ')';
    }

    // ── 블록 상태 표시 (로딩·빈 상태·오류 덮개) ──

    function ensureBlockStateElement(containerElement) {
        let stateElement = containerElement.querySelector(':scope > [data-role="' + BLOCK_STATE_ROLE + '"]');
        if (!stateElement) {
            containerElement.classList.add('relative');
            stateElement = document.createElement('div');
            stateElement.dataset.role = BLOCK_STATE_ROLE;
            stateElement.className = 'absolute inset-0 z-10 flex items-center justify-center gap-2 p-4 text-sm text-center rounded-box bg-base-100/85';
            containerElement.appendChild(stateElement);
        }
        stateElement.hidden = false;
        return stateElement;
    }

    function setBlockState(containerElement, message, toneClass, hasSpinner) {
        if (!containerElement) return;
        const stateElement = ensureBlockStateElement(containerElement);
        stateElement.classList.remove('text-error', 'text-base-content/50');
        stateElement.classList.add(toneClass);
        stateElement.replaceChildren();
        if (hasSpinner) {
            const spinner = document.createElement('span');
            spinner.className = 'loading loading-spinner loading-sm';
            stateElement.appendChild(spinner);
        }
        const textElement = document.createElement('span');
        textElement.textContent = message;
        stateElement.appendChild(textElement);
    }

    function showBlockLoading(containerElement) {
        setBlockState(containerElement, '불러오는 중...', 'text-base-content/50', true);
    }

    function showBlockEmpty(containerElement, message) {
        setBlockState(containerElement, message || '표시할 데이터가 없습니다.', 'text-base-content/50', false);
    }

    /** 오류 덮개 (AdminApiError 는 서버 message 그대로) */
    function showBlockError(containerElement, error, fallbackMessage) {
        const message = (error && error.message) || fallbackMessage || '불러오지 못했습니다.';
        setBlockState(containerElement, message, 'text-error', false);
    }

    function clearBlockState(containerElement) {
        if (!containerElement) return;
        const stateElement = containerElement.querySelector(':scope > [data-role="' + BLOCK_STATE_ROLE + '"]');
        if (stateElement) stateElement.hidden = true;
    }

    /**
     * 블록 1개 불러오기: 로딩 > fetch > render(응답) > 덮개 제거, 실패 시 오류 덮개 (다른 블록과 독립)
     * render 가 false 를 돌려주면 빈 상태 덮개, 같은 블록의 늦게 온 이전 응답은 버림 (일/월 연타)
     */
    async function loadBlock(containerElement, url, render, emptyMessage) {
        const requestSequence = (latestRequestSequenceByContainer.get(containerElement) || 0) + 1;
        latestRequestSequenceByContainer.set(containerElement, requestSequence);
        const isLatestRequest = () => latestRequestSequenceByContainer.get(containerElement) === requestSequence;
        showBlockLoading(containerElement);
        try {
            const responseBody = await window.AdminApi.get(url);
            if (!isLatestRequest()) return;
            const hasContent = render(responseBody || {});
            if (hasContent === false) showBlockEmpty(containerElement, emptyMessage);
            else clearBlockState(containerElement);
        } catch (error) {
            if (isLatestRequest()) showBlockError(containerElement, error);
        }
    }

    window.AdminChart = {
        hasChartLibrary,
        readThemeColors,
        renderChart,
        destroyChart,
        bindRangeToggle,
        formatNumber,
        formatUsd,
        formatMilliseconds,
        formatPercent,
        formatTokenCount,
        formatDateTime,
        formatTime,
        renderBudgetProgress,
        renderBudgetAlert,
        showBlockLoading,
        showBlockEmpty,
        showBlockError,
        clearBlockState,
        loadBlock
    };

    // ── 서버 코드값 > 화면 표시 이름 (관리자 대시보드·통계·게시글 공통 단일 원본) ──
    window.AdminDisplayLabels = {
        // CommunityBoardType
        boardTypeLabelByCode: { QUESTION_OPINION: '문제 의견', EXAM_REVIEW: '시험 후기', FREE: '자유', QNA: '질문' },
        // CommunityPostStatus
        postStatusLabelByCode: { VISIBLE: '노출', HIDDEN_AUTO: '자동 숨김', HIDDEN_ADMIN: '관리자 숨김', DELETED: '삭제' },
        postStatusBadgeClassByCode: { VISIBLE: 'badge-success', HIDDEN_AUTO: 'badge-warning', HIDDEN_ADMIN: 'badge-error', DELETED: 'badge-neutral' },
        // ai_call_log.call_source
        callSourceLabelByCode: { AI_SERVER: 'AI 서버', GEMINI_DIRECT: 'Gemini 직접' },
        // member AuthProvider
        authProviderLabelByCode: { GOOGLE: 'Google', KAKAO: '카카오', NAVER: '네이버', APPLE: 'Apple', GITHUB: 'GitHub' },
        /** 코드 > 표시 이름 (매핑 없으면 코드 그대로, 비었으면 '-') */
        toLabel(labelByCode, code) {
            if (code === null || code === undefined || code === '') return '-';
            return labelByCode[code] || String(code);
        }
    };
})();
