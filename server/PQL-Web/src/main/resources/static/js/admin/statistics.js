/**
 * 관리자 AI 사용량·통계: 월 선택 > 요약 카드·모델별·기능별·단가표, 가입 경로별 월 가입 누적 막대
 * API: /admin/api/statistics/ai-monthly?month=yyyy-MM, /admin/api/statistics/signups-by-provider (블록별 독립 fetch)
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/statistics';
    // 가입 경로 > 차트 색 키 (서비스 대표색에 가깝게 고정, Apple 은 글자색이라 다크에서도 보임, 목록 밖 경로는 accent)
    const COLOR_KEY_BY_AUTH_PROVIDER = { GOOGLE: 'info', KAKAO: 'warning', NAVER: 'success', APPLE: 'baseContent', GITHUB: 'secondary' };
    const FALLBACK_PROVIDER_COLOR_KEY = 'accent';

    const { renderChart, loadBlock, formatNumber, formatUsd, formatMilliseconds, formatPercent, formatTokenCount, renderBudgetProgress } = AdminChart;
    const labels = AdminDisplayLabels;
    const escapeHtml = AdminUi.escapeHtml;
    const monthInput = document.getElementById('statisticsMonth');

    /** 오늘 > yyyy-MM (로컬 시각 기준) */
    function toCurrentMonthText() {
        const today = new Date();
        return today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0');
    }

    /** 표 본문 채우기 (비었으면 안내 1행) */
    function renderTableRows(tableBodyId, rows, columnCount, buildRow, emptyMessage) {
        const tableBody = document.getElementById(tableBodyId);
        if (!rows || rows.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="' + columnCount + '" class="text-center text-base-content/50 py-6">' + emptyMessage + '</td></tr>';
            return;
        }
        tableBody.innerHTML = rows.map(buildRow).join('');
    }

    function numberCell(text) {
        return '<td class="text-right whitespace-nowrap">' + text + '</td>';
    }

    function failureCell(failureCount) {
        return '<td class="text-right' + (Number(failureCount) > 0 ? ' text-error font-bold' : '') + '">' + formatNumber(failureCount) + '</td>';
    }

    // ── 요약 카드 4개 ──
    function renderSummary(aiMonthly) {
        const totalCallCount = Number(aiMonthly.totalCallCount) || 0;
        const totalFailureCount = Number(aiMonthly.totalFailureCount) || 0;
        document.getElementById('totalCallCount').textContent = formatNumber(totalCallCount);
        const failureCountElement = document.getElementById('totalFailureCount');
        failureCountElement.textContent = formatNumber(totalFailureCount);
        failureCountElement.classList.toggle('text-error', totalFailureCount > 0);
        document.getElementById('failureRate').textContent = '실패율 '
            + formatPercent(totalCallCount > 0 ? totalFailureCount / totalCallCount * 100 : 0);

        const promptTokenCount = Number(aiMonthly.totalPromptTokenCount) || 0;
        const completionTokenCount = Number(aiMonthly.totalCompletionTokenCount) || 0;
        document.getElementById('totalTokenCount').textContent = formatTokenCount(promptTokenCount + completionTokenCount);
        document.getElementById('tokenBreakdown').textContent = '입력 ' + formatTokenCount(promptTokenCount) + ' · 출력 ' + formatTokenCount(completionTokenCount);

        const estimatedCostUsd = Number(aiMonthly.totalEstimatedCostUsd) || 0;
        const monthlyBudgetUsd = Number(aiMonthly.monthlyBudgetUsd) || 0;
        const budgetUsedPercent = monthlyBudgetUsd > 0 ? estimatedCostUsd / monthlyBudgetUsd * 100 : 0;
        document.getElementById('totalEstimatedCost').textContent = formatUsd(estimatedCostUsd);
        renderBudgetProgress(document.getElementById('budgetProgress'), budgetUsedPercent);
        document.getElementById('budgetSummary').textContent = monthlyBudgetUsd > 0
            ? '월 예산 ' + formatUsd(monthlyBudgetUsd) + ' 대비 ' + formatPercent(budgetUsedPercent)
            : '월 예산 미설정';
    }

    // ── 모델별·기능별·단가표 ──
    function renderByModel(byModel) {
        renderTableRows('byModelBody', byModel, 6, modelUsage =>
            '<tr><td class="font-mono text-xs break-all">' + escapeHtml(modelUsage.modelName || '(모델 미기록)') + '</td>'
            + numberCell(formatNumber(modelUsage.callCount))
            + failureCell(modelUsage.failureCount)
            + numberCell(formatNumber(modelUsage.promptTokenCount))
            + numberCell(formatNumber(modelUsage.completionTokenCount))
            + numberCell(modelUsage.isPriceRegistered ? formatUsd(modelUsage.estimatedCostUsd)
                : '<span class="badge badge-xs badge-warning">단가 미등록</span>') + '</tr>',
        '이 달 호출 기록이 없습니다.');
    }

    function renderByEndpoint(byEndpoint) {
        renderTableRows('byEndpointBody', byEndpoint, 8, endpointUsage =>
            '<tr><td class="whitespace-nowrap"><span class="badge badge-sm badge-ghost">'
            + escapeHtml(labels.toLabel(labels.callSourceLabelByCode, endpointUsage.callSource)) + '</span></td>'
            + '<td class="font-mono text-xs break-all">' + escapeHtml(endpointUsage.endpointPath || '-') + '</td>'
            + numberCell(formatNumber(endpointUsage.callCount))
            + failureCell(endpointUsage.failureCount)
            + numberCell(formatMilliseconds(endpointUsage.averageLatencyMilliseconds))
            + numberCell(formatNumber(endpointUsage.promptTokenCount))
            + numberCell(formatNumber(endpointUsage.completionTokenCount))
            + numberCell(formatUsd(endpointUsage.estimatedCostUsd)) + '</tr>',
        '이 달 호출 기록이 없습니다.');
    }

    function renderPriceTable(priceTable) {
        renderTableRows('priceTableBody', priceTable, 3, modelPrice =>
            '<tr><td class="font-mono text-xs break-all">' + escapeHtml(modelPrice.modelName) + '</td>'
            + numberCell(formatUsd(modelPrice.inputUsdPerMillion))
            + numberCell(formatUsd(modelPrice.outputUsdPerMillion)) + '</tr>',
        '등록된 단가가 없습니다. 앱 설정에서 ai.model_price_table 을 등록하세요.');
    }

    function loadAiMonthly() {
        const month = monthInput.value || toCurrentMonthText();
        loadBlock(document.getElementById('aiMonthlyBlock'), API_BASE + '/ai-monthly?month=' + encodeURIComponent(month), aiMonthly => {
            renderSummary(aiMonthly);
            renderByModel(aiMonthly.byModel);
            renderByEndpoint(aiMonthly.byEndpoint);
            renderPriceTable(aiMonthly.priceTable);
            return true;
        });
    }

    // ── 가입 경로별 월 가입 (누적 막대, 경로 색 고정) ──
    function loadSignupsByProvider() {
        const chartBox = document.getElementById('signupProviderChartBox');
        loadBlock(chartBox, API_BASE + '/signups-by-provider', signupsByProvider => {
            const series = signupsByProvider.series || [];
            if (!Array.isArray(signupsByProvider.labels) || signupsByProvider.labels.length === 0 || series.length === 0) return false;
            renderChart(document.getElementById('signupProviderChart'), colors => ({
                type: 'bar',
                data: {
                    labels: signupsByProvider.labels,
                    datasets: series.map(providerSeries => ({
                        label: labels.toLabel(labels.authProviderLabelByCode, providerSeries.authProvider),
                        data: providerSeries.counts,
                        backgroundColor: colors[COLOR_KEY_BY_AUTH_PROVIDER[providerSeries.authProvider] || FALLBACK_PROVIDER_COLOR_KEY],
                        stack: 'signups'
                    }))
                },
                options: {
                    scales: { x: { stacked: true }, y: { stacked: true, beginAtZero: true, ticks: { precision: 0 }, title: { display: true, text: '가입 수' } } },
                    plugins: { tooltip: { callbacks: { footer: items => '합계 ' + formatNumber(items.reduce((sum, item) => sum + (Number(item.raw) || 0), 0)) } } }
                }
            }));
            return true;
        }, '가입 기록이 없습니다.');
    }

    // ── 시작: 월 기본값 이번 달, 바꾸면 AI 통계만 다시 조회 ──
    monthInput.value = toCurrentMonthText();
    monthInput.max = toCurrentMonthText();
    monthInput.addEventListener('change', () => { if (monthInput.value) loadAiMonthly(); });
    loadAiMonthly();
    loadSignupsByProvider();
})();
