/**
 * 관리자 구독·매출 현황: 기간 선택 > 요약 카드, 일별 구매 차트, 상품별 판매, 통화별 금액
 * API: /admin/api/subscriptions/summary?from=&to= (CSV: summary.csv)
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/subscriptions';
    const { renderChart, loadBlock, formatNumber, formatPercent } = AdminChart;
    const escapeHtml = AdminUi.escapeHtml;
    // 스토어 코드 > 표시 이름 (PurchaseStore)
    const STORE_LABEL_BY_CODE = { PLAY: 'Google Play', APP_STORE: 'App Store' };

    /** 현재값·직전값 > "직전 12건 (+8.3%)" 비교 문구 (직전 0 이면 증감률 생략) */
    function toCompareText(currentValue, previousValue) {
        if (!previousValue) return '직전 기간 ' + formatNumber(previousValue);
        const changePercent = (currentValue - previousValue) / previousValue * 100;
        return '직전 기간 ' + formatNumber(previousValue) + ' (' + (changePercent >= 0 ? '+' : '') + formatNumber(changePercent, 1) + '%)';
    }

    function setText(elementId, text) {
        document.getElementById(elementId).textContent = text;
    }

    // ── 요약 카드 6개 ──
    function renderSummary(summary) {
        setText('activeProMemberCount', formatNumber(summary.activeProMemberCount));
        setText('expiringSoonDayCount', formatNumber(summary.expiringSoonDayCount));
        setText('expiringSoonMemberCount', formatNumber(summary.expiringSoonMemberCount));
        setText('purchaseCount', formatNumber(summary.purchaseCount));
        setText('purchaseCountCompare', toCompareText(summary.purchaseCount, summary.previousPurchaseCount));
        setText('revokedPurchaseCount', formatNumber(summary.revokedPurchaseCount));
        setText('revokedPurchaseCountCompare', toCompareText(summary.revokedPurchaseCount, summary.previousRevokedPurchaseCount));
        setText('signupConversionRate', formatPercent(summary.signupConversionRatePercent));
        setText('signupConversionDetail', '구간 가입 ' + formatNumber(summary.signupCount) + '명 중 구매 이력 ' + formatNumber(summary.convertedSignupCount) + '명');
        setText('purchasedMemberRate', formatPercent(summary.purchasedMemberRatePercent));
        setText('purchasedMemberDetail', '전체 ' + formatNumber(summary.totalMemberCount) + '명 중 ' + formatNumber(summary.purchasedMemberCount) + '명');
    }

    // ── 일별 구매 막대 ──
    function renderDailyPurchaseChart(summary) {
        renderChart(document.getElementById('dailyPurchaseChart'), colors => ({
            type: 'bar',
            data: {
                labels: summary.dailyLabels,
                datasets: [{ label: '구매', data: summary.dailyPurchaseCounts, backgroundColor: colors.primary }]
            },
            options: {
                scales: { y: { beginAtZero: true, ticks: { precision: 0 }, title: { display: true, text: '건' } } },
                plugins: { legend: { display: false } }
            }
        }));
    }

    function renderTableRows(tableBodyId, rows, columnCount, buildRow, emptyMessage) {
        const tableBody = document.getElementById(tableBodyId);
        tableBody.innerHTML = rows.length === 0
            ? '<tr><td colspan="' + columnCount + '" class="text-center text-base-content/50 py-6">' + emptyMessage + '</td></tr>'
            : rows.map(buildRow).join('');
    }

    // ── 상품별 판매·통화별 금액 ──
    function renderProductSales(summary) {
        renderTableRows('productSalesBody', summary.productSales, 4, product =>
            '<tr><td class="font-mono text-xs">' + escapeHtml(product.productId) + '</td>'
            + '<td class="text-xs">' + escapeHtml(STORE_LABEL_BY_CODE[product.store] || product.store) + '</td>'
            + '<td class="text-right">' + formatNumber(product.soldCount) + '</td>'
            + '<td class="text-right' + (product.revokedCount > 0 ? ' text-error font-bold' : '') + '">' + formatNumber(product.revokedCount) + '</td></tr>',
        '이 기간 구매가 없습니다.');
    }

    function renderAmounts(summary) {
        renderTableRows('amountBody', summary.amounts, 3, amount =>
            '<tr><td class="font-mono text-xs">' + escapeHtml(amount.currencyCode) + '</td>'
            + '<td class="text-right">' + formatNumber(amount.amount, 2) + '</td>'
            + '<td class="text-right">' + formatNumber(amount.purchaseCount) + '</td></tr>',
        '금액이 기록된 구매가 없습니다.');
        const noticeElement = document.getElementById('amountMissingNotice');
        noticeElement.hidden = !summary.verifiedPurchaseWithoutAmountCount;
        noticeElement.textContent = '금액 미기록 유효 구매 ' + formatNumber(summary.verifiedPurchaseWithoutAmountCount)
            + '건은 합계에서 빠져 있습니다. (스토어가 금액을 알려 준 구매만 기록)';
    }

    function loadSummary(queryString) {
        loadBlock(document.getElementById('subscriptionBlock'), API_BASE + '/summary?' + queryString, summary => {
            renderSummary(summary);
            renderDailyPurchaseChart(summary);
            renderProductSales(summary);
            renderAmounts(summary);
            return true;
        });
    }

    // ── 시작: 기본 최근 30일, 기간이 바뀔 때마다 다시 조회 ──
    AdminPeriodFilter.bind(document.querySelector('[data-period-filter]'), {
        defaultPreset: 'LAST_30',
        csvBaseUrl: API_BASE + '/summary.csv',
        onChange: period => loadSummary(period.queryString)
    });
})();
