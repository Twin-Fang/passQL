/**
 * 관리자 결제 관리 > 결제 목록 (#1032): 필터 > 페이지 표, CSV 링크, 건별 회수(쓰기 권한만, 사유 입력)
 * API: GET /admin/api/subscriptions/purchases, purchases.csv, POST purchases/{uuid}/revoke
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/subscriptions/purchases';
    const { loadBlock, formatDateTime } = AdminChart;
    const { formatMoney, toStoreLabel, canWriteAdmin, renderPager, onTabSelected } = BillingManagement;
    const escapeHtml = AdminUi.escapeHtml;
    // 표 열 개수 (빈 표 안내 colspan)
    const PURCHASE_TABLE_COLUMN_COUNT = 10;
    // 상태 코드 > 배지 (PurchaseStatus)
    const STATUS_BADGE_BY_CODE = {
        VERIFIED: '<span class="badge badge-sm badge-success">정상</span>',
        REVOKED: '<span class="badge badge-sm badge-error">회수</span>'
    };
    // App Store 환불 요청 상태 > 배지
    const REFUND_REQUEST_BADGE_BY_STATE = {
        REQUESTED: '<span class="badge badge-sm badge-warning">환불 요청 중</span>',
        DECLINED: '<span class="badge badge-sm badge-ghost">환불 거절됨</span>'
    };

    const filterForm = document.getElementById('purchaseFilterForm');
    const previousButton = document.getElementById('purchasePreviousButton');
    const nextButton = document.getElementById('purchaseNextButton');
    let currentPage = 0;
    let hasLoaded = false;

    /** 필터 값 > 쿼리 문자열 (빈 값 생략) */
    function toFilterQueryString() {
        const parameters = new URLSearchParams();
        new FormData(filterForm).forEach((value, name) => { if (value) parameters.append(name, value); });
        return parameters.toString();
    }

    function toPurchaseRow(row) {
        const memberLabel = (row.memberNickname || '(회원 없음)')
            + (row.isTestAccount ? ' <span class="badge badge-xs badge-ghost">테스트</span>' : '');
        const revokeButton = canWriteAdmin() && row.status === 'VERIFIED'
            ? '<button type="button" class="btn btn-xs btn-outline btn-error" data-action="revoke"'
                + ' data-purchase-uuid="' + escapeHtml(row.entitlementPurchaseUuid) + '"'
                + ' data-member-uuid="' + escapeHtml(row.memberUuid) + '">회수</button>'
            : '';
        return '<tr><td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(row.purchasedAt)) + '</td>'
            + '<td class="text-xs whitespace-nowrap">' + escapeHtml(toStoreLabel(row.store)) + '</td>'
            + '<td class="font-mono text-xs">' + escapeHtml(row.productId) + '</td>'
            + '<td class="whitespace-nowrap">' + (STATUS_BADGE_BY_CODE[row.status] || escapeHtml(row.status))
            + ' ' + (REFUND_REQUEST_BADGE_BY_STATE[row.refundRequestState] || '') + '</td>'
            + '<td class="text-right whitespace-nowrap">' + (row.amount === null
                ? '<span class="text-xs text-warning">금액 미확인</span>' : escapeHtml(formatMoney(row.amount, row.currencyCode))) + '</td>'
            + '<td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(row.grantedExpiresAt)) + '</td>'
            + '<td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(row.revokedAt)) + '</td>'
            + '<td class="font-mono text-xs">' + escapeHtml(row.maskedOrderId) + '</td>'
            + '<td class="text-xs whitespace-nowrap"><a class="link link-primary" href="/admin/members/' + encodeURIComponent(row.memberUuid) + '">'
            + memberLabel + '</a></td>'
            + '<td class="whitespace-nowrap">' + revokeButton + '</td></tr>';
    }

    function loadPurchases(page) {
        currentPage = Math.max(0, page);
        hasLoaded = true;
        const queryString = toFilterQueryString();
        document.getElementById('purchaseCsvLink').href = API_BASE + '.csv' + (queryString ? '?' + queryString : '');
        loadBlock(document.getElementById('purchaseBlock'), API_BASE + '?page=' + currentPage + (queryString ? '&' + queryString : ''),
            pageResponse => {
                document.getElementById('purchaseBody').innerHTML = pageResponse.rows.length === 0
                    ? '<tr><td colspan="' + PURCHASE_TABLE_COLUMN_COUNT + '" class="text-center text-base-content/50 py-6">조건에 맞는 결제가 없습니다.</td></tr>'
                    : pageResponse.rows.map(toPurchaseRow).join('');
                renderPager(document.getElementById('purchasePageInfo'), previousButton, nextButton, pageResponse);
                return true;
            });
    }

    /** 건별 회수: 사유 입력 > 회수 요청 > 결과 토스트 > 현재 페이지 다시 조회 */
    async function revokePurchase(buttonElement) {
        const reason = await AdminReasonPrompt.ask({
            title: '결제 회수',
            message: '이 결제를 회수하고 회원 프로 기간을 남은 구매로 다시 계산합니다.\n스토어 환불은 따로 처리되지 않습니다.',
            confirmLabel: '회수',
            placeholder: '회수 사유 (필수, 200자)',
            isDanger: true
        });
        if (!reason) {
            if (reason === '') AdminUi.toast('회수 사유를 입력해 주세요.', 'error');
            return;
        }
        buttonElement.disabled = true;
        try {
            await AdminApi.post(API_BASE + '/' + encodeURIComponent(buttonElement.dataset.purchaseUuid) + '/revoke',
                { memberUuid: buttonElement.dataset.memberUuid, reason });
            AdminUi.toast('결제를 회수했습니다.');
            loadPurchases(currentPage);
        } catch (error) {
            AdminUi.showError(error);
            buttonElement.disabled = false;
        }
    }

    // ── 시작: 결제 목록 탭을 처음 열 때 조회 ──
    filterForm.addEventListener('submit', event => { event.preventDefault(); loadPurchases(0); });
    previousButton.addEventListener('click', () => loadPurchases(currentPage - 1));
    nextButton.addEventListener('click', () => loadPurchases(currentPage + 1));
    document.getElementById('purchaseBody').addEventListener('click', event => {
        const revokeButton = event.target.closest('[data-action="revoke"]');
        if (revokeButton) revokePurchase(revokeButton);
    });
    onTabSelected(tabCode => { if (tabCode === 'purchases' && !hasLoaded) loadPurchases(0); });
})();
