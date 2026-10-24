/**
 * 관리자 통계 기간 선택 공통: 프리셋(최근 7·30일, 이번 달, 지난달) + 직접 지정 > 변경 알림, CSV 링크 주소 갱신
 * 마크업은 fragments/statistics-period-filter.html, 서버 해석·직전 기간 규칙은 StatisticsPeriod
 */
(function () {
    'use strict';

    // 프리셋 코드 > 기간 계산 (today 기준, 종료일은 항상 오늘 이하)
    const PERIOD_BY_PRESET = {
        LAST_7: today => ({ fromDate: addDays(today, -6), toDate: today }),
        LAST_30: today => ({ fromDate: addDays(today, -29), toDate: today }),
        LAST_56: today => ({ fromDate: addDays(today, -55), toDate: today }),
        THIS_MONTH: today => ({ fromDate: new Date(today.getFullYear(), today.getMonth(), 1), toDate: today }),
        LAST_MONTH: today => ({
            fromDate: new Date(today.getFullYear(), today.getMonth() - 1, 1),
            toDate: new Date(today.getFullYear(), today.getMonth(), 0)
        })
    };

    function addDays(date, dayCount) {
        const result = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        result.setDate(result.getDate() + dayCount);
        return result;
    }

    /** Date > yyyy-MM-dd (로컬 날짜 기준) */
    function toDateText(date) {
        return date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0');
    }

    /**
     * 기간 선택 영역 연결
     * rootElement: [data-period-filter] 요소 (버튼 [data-preset], 입력 [data-role=from|to], 적용 [data-role=apply])
     * options.defaultPreset: 처음 선택할 프리셋, options.onChange({from, to, queryString}): 기간 바뀔 때마다 (연결 직후 1회 포함)
     * options.csvBaseUrl: 있으면 [data-role=csv] 링크 href 를 기간이 바뀔 때마다 csvBaseUrl + '?' + queryString 으로 갱신
     */
    function bind(rootElement, options) {
        const fromInput = rootElement.querySelector('[data-role="from"]');
        const toInput = rootElement.querySelector('[data-role="to"]');
        const applyButton = rootElement.querySelector('[data-role="apply"]');
        const presetButtons = Array.from(rootElement.querySelectorAll('button[data-preset]'));
        const csvLinkElement = rootElement.querySelector('[data-role="csv"]');

        function notifyChange() {
            const queryString = 'from=' + encodeURIComponent(fromInput.value) + '&to=' + encodeURIComponent(toInput.value);
            if (csvLinkElement && options.csvBaseUrl) csvLinkElement.href = options.csvBaseUrl + '?' + queryString;
            options.onChange({ from: fromInput.value, to: toInput.value, queryString });
        }

        function selectPreset(presetCode) {
            const period = PERIOD_BY_PRESET[presetCode](new Date());
            fromInput.value = toDateText(period.fromDate);
            toInput.value = toDateText(period.toDate);
            presetButtons.forEach(button => button.classList.toggle('btn-active', button.dataset.preset === presetCode));
            notifyChange();
        }

        presetButtons.forEach(button => button.addEventListener('click', () => selectPreset(button.dataset.preset)));
        applyButton.addEventListener('click', () => {
            if (!fromInput.value || !toInput.value || fromInput.value > toInput.value) {
                AdminUi.toast('시작일과 종료일을 확인해 주세요.');
                return;
            }
            presetButtons.forEach(button => button.classList.remove('btn-active'));
            notifyChange();
        });
        toInput.max = toDateText(new Date());
        fromInput.max = toInput.max;
        selectPreset(options.defaultPreset);
    }

    window.AdminPeriodFilter = { bind, toDateText };
})();
