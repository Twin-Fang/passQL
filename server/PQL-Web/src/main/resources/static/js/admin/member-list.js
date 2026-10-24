/**
 * 회원 목록 화면: 행 선택 > 일괄 작업 바(일괄 정지, 일괄 푸시)
 * 제재·푸시 창은 member-moderation.js, 체크박스 묶음은 admin-bulk-select.js 공용
 */
(function () {
    'use strict';

    const bulkBar = document.getElementById('memberBulkBar');
    const bulkCount = document.getElementById('memberBulkCount');

    // 선택 수가 0이면 일괄 작업 바 숨김
    const bulkSelection = AdminBulkSelect.attach(document.getElementById('memberTableWrapper'), selectedCount => {
        bulkCount.textContent = selectedCount;
        bulkBar.classList.toggle('hidden', selectedCount === 0);
    });

    window.openBulkSuspend = () => openSuspendModal(bulkSelection.getSelectedValues());
    window.openBulkPush = () => openPushModal(bulkSelection.getSelectedValues());
})();
