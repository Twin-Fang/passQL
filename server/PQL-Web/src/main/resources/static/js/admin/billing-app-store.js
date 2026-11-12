/**
 * 관리자 결제 관리 > App Store (#1032): 환불 점검(키 상태·최근 실행·지금 확인), 알림 수신 기록(페이지, 환불 요청 강조)
 * API: GET·POST /admin/api/subscriptions/app-store/refund-checks, GET /admin/api/subscriptions/app-store/notifications
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/subscriptions/app-store';
    const { loadBlock, formatNumber, formatDateTime } = AdminChart;
    const { canWriteAdmin, renderPager, onTabSelected } = BillingManagement;
    const escapeHtml = AdminUi.escapeHtml;
    // 표 열 개수 (빈 표 안내 colspan)
    const RUN_TABLE_COLUMN_COUNT = 6;
    const NOTIFICATION_TABLE_COLUMN_COUNT = 7;
    // 키 미설정으로 건너뛴 실행 (실패가 아니라 회색 표시)
    const KEY_NOT_CONFIGURED_REASON = 'APP_STORE_KEY_NOT_CONFIGURED';
    // 처리 결과 > 글자색 (AppStoreNotificationResult)
    const RESULT_TONE_BY_CODE = {
        REVOKED: 'text-error font-bold',
        VERIFICATION_FAILED: 'text-error',
        CONSUMPTION_FAILED: 'text-error',
        IGNORED: 'text-base-content/50'
    };

    const notificationPreviousButton = document.getElementById('appStoreNotificationPreviousButton');
    const notificationNextButton = document.getElementById('appStoreNotificationNextButton');
    let notificationPage = 0;
    const loadedTabs = new Set();

    function setBadge(elementId, isOn, onText, offText, offClass) {
        const badgeElement = document.getElementById(elementId);
        badgeElement.className = 'badge badge-sm ' + (isOn ? 'badge-success' : (offClass || 'badge-ghost'));
        badgeElement.textContent = isOn ? onText : offText;
    }

    // ── 환불 점검 ──
    function toRunResultCell(run) {
        if (run.isSucceeded) return '<td class="text-xs text-success">성공</td>';
        const toneClass = run.failureReason === KEY_NOT_CONFIGURED_REASON ? 'text-base-content/50' : 'text-error';
        return '<td class="text-xs ' + toneClass + '">' + escapeHtml(run.failureReasonLabel) + '</td>';
    }

    function toRunRow(run) {
        return '<tr><td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(run.startedAt)) + '</td>'
            + '<td class="text-xs">' + escapeHtml(run.triggerTypeLabel) + '</td>'
            + '<td class="text-right">' + formatNumber(run.checkedOrderCount) + '</td>'
            + '<td class="text-right">' + formatNumber(run.refundedOrderCount) + '</td>'
            + '<td class="text-right' + (run.revokedCount > 0 ? ' text-error font-bold' : '') + '">' + formatNumber(run.revokedCount) + '</td>'
            + toRunResultCell(run) + '</tr>';
    }

    function renderRefundCheckOverview(overview) {
        setBadge('appStoreKeyBadge', overview.isServerApiConfigured, '설정됨', '키 미설정', 'badge-warning');
        setBadge('appStoreSandboxBadge', overview.isSandboxFallbackEnabled, '켜짐', '꺼짐');
        setBadge('appStoreConsumptionBadge', overview.isConsumptionResponseEnabled, '켜짐', '꺼짐');
        document.getElementById('appStoreKeyMissingNotice').hidden = overview.isServerApiConfigured;
        document.getElementById('appStoreRefundCheckRunButton').hidden = !canWriteAdmin();
        document.getElementById('appStoreRefundCheckRunBody').innerHTML = overview.recentRuns.length === 0
            ? '<tr><td colspan="' + RUN_TABLE_COLUMN_COUNT + '" class="text-center text-base-content/50 py-6">실행 기록이 없습니다.</td></tr>'
            : overview.recentRuns.map(toRunRow).join('');
        return true;
    }

    function loadRefundCheckOverview() {
        loadBlock(document.getElementById('appStoreRefundCheckBlock'), API_BASE + '/refund-checks', renderRefundCheckOverview);
    }

    async function runRefundCheckNow(buttonElement) {
        buttonElement.disabled = true;
        try {
            const run = await AdminApi.post(API_BASE + '/refund-checks');
            if (run.isSucceeded) {
                AdminUi.toast('App Store 환불 확인을 마쳤습니다. 회수 ' + formatNumber(run.revokedCount) + '건');
            } else {
                AdminUi.toast('App Store 환불 확인: ' + run.failureReasonLabel, 'error');
            }
            loadRefundCheckOverview();
        } catch (error) {
            AdminUi.showError(error);
        } finally {
            buttonElement.disabled = false;
        }
    }

    // ── 알림 기록 ──
    function toNotificationRow(notification) {
        const rowClass = notification.isRefundRequest ? ' class="bg-warning/15"' : '';
        const typeCell = notification.isRefundRequest
            ? '<span class="badge badge-sm badge-warning">환불 요청</span> <span class="font-mono text-xs">' + escapeHtml(notification.notificationType) + '</span>'
            : '<span class="font-mono text-xs">' + escapeHtml(notification.notificationType || '-') + '</span>';
        return '<tr' + rowClass + '><td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(notification.receivedAt)) + '</td>'
            + '<td>' + typeCell + '</td>'
            + '<td class="font-mono text-xs">' + escapeHtml(notification.subtype || '-') + '</td>'
            + '<td class="font-mono text-xs">' + escapeHtml(notification.transactionId || '-') + '</td>'
            + '<td class="text-xs">' + escapeHtml(notification.environment || '-') + '</td>'
            + '<td class="text-xs ' + (RESULT_TONE_BY_CODE[notification.handlingResult] || '') + '">' + escapeHtml(notification.handlingResultLabel) + '</td>'
            + '<td class="font-mono text-xs text-base-content/50">' + escapeHtml(notification.notificationUuid ? notification.notificationUuid.substring(0, 8) : '-') + '</td></tr>';
    }

    function loadNotifications(page) {
        notificationPage = Math.max(0, page);
        loadBlock(document.getElementById('appStoreNotificationBlock'), API_BASE + '/notifications?page=' + notificationPage, pageResponse => {
            document.getElementById('appStoreNotificationBody').innerHTML = pageResponse.rows.length === 0
                ? '<tr><td colspan="' + NOTIFICATION_TABLE_COLUMN_COUNT + '" class="text-center text-base-content/50 py-6">받은 알림이 없습니다.</td></tr>'
                : pageResponse.rows.map(toNotificationRow).join('');
            renderPager(document.getElementById('appStoreNotificationPageInfo'), notificationPreviousButton, notificationNextButton, pageResponse);
            return true;
        });
    }

    // ── 시작: 탭을 처음 열 때 조회 ──
    const runButton = document.getElementById('appStoreRefundCheckRunButton');
    runButton.addEventListener('click', () => runRefundCheckNow(runButton));
    notificationPreviousButton.addEventListener('click', () => loadNotifications(notificationPage - 1));
    notificationNextButton.addEventListener('click', () => loadNotifications(notificationPage + 1));
    onTabSelected(tabCode => {
        if (loadedTabs.has(tabCode)) return;
        if (tabCode === 'refund-checks') loadRefundCheckOverview();
        else if (tabCode === 'notifications') loadNotifications(0);
        else return;
        loadedTabs.add(tabCode);
    });
})();
