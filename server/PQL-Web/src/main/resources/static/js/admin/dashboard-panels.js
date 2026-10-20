/**
 * 관리자 대시보드 패널: 지금·오늘 KPI(30초 폴링, 탭 숨김이면 멈춤) + 토론 신고 대기 배지, AI API 상태
 * API: /admin/api/dashboard/realtime, /admin/api/dashboard/ai-status (블록마다 독립 fetch)
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/dashboard';
    // KPI 자동 갱신 주기 (30초)
    const REALTIME_REFRESH_MILLISECONDS = 30000;
    const MILLISECONDS_PER_MINUTE = 60000;

    const { formatNumber, formatUsd, formatMilliseconds, formatPercent, formatTokenCount, formatTime, loadBlock, renderBudgetProgress } = AdminChart;
    const escapeHtml = AdminUi.escapeHtml;

    // ── 지금·오늘 KPI 카드 6개: 제목, 값 색, 값 키, 보조 문구 ──
    const REALTIME_CARD_DEFINITIONS = [
        { key: 'online', title: '지금 접속 중', valueClass: '', hasLiveDot: true,
            readValue: realtime => realtime.onlineMemberCount, buildCaption: () => captionOf('최근 5분 안에 요청한 회원') },
        { key: 'visitor', title: '오늘 방문자', valueClass: 'text-primary',
            readValue: realtime => realtime.todayVisitorCount, buildCaption: buildVisitorCaption },
        { key: 'signup', title: '오늘 신규 가입', valueClass: 'text-info',
            readValue: realtime => realtime.todaySignupCount,
            buildCaption: realtime => captionOf('어제 ' + formatNumber(realtime.yesterdaySignupCount)
                + ' · 7일 평균 ' + formatNumber(realtime.sevenDayAverageSignupCount, 1)) },
        { key: 'submission', title: '오늘 제출', valueClass: 'text-success',
            readValue: realtime => realtime.todaySubmissionCount,
            buildCaption: realtime => captionOf('정답률 ' + formatPercent(realtime.todayCorrectRatePercent, 0)) },
        { key: 'aiCall', title: '오늘 AI 호출', valueClass: 'text-warning',
            readValue: realtime => realtime.todayAiCallCount,
            buildCaption: realtime => captionOf('실패 ' + formatNumber(realtime.todayAiFailureCount)
                + ' · 평균 ' + formatMilliseconds(realtime.todayAiAverageLatencyMilliseconds),
                realtime.todayAiFailureCount > 0 ? 'text-error' : '') },
        { key: 'communityPost', title: '오늘 토론 새 글', valueClass: '',
            readValue: realtime => realtime.todayCommunityPostCount,
            buildCaption: realtime => captionOf('신고 대기 ' + formatNumber(realtime.pendingCommunityReportCount),
                realtime.pendingCommunityReportCount > 0 ? 'text-warning' : '') }
    ];

    const realtimeCards = document.getElementById('realtimeCards');
    const realtimeGeneratedAt = document.getElementById('realtimeGeneratedAt');
    const pendingCommunityReportBadge = document.getElementById('pendingCommunityReportBadge');
    let realtimeTimerId = null;
    let isRealtimeLoading = false;

    function captionOf(text, toneClass) {
        return { text, toneClass: toneClass || '' };
    }

    /** 오늘 방문자 <-> 어제 같은 시각 증감률 */
    function buildVisitorCaption(realtime) {
        const yesterdayCount = Number(realtime.yesterdaySameTimeVisitorCount) || 0;
        if (yesterdayCount === 0) return captionOf('어제 같은 시각 ' + formatNumber(realtime.yesterdaySameTimeVisitorCount));
        const changePercent = Math.round((Number(realtime.todayVisitorCount) - yesterdayCount) / yesterdayCount * 100);
        const sign = changePercent > 0 ? '+' : '';
        return captionOf('어제 같은 시각보다 ' + sign + changePercent + '%', changePercent >= 0 ? 'text-success' : 'text-error');
    }

    /** 카드 골격 6개 (값 '-') */
    function renderRealtimeCardSkeletons() {
        realtimeCards.innerHTML = REALTIME_CARD_DEFINITIONS.map(definition =>
            '<div class="card bg-base-100 shadow-sm"><div class="card-body p-4 gap-1">'
            + '<span class="text-xs text-base-content/60">' + escapeHtml(definition.title) + '</span>'
            + '<div class="flex items-center gap-2">'
            + (definition.hasLiveDot ? '<span class="inline-block size-2 rounded-full bg-success animate-pulse" aria-hidden="true"></span>' : '')
            + '<span class="text-3xl font-bold ' + definition.valueClass + '" data-realtime-value="' + definition.key + '">-</span></div>'
            + '<span class="text-xs text-base-content/50" data-realtime-caption="' + definition.key + '">&nbsp;</span>'
            + '</div></div>').join('');
    }

    function renderRealtime(realtime) {
        REALTIME_CARD_DEFINITIONS.forEach(definition => {
            realtimeCards.querySelector('[data-realtime-value="' + definition.key + '"]').textContent = formatNumber(definition.readValue(realtime));
            const captionElement = realtimeCards.querySelector('[data-realtime-caption="' + definition.key + '"]');
            const caption = definition.buildCaption(realtime);
            captionElement.textContent = caption.text;
            captionElement.className = 'text-xs ' + (caption.toneClass || 'text-base-content/50');
        });
        renderPendingCommunityReportBadge(realtime.pendingCommunityReportCount);
        realtimeGeneratedAt.textContent = '기준 ' + formatTime(realtime.generatedAt);
        realtimeGeneratedAt.classList.remove('text-error');
    }

    /** 처리 필요 띠의 토론 신고 대기 배지 (0이면 회색) */
    function renderPendingCommunityReportBadge(pendingCount) {
        if (!pendingCommunityReportBadge) return;
        pendingCommunityReportBadge.textContent = '토론 신고 대기 · ' + formatNumber(pendingCount);
        const hasPending = Number(pendingCount) > 0;
        pendingCommunityReportBadge.classList.toggle('badge-warning', hasPending);
        pendingCommunityReportBadge.classList.toggle('badge-ghost', !hasPending);
    }

    /** realtime 1회 조회 (실패 시 이전 값 유지 + 갱신 실패 표시, 중복 요청 방지) */
    async function loadRealtime() {
        if (isRealtimeLoading) return;
        isRealtimeLoading = true;
        try {
            renderRealtime(await AdminApi.get(API_BASE + '/realtime') || {});
        } catch (error) {
            realtimeGeneratedAt.textContent = '갱신 실패 · ' + (error.message || '불러오지 못했습니다.');
            realtimeGeneratedAt.classList.add('text-error');
        } finally {
            isRealtimeLoading = false;
        }
    }

    function startRealtimePolling() {
        stopRealtimePolling();
        loadRealtime();
        realtimeTimerId = setInterval(loadRealtime, REALTIME_REFRESH_MILLISECONDS);
    }

    function stopRealtimePolling() {
        if (realtimeTimerId !== null) clearInterval(realtimeTimerId);
        realtimeTimerId = null;
    }

    // ── AI API 상태 ──

    /** 배지 1개 갱신 (색 클래스 + 문구 + 툴팁) */
    function setStatusBadge(badgeElement, badgeClass, text, tooltip) {
        badgeElement.className = 'badge badge-sm whitespace-nowrap ' + badgeClass;
        badgeElement.textContent = text;
        badgeElement.title = tooltip || '';
    }

    /** 확인 시각 > 'N분 전 확인' */
    function toCheckedAgoText(checkedAt) {
        if (!checkedAt) return '';
        const elapsedMilliseconds = Date.now() - new Date(checkedAt).getTime();
        if (Number.isNaN(elapsedMilliseconds)) return '';
        const elapsedMinutes = Math.max(0, Math.floor(elapsedMilliseconds / MILLISECONDS_PER_MINUTE));
        return elapsedMinutes === 0 ? '방금 확인' : elapsedMinutes + '분 전 확인';
    }

    function renderAiComponentBadges(aiStatus) {
        const aiServer = aiStatus.aiServer || {};
        setStatusBadge(document.getElementById('aiServerBadge'),
            aiServer.isUp ? 'badge-success' : 'badge-error',
            aiServer.isUp ? '정상 · ' + formatMilliseconds(aiServer.latencyMilliseconds) : '응답 없음', aiServer.detail);

        // 서킷 상태: CLOSED 정상, HALF_OPEN 회복 시도, OPEN 차단
        const circuitBadgeClassByState = { CLOSED: 'badge-success', HALF_OPEN: 'badge-warning', OPEN: 'badge-error' };
        setStatusBadge(document.getElementById('circuitStateBadge'),
            circuitBadgeClassByState[aiStatus.circuitState] || 'badge-ghost', aiStatus.circuitState || '-');

        // Gemini 키: true 유효, false 확인 필요, null 미확인
        const geminiKey = aiStatus.geminiKey || {};
        const geminiKeyDetail = document.getElementById('geminiKeyDetail');
        const checkedAgoText = toCheckedAgoText(geminiKey.checkedAt);
        if (geminiKey.isValid === true) {
            setStatusBadge(document.getElementById('geminiKeyBadge'), 'badge-success', '유효' + (checkedAgoText ? ' · ' + checkedAgoText : ''), geminiKey.detail);
        } else if (geminiKey.isValid === false) {
            setStatusBadge(document.getElementById('geminiKeyBadge'), 'badge-error', '확인 필요' + (checkedAgoText ? ' · ' + checkedAgoText : ''), geminiKey.detail);
        } else {
            setStatusBadge(document.getElementById('geminiKeyBadge'), 'badge-ghost', '미확인', geminiKey.detail);
        }
        geminiKeyDetail.hidden = !(geminiKey.isValid === false && geminiKey.detail);
        geminiKeyDetail.textContent = geminiKey.detail || '';
    }

    /** 최근 24시간 실패 원인 4종 (0 초과면 강조) */
    function renderFailureBreakdown(failureBreakdown) {
        const breakdown = failureBreakdown || {};
        const failureCategories = [
            { label: '429 한도 초과', count: breakdown.quotaExceededCount },
            { label: '403 결제·권한', count: breakdown.permissionDeniedCount },
            { label: '시간 초과·5xx', count: breakdown.timeoutOrServerErrorCount },
            { label: '기타', count: breakdown.otherCount }
        ];
        document.getElementById('failureBreakdown').innerHTML = failureCategories.map(category =>
            '<div class="rounded-box bg-base-200 p-2">'
            + '<div class="text-lg font-bold' + (Number(category.count) > 0 ? ' text-error' : '') + '">' + formatNumber(category.count) + '</div>'
            + '<div class="text-[11px] text-base-content/60">' + category.label + '</div></div>').join('');
    }

    /** 이번 달 토큰·예산 사용률·모델별 비용 */
    function renderMonthCost(aiStatus) {
        document.getElementById('monthTokenSummary').textContent =
            '입력 ' + formatTokenCount(aiStatus.monthPromptTokenCount) + ' · 출력 ' + formatTokenCount(aiStatus.monthCompletionTokenCount);

        const budgetUsedPercent = Number(aiStatus.budgetUsedPercent) || 0;
        const hasBudget = Number(aiStatus.monthlyBudgetUsd) > 0;
        renderBudgetProgress(document.getElementById('budgetProgress'), budgetUsedPercent);
        document.getElementById('budgetSummary').textContent = hasBudget
            ? '월 예산 ' + formatUsd(aiStatus.monthlyBudgetUsd) + ' 대비 ' + formatPercent(budgetUsedPercent) + ' · 추정 비용 ' + formatUsd(aiStatus.monthEstimatedCostUsd)
            : '월 예산 미설정 · 추정 비용 ' + formatUsd(aiStatus.monthEstimatedCostUsd);

        const costByModel = aiStatus.costByModel || [];
        const costTableBody = document.getElementById('costByModelBody');
        if (costByModel.length === 0) {
            costTableBody.innerHTML = '<tr><td colspan="4" class="text-center text-base-content/50">이번 달 호출 없음</td></tr>';
            return;
        }
        costTableBody.innerHTML = costByModel.map(modelCost =>
            '<tr><td class="font-mono break-all">' + escapeHtml(modelCost.modelName || '(모델 미기록)') + '</td>'
            + '<td class="text-right">' + formatNumber(modelCost.callCount) + '</td>'
            + '<td class="text-right whitespace-nowrap">' + formatTokenCount(modelCost.promptTokenCount) + ' / ' + formatTokenCount(modelCost.completionTokenCount) + '</td>'
            + '<td class="text-right whitespace-nowrap">' + (modelCost.isPriceRegistered
                ? formatUsd(modelCost.estimatedCostUsd) : '<span class="badge badge-xs badge-warning">단가 미등록</span>') + '</td></tr>').join('');
    }

    function loadAiStatus() {
        loadBlock(document.getElementById('aiStatusBox'), API_BASE + '/ai-status', aiStatus => {
            renderAiComponentBadges(aiStatus);
            renderFailureBreakdown(aiStatus.failureBreakdown24h);
            renderMonthCost(aiStatus);
            return true;
        });
    }

    // ── 시작: KPI 폴링은 탭이 보일 때만 ──
    renderRealtimeCardSkeletons();
    document.addEventListener('visibilitychange', () => {
        if (document.hidden) stopRealtimePolling();
        else startRealtimePolling();
    });
    if (!document.hidden) startRealtimePolling();
    loadAiStatus();
})();
