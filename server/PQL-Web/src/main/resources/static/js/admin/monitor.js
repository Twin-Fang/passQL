/**
 * 관리자 모니터링: 30초 자동 새로고침(탭 숨김이면 멈춤) + 시간별 실패율·지연·서버 오류 차트
 * API: /admin/api/monitor/timeseries?hours= (hours 는 서버가 렌더한 필터 값 window.MONITOR_FILTER_HOURS)
 */
(function () {
    'use strict';

    const TIMESERIES_URL = '/admin/api/monitor/timeseries';
    // 자동 새로고침 간격 (밀리초)과 설정 저장 키 (브라우저별 편의 설정)
    const AUTO_REFRESH_INTERVAL_MILLISECONDS = 30000;
    const AUTO_REFRESH_STORAGE_KEY = 'passqlAdminMonitorAutoRefresh';

    const { renderChart, loadBlock, formatMilliseconds, formatPercent } = AdminChart;

    // ── 자동 새로고침 (필터는 주소에 있어 reload 로 유지, 저장소를 못 써도 동작은 켠 세션 동안만) ──
    function readAutoRefreshSetting() {
        try { return localStorage.getItem(AUTO_REFRESH_STORAGE_KEY) === '1'; } catch (ignored) { return false; }
    }

    function writeAutoRefreshSetting(isEnabled) {
        try { localStorage.setItem(AUTO_REFRESH_STORAGE_KEY, isEnabled ? '1' : '0'); } catch (ignored) { /* 저장소 차단 환경 */ }
    }

    function bindAutoRefresh(toggleElement) {
        let lastRefreshedAtMilliseconds = Date.now();
        toggleElement.checked = readAutoRefreshSetting();
        toggleElement.addEventListener('change', () => {
            writeAutoRefreshSetting(toggleElement.checked);
            lastRefreshedAtMilliseconds = Date.now();
        });
        setInterval(() => {
            const isDue = Date.now() - lastRefreshedAtMilliseconds >= AUTO_REFRESH_INTERVAL_MILLISECONDS;
            if (toggleElement.checked && !document.hidden && isDue) window.location.reload();
        }, AUTO_REFRESH_INTERVAL_MILLISECONDS / 6);
    }

    // ── 시간별 차트 2개 ──
    function renderFailureRateChart(timeseries) {
        renderChart(document.getElementById('failureRateChart'), colors => ({
            type: 'line',
            data: {
                labels: timeseries.labels,
                datasets: [
                    { label: 'AI 실패율', data: timeseries.aiFailureRatePercents, borderColor: colors.error, backgroundColor: colors.error },
                    { label: 'SQL 실패율', data: timeseries.sqlFailureRatePercents, borderColor: colors.warning, backgroundColor: colors.warning }
                ]
            },
            options: {
                scales: { y: { beginAtZero: true, max: 100, title: { display: true, text: '%' } },
                          x: { ticks: { maxTicksLimit: 12 } } },
                plugins: { tooltip: { callbacks: { label: item => item.dataset.label + ' ' + formatPercent(item.raw) } } }
            }
        }));
    }

    function renderLatencyChart(timeseries) {
        renderChart(document.getElementById('latencyChart'), colors => ({
            data: {
                labels: timeseries.labels,
                datasets: [
                    { type: 'bar', label: '서버 오류(5xx)', data: timeseries.serverErrorCounts, backgroundColor: colors.translucent('error', 0.6), yAxisID: 'y' },
                    { type: 'line', label: 'AI 평균 지연', data: timeseries.aiAverageLatencyMilliseconds, borderColor: colors.info, backgroundColor: colors.info, yAxisID: 'yLatency' },
                    { type: 'line', label: 'SQL 평균 소요', data: timeseries.sqlAverageElapsedMilliseconds, borderColor: colors.accent, backgroundColor: colors.accent, yAxisID: 'yLatency' }
                ]
            },
            options: {
                scales: {
                    x: { ticks: { maxTicksLimit: 12 } },
                    y: { beginAtZero: true, ticks: { precision: 0 }, title: { display: true, text: '건' } },
                    yLatency: { position: 'right', beginAtZero: true, grid: { drawOnChartArea: false }, title: { display: true, text: 'ms' } }
                },
                plugins: { tooltip: { callbacks: { label: item => item.dataset.label + ' ' + (item.dataset.yAxisID === 'yLatency' ? formatMilliseconds(item.raw) : item.raw) } } }
            }
        }));
    }

    function loadTimeseries() {
        const hours = window.MONITOR_FILTER_HOURS || 24;
        const url = TIMESERIES_URL + '?hours=' + encodeURIComponent(hours);
        loadBlock(document.getElementById('failureRateChartBox'), url, timeseries => {
            renderFailureRateChart(timeseries);
            return Array.isArray(timeseries.labels) && timeseries.labels.length > 0;
        });
        loadBlock(document.getElementById('latencyChartBox'), url, timeseries => {
            renderLatencyChart(timeseries);
            return Array.isArray(timeseries.labels) && timeseries.labels.length > 0;
        });
    }

    lucide.createIcons();
    bindAutoRefresh(document.getElementById('autoRefreshToggle'));
    loadTimeseries();
})();
