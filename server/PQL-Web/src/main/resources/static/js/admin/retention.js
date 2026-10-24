/**
 * 관리자 리텐션·코호트: 가입 기간 선택 > D1·D7·D30 카드, 가입 주차 코호트 표, 기능별 사용률
 * API: /admin/api/retention?from=&to= (CSV: export.csv)
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/retention';
    const { loadBlock, formatNumber, formatPercent } = AdminChart;
    const escapeHtml = AdminUi.escapeHtml;
    // 코호트 칸 배경 진하기 (비율 100% 일 때 최대 불투명도)
    const COHORT_CELL_MAX_ALPHA = 0.55;

    // ── N일 리텐션 카드 ──
    function renderDayRetentionCards(dayRetentions) {
        document.getElementById('dayRetentionCards').innerHTML = dayRetentions.map(day =>
            '<div class="card bg-base-100 shadow-sm"><div class="card-body p-4 gap-1">'
            + '<span class="text-xs text-base-content/60">D' + day.dayOffset + ' 리텐션 <span class="text-base-content/40">(가입 ' + day.dayOffset + '일째 활동)</span></span>'
            + '<span class="text-3xl font-bold text-primary">' + (day.eligibleCount > 0 ? formatPercent(day.ratePercent) : '-') + '</span>'
            + '<span class="text-xs text-base-content/50">대상 ' + formatNumber(day.eligibleCount) + '명 중 ' + formatNumber(day.retainedCount) + '명 (가입 후 ' + day.dayOffset + '일이 지난 회원만)</span>'
            + '</div></div>').join('');
    }

    // ── 주차 코호트 표 (칸 색 = 유지율) ──
    function renderCohortTable(weekCohorts) {
        const weekOffsetCount = weekCohorts.length > 0 ? weekCohorts[0].retainedCounts.length : 0;
        let headerHtml = '<tr><th>가입 주 시작</th><th class="text-right">가입</th>';
        for (let weekOffset = 0; weekOffset < weekOffsetCount; weekOffset++) headerHtml += '<th class="text-center">' + weekOffset + '주</th>';
        document.getElementById('cohortHead').innerHTML = headerHtml + '</tr>';

        document.getElementById('cohortBody').innerHTML = weekCohorts.length === 0
            ? '<tr><td colspan="' + (weekOffsetCount + 2) + '" class="text-center text-base-content/50 py-6">이 기간 가입자가 없습니다.</td></tr>'
            : weekCohorts.map(cohort => {
                const cells = cohort.retentionRatePercents.map((ratePercent, weekOffset) => {
                    if (ratePercent === null || ratePercent === undefined) return '<td class="text-center text-base-content/30">-</td>';
                    const alpha = Math.min(ratePercent / 100, 1) * COHORT_CELL_MAX_ALPHA;
                    return '<td class="text-center text-xs" style="background-color: color-mix(in oklab, var(--color-primary) ' + Math.round(alpha * 100) + '%, transparent)"'
                        + ' title="' + formatNumber(cohort.retainedCounts[weekOffset]) + '명">' + formatPercent(ratePercent, 0) + '</td>';
                }).join('');
                return '<tr><td class="whitespace-nowrap">' + escapeHtml(cohort.weekStartDate) + '</td>'
                    + '<td class="text-right">' + formatNumber(cohort.cohortSize) + '</td>' + cells + '</tr>';
            }).join('');
    }

    // ── 기능별 사용률 ──
    function renderFeatureUsages(retention) {
        document.getElementById('activeMemberSummary').textContent = '기간 내 활동 회원 ' + formatNumber(retention.activeMemberCount) + '명 기준';
        document.getElementById('featureUsageBody').innerHTML = retention.featureUsages.map(feature =>
            '<tr><td>' + escapeHtml(feature.featureLabel) + '</td>'
            + '<td class="text-right">' + formatNumber(feature.userCount) + '</td>'
            + '<td><div class="flex items-center gap-2"><progress class="progress progress-primary w-full" value="' + feature.ratePercent + '" max="100"></progress>'
            + '<span class="text-xs w-14 text-right">' + formatPercent(feature.ratePercent) + '</span></div></td></tr>').join('');
    }

    function loadRetention(queryString) {
        loadBlock(document.getElementById('retentionBlock'), API_BASE + '?' + queryString, retention => {
            renderDayRetentionCards(retention.dayRetentions || []);
            renderCohortTable(retention.weekCohorts || []);
            renderFeatureUsages(retention);
            return true;
        });
    }

    // ── 시작: 기본 최근 8주 가입자, 기간이 바뀔 때마다 다시 조회 ──
    AdminPeriodFilter.bind(document.querySelector('[data-period-filter]'), {
        defaultPreset: 'LAST_56',
        csvBaseUrl: API_BASE + '/export.csv',
        onChange: period => loadRetention(period.queryString)
    });
})();
