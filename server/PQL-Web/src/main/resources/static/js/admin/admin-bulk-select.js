/**
 * 관리자 목록 공통: 행 체크박스 + 전체 선택 + 선택 수 알림
 * 행 체크박스 = .bulk-row-checkbox (value 가 대상 UUID), 전체 선택 = .bulk-all-checkbox
 * 이벤트 위임이라 JS 가 행을 다시 그려도 그대로 동작 (다시 그린 뒤 refresh 호출)
 */
(function () {
    'use strict';

    const ROW_CHECKBOX_SELECTOR = '.bulk-row-checkbox';
    const ALL_CHECKBOX_SELECTOR = '.bulk-all-checkbox';

    /**
     * rootElement 안의 체크박스를 묶는다
     * onChange(selectedCount): 선택 수가 바뀔 때마다 호출 (일괄 작업 바 표시용)
     */
    function attach(rootElement, onChange) {
        const notifyChange = () => {
            if (onChange) onChange(getSelectedValues().length);
        };

        function getRowCheckboxes() {
            return Array.from(rootElement.querySelectorAll(ROW_CHECKBOX_SELECTOR)).filter(checkbox => !checkbox.disabled);
        }

        function getSelectedValues() {
            return getRowCheckboxes().filter(checkbox => checkbox.checked).map(checkbox => checkbox.value);
        }

        /** 전체 선택 체크박스 상태를 행 선택 상태에 맞춤 (일부만 선택이면 indeterminate) */
        function syncAllCheckbox() {
            const allCheckbox = rootElement.querySelector(ALL_CHECKBOX_SELECTOR);
            if (!allCheckbox) return;
            const rowCheckboxes = getRowCheckboxes();
            const selectedCount = rowCheckboxes.filter(checkbox => checkbox.checked).length;
            allCheckbox.checked = rowCheckboxes.length > 0 && selectedCount === rowCheckboxes.length;
            allCheckbox.indeterminate = selectedCount > 0 && selectedCount < rowCheckboxes.length;
        }

        rootElement.addEventListener('change', event => {
            if (event.target.matches(ALL_CHECKBOX_SELECTOR)) {
                getRowCheckboxes().forEach(checkbox => { checkbox.checked = event.target.checked; });
            } else if (!event.target.matches(ROW_CHECKBOX_SELECTOR)) {
                return;
            }
            syncAllCheckbox();
            notifyChange();
        });

        // 행 클릭 이동(tr onclick)과 겹치지 않게 체크박스 클릭은 위로 올리지 않음
        rootElement.addEventListener('click', event => {
            if (event.target.matches(ROW_CHECKBOX_SELECTOR) || event.target.matches(ALL_CHECKBOX_SELECTOR)) {
                event.stopPropagation();
            }
        });

        return {
            getSelectedValues,
            /** 행을 다시 그린 뒤 선택 상태 초기화 */
            refresh() {
                syncAllCheckbox();
                notifyChange();
            }
        };
    }

    window.AdminBulkSelect = { attach };
})();
