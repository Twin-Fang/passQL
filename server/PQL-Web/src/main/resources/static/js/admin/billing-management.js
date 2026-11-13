/**
 * 관리자 결제 관리 공통 (#1032): 탭 전환(주소 #탭 기억), 금액·스토어 표시, 쓰기 권한 여부, 페이지 이동 버튼
 * 탭 패널: [data-tab-panel=탭 코드] (같은 코드 여러 영역 동시 표시)
 */
(function () {
    'use strict';

    const pageElement = document.getElementById('billingManagementPage');
    const tabButtons = Array.from(document.querySelectorAll('#billingTabList [data-tab]'));
    const DEFAULT_TAB = 'payout';
    // 스토어 코드 > 표시 이름 (PurchaseStore)
    const STORE_LABEL_BY_CODE = { PLAY: 'Google Play', APP_STORE: 'App Store' };
    // 원화 표시 통화 (소수점 없이 "원")
    const KRW_CURRENCY_CODE = 'KRW';
    const tabSelectedListeners = [];

    /** 탭 선택: 버튼 강조 > 패널 표시 > 주소 #탭 > 구독 함수 알림 */
    function selectTab(tabCode) {
        const isKnownTab = tabButtons.some(button => button.dataset.tab === tabCode);
        const selectedTab = isKnownTab ? tabCode : DEFAULT_TAB;
        tabButtons.forEach(button => button.classList.toggle('tab-active', button.dataset.tab === selectedTab));
        document.querySelectorAll('[data-tab-panel]').forEach(panel => {
            panel.hidden = panel.dataset.tabPanel !== selectedTab;
        });
        history.replaceState(null, '', '#' + selectedTab);
        tabSelectedListeners.forEach(listener => listener(selectedTab));
    }

    /** 금액 > "4,400원" / "USD 1.99" (금액 없으면 '-') */
    function formatMoney(amount, currencyCode) {
        if (amount === null || amount === undefined) return '-';
        if (currencyCode === KRW_CURRENCY_CODE) return AdminChart.formatNumber(amount) + '원';
        return (currencyCode || '') + ' ' + AdminChart.formatNumber(amount, 2);
    }

    function toStoreLabel(storeCode) {
        return STORE_LABEL_BY_CODE[storeCode] || storeCode || '-';
    }

    /** 쓰기 권한(ADMIN) 여부: 조회 전용 계정은 회수·설정 버튼 숨김 */
    function canWriteAdmin() {
        return pageElement && pageElement.dataset.canWriteAdmin === 'true';
    }

    /** 페이지 정보·이전/다음 버튼 상태 (page 0부터) */
    function renderPager(infoElement, previousButton, nextButton, pageResponse) {
        const totalPageCount = Math.max(1, pageResponse.totalPageCount);
        infoElement.textContent = (pageResponse.page + 1) + ' / ' + totalPageCount + ' 페이지 · 총 '
            + AdminChart.formatNumber(pageResponse.totalCount) + '건';
        previousButton.disabled = pageResponse.page <= 0;
        nextButton.disabled = pageResponse.page + 1 >= totalPageCount;
    }

    window.BillingManagement = {
        formatMoney,
        toStoreLabel,
        canWriteAdmin,
        renderPager,
        onTabSelected: listener => tabSelectedListeners.push(listener)
    };

    // ── 시작: 주소 #탭 > 기본 실수령액 (다른 화면 스크립트가 구독한 뒤 실행) ──
    tabButtons.forEach(button => button.addEventListener('click', () => selectTab(button.dataset.tab)));
    // 주소 #탭 직접 변경(뒤로 가기·링크) 반영
    window.addEventListener('hashchange', () => selectTab(location.hash.replace('#', '')));
    document.addEventListener('DOMContentLoaded', () => selectTab(location.hash.replace('#', '')));
})();
