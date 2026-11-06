/**
 * 관리자 모의고사 문항 통계 탭 (#866): 채점 수·정답률·안 고른 비율·보기별 선택률, 점검 신호, 미처리 신고 > 문제 상세·신고 상세 링크
 * API: GET /admin/api/mock-exams/rounds/{roundUuid}/item-stats (회차 상세 화면이 탭을 처음 열 때 loadOnce 호출)
 */
(function () {
    'use strict';

    const mockExam = MockExamAdmin;
    const { formatNumber, formatPercent } = AdminChart;
    const escapeHtml = AdminUi.escapeHtml;
    const STAT_TABLE_COLUMN_COUNT = 9;

    const statTableBody = document.getElementById('statTableBody');
    const reviewTargetOnlyFilter = document.getElementById('reviewTargetOnlyFilter');

    // 마지막으로 불러온 통계 (null 이면 다음 탭 열기에서 다시 조회)
    let loadedItemStats = null;

    /** 점검 대상: 점검 신호 2개 중 하나 또는 미처리 신고 있음 */
    function isReviewTarget(itemStat) {
        return itemStat.isLowAccuracy || itemStat.hasStrongerDistractor || itemStat.pendingReportCount > 0;
    }

    function renderMessageRow(message, toneClass) {
        statTableBody.innerHTML = '<tr><td colspan="' + STAT_TABLE_COLUMN_COUNT + '" class="text-center py-12 ' + toneClass + '">'
            + escapeHtml(message) + '</td></tr>';
    }

    /**
     * 보기별 선택률 막대: 정답 초록·굵게, 정답보다 많이 고른 오답 빨강, 나머지 회색
     * 막대 너비 = 선택률 (%)
     */
    function renderChoicePicks(itemStat) {
        const correctPick = (itemStat.choicePicks || []).find(choicePick => choicePick.isCorrect);
        const correctPickPercent = correctPick ? (correctPick.pickPercent || 0) : 0;
        return '<div class="grid grid-cols-[auto_1fr_auto] gap-x-1.5 gap-y-0.5 items-center text-xs min-w-48">'
            + (itemStat.choicePicks || []).map(choicePick => {
                const pickPercent = choicePick.pickPercent || 0;
                const isStrongerDistractor = !choicePick.isCorrect && pickPercent > correctPickPercent;
                const barClass = choicePick.isCorrect ? 'bg-success' : (isStrongerDistractor ? 'bg-error' : 'bg-base-content/30');
                const keyClass = choicePick.isCorrect ? 'font-bold text-success' : (isStrongerDistractor ? 'font-bold text-error' : '');
                return '<span class="' + keyClass + '">' + escapeHtml(choicePick.choiceKey) + (choicePick.isCorrect ? ' ✓' : '') + '</span>'
                    + '<div class="h-1.5 rounded bg-base-300 overflow-hidden"><div class="h-full ' + barClass + '" style="width:'
                    + Math.min(100, Math.max(0, pickPercent)) + '%"></div></div>'
                    + '<span class="text-right tabular-nums ' + keyClass + '">' + formatPercent(choicePick.pickPercent, 0)
                    + ' <span class="text-base-content/40">(' + formatNumber(choicePick.pickCount) + ')</span></span>';
            }).join('') + '</div>';
    }

    function renderSignals(itemStat) {
        const badges = [];
        if (itemStat.isLowAccuracy) badges.push('<span class="badge badge-error badge-sm whitespace-nowrap">정답률 30% 미만</span>');
        if (itemStat.hasStrongerDistractor) badges.push('<span class="badge badge-warning badge-sm whitespace-nowrap">오답 보기 우세</span>');
        return badges.length > 0 ? '<div class="flex flex-col gap-1">' + badges.join('') + '</div>' : '<span class="text-base-content/40 text-xs">-</span>';
    }

    function renderPendingReports(itemStat) {
        if (!itemStat.pendingReportCount) return '<span class="text-base-content/40">0</span>';
        return '<a class="badge badge-warning badge-sm" href="' + escapeHtml(mockExam.toReportDetailPath(itemStat.questionUuid))
            + '" title="신고 상세">' + formatNumber(itemStat.pendingReportCount) + '</a>';
    }

    function renderItemStats() {
        if (!loadedItemStats) return;
        const visibleItemStats = reviewTargetOnlyFilter.checked ? loadedItemStats.filter(isReviewTarget) : loadedItemStats;
        if (visibleItemStats.length === 0) {
            renderMessageRow(reviewTargetOnlyFilter.checked ? '점검 대상 문항이 없습니다.' : '문항이 없습니다.', 'text-base-content/50');
            return;
        }
        statTableBody.innerHTML = visibleItemStats.map(itemStat =>
            '<tr' + (isReviewTarget(itemStat) ? ' class="bg-warning/10"' : '') + '>'
            + '<td class="font-bold">' + itemStat.questionNumber + '</td>'
            + '<td><span class="badge badge-outline badge-sm whitespace-nowrap">' + escapeHtml(itemStat.topicName || '-') + '</span></td>'
            + '<td class="text-sm"><a class="link link-hover" target="_blank" rel="noopener" href="'
            + escapeHtml(mockExam.toQuestionDetailPath(itemStat.questionUuid)) + '" title="문제 상세 (새 탭)">'
            + escapeHtml(itemStat.stemPreview || '(지문 없음)') + '</a></td>'
            + '<td class="text-right">' + formatNumber(itemStat.gradedCount) + '</td>'
            + '<td class="text-right' + (itemStat.isLowAccuracy ? ' text-error font-bold' : '') + '">' + formatPercent(itemStat.correctRatePercent, 0) + '</td>'
            + '<td class="text-right">' + formatPercent(itemStat.unansweredPercent, 0) + '</td>'
            + '<td>' + renderChoicePicks(itemStat) + '</td>'
            + '<td>' + renderSignals(itemStat) + '</td>'
            + '<td class="text-right">' + renderPendingReports(itemStat) + '</td></tr>').join('');
    }

    /** 통계 탭 첫 열기 1회 조회 (초안은 응시가 없어 안내만) */
    async function loadOnce(roundApiPath, roundStatus) {
        if (loadedItemStats) return;
        if (roundStatus === 'DRAFT') {
            renderMessageRow('초안 회차는 응시가 없어 통계가 없습니다. 공개 후 채점된 응시부터 집계돼요.', 'text-base-content/50');
            return;
        }
        renderMessageRow('불러오는 중...', 'text-base-content/50');
        try {
            const itemStats = await AdminApi.get(roundApiPath + '/item-stats') || [];
            if (itemStats.every(itemStat => !itemStat.gradedCount)) {
                renderMessageRow('아직 채점된 응시가 없습니다.', 'text-base-content/50');
                return;
            }
            loadedItemStats = itemStats;
            renderItemStats();
        } catch (error) {
            renderMessageRow(error.message || '불러오지 못했습니다.', 'text-error');
        }
    }

    /** 회차 상태가 바뀌면 다음 탭 열기에서 다시 조회 */
    function reset() {
        loadedItemStats = null;
    }

    reviewTargetOnlyFilter.addEventListener('change', renderItemStats);

    window.MockExamItemStats = { loadOnce, reset };
})();
