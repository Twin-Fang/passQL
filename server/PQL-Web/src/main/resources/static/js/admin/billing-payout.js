/**
 * 관리자 결제 관리 > 실수령액 (#1032): 기간 프리셋 > 통화별 카드, 월별 차트, 스토어·상품별 표, 설정값 표시·수정
 * API: GET /admin/api/subscriptions/payout?from=&to= (from 비우면 전체), PUT /admin/api/subscriptions/payout/settings
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/subscriptions/payout';
    const { renderChart, loadBlock, formatNumber, formatPercent } = AdminChart;
    const { formatMoney, toStoreLabel, canWriteAdmin } = BillingManagement;
    const escapeHtml = AdminUi.escapeHtml;
    const toDateText = AdminPeriodFilter.toDateText;

    const fromInput = document.getElementById('payoutFromDate');
    const toInput = document.getElementById('payoutToDate');
    const presetButtons = Array.from(document.querySelectorAll('[data-payout-preset]'));
    const settingsForm = document.getElementById('payoutSettingsForm');
    const settingsEditButton = document.getElementById('payoutSettingsEditButton');
    let latestSettings = null;

    // 프리셋 코드 > 기간 (ALL: 시작일 비움 = 전체)
    const PERIOD_BY_PRESET = {
        THIS_MONTH: today => ({ fromDate: new Date(today.getFullYear(), today.getMonth(), 1), toDate: today }),
        LAST_MONTH: today => ({
            fromDate: new Date(today.getFullYear(), today.getMonth() - 1, 1),
            toDate: new Date(today.getFullYear(), today.getMonth(), 0)
        }),
        LAST_30: today => ({ fromDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 29), toDate: today }),
        ALL: today => ({ fromDate: null, toDate: today })
    };

    function selectPreset(presetCode) {
        const period = PERIOD_BY_PRESET[presetCode](new Date());
        fromInput.value = period.fromDate ? toDateText(period.fromDate) : '';
        toInput.value = toDateText(period.toDate);
        presetButtons.forEach(button => button.classList.toggle('btn-active', button.dataset.payoutPreset === presetCode));
        loadPayout();
    }

    // ── 통화별 카드: 큰 숫자 = 예상 실수령, 아래 단계별 금액 ──
    function toCurrencyCard(currencyTotal) {
        const amounts = currencyTotal.amounts;
        const currencyCode = currencyTotal.currencyCode;
        const stepRow = (label, value, toneClass) => '<div class="flex justify-between"><span class="text-base-content/60">'
            + label + '</span><span class="' + (toneClass || '') + '">' + escapeHtml(value) + '</span></div>';
        return '<div class="card bg-base-100 shadow-sm"><div class="card-body p-4 gap-2">'
            + '<div class="flex items-center justify-between"><span class="text-xs text-base-content/60">예상 실수령 ('
            + escapeHtml(currencyCode) + ')</span><span class="text-xs text-base-content/50">판매 ' + formatNumber(amounts.purchaseCount)
            + '건 · 환불 ' + formatNumber(amounts.revokedCount) + '건</span></div>'
            + '<span class="text-3xl font-bold text-success">' + escapeHtml(formatMoney(amounts.payoutAmount, currencyCode)) + '</span>'
            + '<div class="text-sm space-y-0.5">'
            + stepRow('판매 총액', formatMoney(amounts.grossAmount, currencyCode))
            + stepRow('− 환불', formatMoney(amounts.refundAmount, currencyCode), amounts.refundAmount > 0 ? 'text-error' : '')
            + stepRow('− 부가세', formatMoney(amounts.vatAmount, currencyCode))
            + stepRow('− 스토어 수수료', formatMoney(amounts.feeAmount, currencyCode))
            + '</div></div></div>';
    }

    function renderCurrencyCards(payout) {
        const cardsElement = document.getElementById('payoutCurrencyCards');
        const currencyTotals = [...payout.currencyTotals].sort((first, second) =>
            (first.currencyCode === 'KRW' ? -1 : 0) - (second.currencyCode === 'KRW' ? -1 : 0));
        cardsElement.innerHTML = currencyTotals.length === 0
            ? '<div class="text-sm text-base-content/50 py-6">이 기간 금액이 기록된 구매가 없습니다.</div>'
            : currencyTotals.map(toCurrencyCard).join('');
        const noticeElement = document.getElementById('payoutAmountUnknownNotice');
        noticeElement.hidden = !payout.amountUnknownCount;
        noticeElement.textContent = '금액 미확인 ' + formatNumber(payout.amountUnknownCount)
            + '건은 합계에서 빠져 있습니다. (스토어가 금액을 알려 주지 않은 구매)';
    }

    function renderSettings(settings) {
        latestSettings = settings;
        document.getElementById('payoutPlayFeeRate').textContent = formatPercent(settings.playFeeRatePercent);
        document.getElementById('payoutAppStoreFeeRate').textContent = formatPercent(settings.appStoreFeeRatePercent);
        document.getElementById('payoutKrwVatRate').textContent = formatPercent(settings.krwVatRatePercent);
        settingsEditButton.hidden = !canWriteAdmin();
    }

    // ── 월별 차트: 판매 총액·환불·예상 실수령 막대 ──
    function renderMonthlyChart(payout) {
        renderChart(document.getElementById('payoutMonthlyChart'), colors => ({
            type: 'bar',
            data: {
                labels: payout.monthlyPayouts.map(month => month.month),
                datasets: [
                    { label: '판매 총액', data: payout.monthlyPayouts.map(month => month.grossAmount), backgroundColor: colors.primary },
                    { label: '환불', data: payout.monthlyPayouts.map(month => month.refundAmount), backgroundColor: colors.error },
                    { label: '예상 실수령', data: payout.monthlyPayouts.map(month => month.payoutAmount), backgroundColor: colors.success }
                ]
            },
            options: { scales: { y: { beginAtZero: true, title: { display: true, text: '원' } } } }
        }));
    }

    function renderRows(tableBodyId, rows, columnCount, buildRow) {
        document.getElementById(tableBodyId).innerHTML = rows.length === 0
            ? '<tr><td colspan="' + columnCount + '" class="text-center text-base-content/50 py-6">이 기간 구매가 없습니다.</td></tr>'
            : rows.map(buildRow).join('');
    }

    function moneyCell(amount, currencyCode, extraClass) {
        return '<td class="text-right whitespace-nowrap ' + (extraClass || '') + '">' + escapeHtml(formatMoney(amount, currencyCode)) + '</td>';
    }

    function renderStoreAndProductTables(payout) {
        renderRows('payoutStoreBody', payout.storePayouts, 8, storePayout => {
            const amounts = storePayout.amounts;
            const currencyCode = storePayout.currencyCode;
            return '<tr><td class="text-xs">' + escapeHtml(toStoreLabel(storePayout.store)) + '</td>'
                + '<td class="font-mono text-xs">' + escapeHtml(currencyCode) + '</td>'
                + '<td class="text-right">' + formatNumber(amounts.purchaseCount) + '</td>'
                + moneyCell(amounts.grossAmount, currencyCode)
                + moneyCell(amounts.refundAmount, currencyCode, amounts.refundAmount > 0 ? 'text-error' : '')
                + moneyCell(amounts.vatAmount, currencyCode)
                + '<td class="text-right whitespace-nowrap">' + escapeHtml(formatMoney(amounts.feeAmount, currencyCode))
                + ' <span class="text-xs text-base-content/50">(' + formatPercent(storePayout.feeRatePercent) + ')</span></td>'
                + moneyCell(amounts.payoutAmount, currencyCode, 'font-bold') + '</tr>';
        });
        renderRows('payoutProductBody', payout.productPayouts, 7, productPayout => {
            const amounts = productPayout.amounts;
            const currencyCode = productPayout.currencyCode;
            return '<tr><td class="font-mono text-xs">' + escapeHtml(productPayout.productId) + '</td>'
                + '<td class="text-xs">' + escapeHtml(toStoreLabel(productPayout.store)) + '</td>'
                + '<td class="font-mono text-xs">' + escapeHtml(currencyCode) + '</td>'
                + '<td class="text-right">' + formatNumber(amounts.purchaseCount)
                + (amounts.revokedCount > 0 ? ' <span class="text-xs text-error">(환불 ' + formatNumber(amounts.revokedCount) + ')</span>' : '') + '</td>'
                + moneyCell(amounts.grossAmount, currencyCode)
                + moneyCell(amounts.refundAmount, currencyCode, amounts.refundAmount > 0 ? 'text-error' : '')
                + moneyCell(amounts.payoutAmount, currencyCode, 'font-bold') + '</tr>';
        });
    }

    function loadPayout() {
        const queryString = 'from=' + encodeURIComponent(fromInput.value) + '&to=' + encodeURIComponent(toInput.value);
        loadBlock(document.getElementById('payoutBlock'), API_BASE + '?' + queryString, payout => {
            renderSettings(payout.settings);
            renderCurrencyCards(payout);
            renderMonthlyChart(payout);
            renderStoreAndProductTables(payout);
            return true;
        });
    }

    // ── 설정 수정 (쓰기 권한만, 저장 후 다시 계산) ──
    function openSettingsForm() {
        if (!latestSettings) return;
        Object.entries(latestSettings).forEach(([name, value]) => {
            const input = settingsForm.elements.namedItem(name);
            if (input) input.value = value;
        });
        settingsForm.hidden = false;
    }

    async function saveSettings(event) {
        event.preventDefault();
        const formValues = Object.fromEntries(new FormData(settingsForm).entries());
        try {
            await AdminApi.put(API_BASE + '/settings', {
                playFeeRatePercent: Number(formValues.playFeeRatePercent),
                appStoreFeeRatePercent: Number(formValues.appStoreFeeRatePercent),
                krwVatRatePercent: Number(formValues.krwVatRatePercent)
            });
            settingsForm.hidden = true;
            AdminUi.toast('설정을 저장했습니다.');
            loadPayout();
        } catch (error) {
            AdminUi.showError(error);
        }
    }

    // ── 시작: 기본 이번 달 ──
    presetButtons.forEach(button => button.addEventListener('click', () => selectPreset(button.dataset.payoutPreset)));
    document.getElementById('payoutApplyButton').addEventListener('click', () => {
        if (!toInput.value || (fromInput.value && fromInput.value > toInput.value)) {
            AdminUi.toast('시작일과 종료일을 확인해 주세요.');
            return;
        }
        presetButtons.forEach(button => button.classList.remove('btn-active'));
        loadPayout();
    });
    settingsEditButton.addEventListener('click', openSettingsForm);
    document.getElementById('payoutSettingsCancelButton').addEventListener('click', () => { settingsForm.hidden = true; });
    settingsForm.addEventListener('submit', saveSettings);
    selectPreset('THIS_MONTH');
})();
