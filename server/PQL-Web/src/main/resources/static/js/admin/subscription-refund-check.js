/**
 * 관리자 구독·매출 현황 > 환불 회수 확인 (#984): 최근 14회 실행 표, 마지막 실행 결과, 「지금 확인」 즉시 실행 > 다시 조회
 * API: GET·POST /admin/api/subscriptions/refund-checks (POST CSRF 헤더는 admin-fetch.js 공통 부착)
 */
(function () {
    'use strict';

    const REFUND_CHECK_API_URL = '/admin/api/subscriptions/refund-checks';
    const { loadBlock, formatNumber, formatDateTime } = AdminChart;
    const escapeHtml = AdminUi.escapeHtml;
    // 표 열 개수 (빈 표 안내 colspan)
    const RUN_TABLE_COLUMN_COUNT = 7;

    /** 실행 1건 > 성공·실패 배지 class·문구 */
    function toResultBadge(run) {
        return run.isSucceeded
            ? { className: 'badge badge-sm badge-success ml-1', text: '성공' }
            : { className: 'badge badge-sm badge-error ml-1', text: '실패' };
    }

    // ── 마지막 실행 요약 ──
    function renderLatestRun(latestRun) {
        const badgeElement = document.getElementById('refundCheckLatestBadge');
        document.getElementById('refundCheckLatestTime').textContent = latestRun ? formatDateTime(latestRun.startedAt) : '기록 없음';
        if (!latestRun) {
            badgeElement.className = 'badge badge-sm badge-ghost ml-1';
            badgeElement.textContent = '-';
            return;
        }
        const resultBadge = toResultBadge(latestRun);
        badgeElement.className = resultBadge.className;
        badgeElement.textContent = resultBadge.text + ' · 회수 ' + formatNumber(latestRun.revokedCount) + '건';
    }

    // ── 최근 실행 표 ──
    function toRunRow(run) {
        return '<tr><td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(run.startedAt)) + '</td>'
            + '<td class="text-xs">' + escapeHtml(run.triggerTypeLabel) + '</td>'
            + '<td class="text-right">' + formatNumber(run.voidedPurchaseCount) + '</td>'
            + '<td class="text-right">' + formatNumber(run.checkedOrderCount) + '</td>'
            + '<td class="text-right">' + formatNumber(run.refundedOrderCount) + '</td>'
            + '<td class="text-right' + (run.revokedCount > 0 ? ' text-error font-bold' : '') + '">' + formatNumber(run.revokedCount) + '</td>'
            + '<td class="text-xs' + (run.isSucceeded ? ' text-base-content/50' : ' text-error') + '">'
            + escapeHtml(run.isSucceeded ? '-' : run.failureReasonLabel) + '</td></tr>';
    }

    function renderRuns(runs) {
        renderLatestRun(runs[0]);
        document.getElementById('refundCheckRunBody').innerHTML = runs.length === 0
            ? '<tr><td colspan="' + RUN_TABLE_COLUMN_COUNT + '" class="text-center text-base-content/50 py-6">실행 기록이 없습니다.</td></tr>'
            : runs.map(toRunRow).join('');
        return true;
    }

    function loadRuns() {
        loadBlock(document.getElementById('refundCheckBlock'), REFUND_CHECK_API_URL, renderRuns);
    }

    /** 「지금 확인」: 즉시 실행 > 결과 토스트 > 표 다시 조회 (실행 중 버튼 잠금) */
    async function runRefundCheckNow(buttonElement) {
        buttonElement.disabled = true;
        try {
            const run = await AdminApi.post(REFUND_CHECK_API_URL);
            if (run.isSucceeded) {
                AdminUi.toast('환불 회수 확인을 마쳤습니다. 회수 ' + formatNumber(run.revokedCount) + '건');
            } else {
                AdminUi.toast('환불 회수 확인 실패: ' + run.failureReasonLabel, 'error');
            }
            loadRuns();
        } catch (error) {
            AdminUi.showError(error);
        } finally {
            buttonElement.disabled = false;
        }
    }

    // ── 시작 ──
    const runButton = document.getElementById('refundCheckRunButton');
    runButton.addEventListener('click', () => runRefundCheckNow(runButton));
    loadRuns();
})();
