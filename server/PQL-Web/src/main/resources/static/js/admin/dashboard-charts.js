/**
 * 관리자 대시보드 차트 6종: 가입·방문 추이, AI 호출량, 학습 활동, 토론 활동, 시간대별 접속, 토픽별 문제·풀이
 * API: /admin/api/dashboard/{growth|ai-usage|learning|community|hourly-visitors|topics} (블록마다 독립 fetch)
 * KPI·AI 상태 패널은 dashboard-panels.js
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/dashboard';
    const HOURS_PER_DAY = 24;
    // 토픽 차트 높이: 토픽 1개당 (px), 최소 (px)
    const TOPIC_ROW_HEIGHT_PIXELS = 40;
    const TOPIC_CHART_MINIMUM_HEIGHT_PIXELS = 192;
    // 정답률 축 범위 (%)
    const PERCENT_AXIS_MAXIMUM = 100;

    const { renderChart, bindRangeToggle, loadBlock, formatUsd, formatMilliseconds, formatNumber, formatPercent } = AdminChart;
    const labels = AdminDisplayLabels;
    const escapeHtml = AdminUi.escapeHtml;

    // 정수 눈금 (사람 수·호출 수에 0.1 단위 눈금 방지)
    const INTEGER_TICKS = { precision: 0 };

    /** 오른쪽 보조 축 (격자 없음, 제목 표시) */
    function buildRightAxis(title, extraOptions) {
        return { position: 'right', beginAtZero: true, grid: { display: false }, title: { display: true, text: title }, ...extraOptions };
    }

    function hasLabels(responseBody) {
        return Array.isArray(responseBody.labels) && responseBody.labels.length > 0;
    }

    // ── 신규 가입·방문자 추이 (가입 막대 + 누적 회원 점선 / 방문자 선, 규모 차이로 차트 분리) ──
    function loadGrowth(range) {
        const chartBox = document.getElementById('growthChartBox');
        document.getElementById('growthCsvLink').href = API_BASE + '/growth.csv?range=' + range;
        loadBlock(chartBox, API_BASE + '/growth?range=' + range, growth => {
            if (!hasLabels(growth)) return false;
            renderChart(document.getElementById('growthSignupChart'), colors => ({
                type: 'bar',
                data: {
                    labels: growth.labels,
                    datasets: [
                        { type: 'bar', label: '신규 가입', data: growth.signupCounts, backgroundColor: colors.info, yAxisID: 'y' },
                        { type: 'line', label: '누적 회원', data: growth.cumulativeMemberCounts, borderColor: colors.translucent('baseContent', 0.45),
                            backgroundColor: colors.translucent('baseContent', 0.45), borderDash: [4, 4], yAxisID: 'y2' }
                    ]
                },
                options: { scales: { y: { beginAtZero: true, ticks: INTEGER_TICKS, title: { display: true, text: '가입(명)' } }, y2: buildRightAxis('누적 회원', { ticks: INTEGER_TICKS }) } }
            }));
            renderChart(document.getElementById('growthVisitorChart'), colors => ({
                type: 'line',
                data: {
                    labels: growth.labels,
                    datasets: [{ label: '방문자', data: growth.visitorCounts, borderColor: colors.primary, backgroundColor: colors.translucent('primary', 0.15), fill: true }]
                },
                options: { plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: INTEGER_TICKS, title: { display: true, text: '방문자(명)' } } } }
            }));
            return true;
        }, '가입·방문 기록이 없습니다.');
    }

    // ── AI 호출량 (성공/실패 누적 막대, 평균 응답 선, 툴팁에 추정 비용) ──
    function loadAiUsage(range) {
        const chartBox = document.getElementById('aiUsageChartBox');
        document.getElementById('aiUsageCsvLink').href = API_BASE + '/ai-usage.csv?range=' + range;
        loadBlock(chartBox, API_BASE + '/ai-usage?range=' + range, aiUsage => {
            if (!hasLabels(aiUsage)) return false;
            const estimatedCosts = aiUsage.estimatedCostUsd || [];
            renderChart(document.getElementById('aiUsageChart'), colors => ({
                type: 'bar',
                data: {
                    labels: aiUsage.labels,
                    datasets: [
                        { type: 'bar', label: '성공', data: aiUsage.successCounts, backgroundColor: colors.success, stack: 'calls', yAxisID: 'y' },
                        { type: 'bar', label: '실패', data: aiUsage.failureCounts, backgroundColor: colors.error, stack: 'calls', yAxisID: 'y' },
                        { type: 'line', label: '평균 응답(ms)', data: aiUsage.averageLatencyMilliseconds, borderColor: colors.warning,
                            backgroundColor: colors.warning, yAxisID: 'y2' }
                    ]
                },
                options: {
                    scales: { x: { stacked: true }, y: { stacked: true, beginAtZero: true, ticks: INTEGER_TICKS, title: { display: true, text: '호출 수' } }, y2: buildRightAxis('평균 응답(ms)') },
                    plugins: {
                        tooltip: {
                            callbacks: {
                                label: item => item.dataset.yAxisID === 'y2'
                                    ? item.dataset.label + ': ' + formatMilliseconds(item.raw)
                                    : item.dataset.label + ': ' + formatNumber(item.raw),
                                footer: items => items.length ? '추정 비용 ' + formatUsd(estimatedCosts[items[0].dataIndex]) : ''
                            }
                        }
                    }
                }
            }));
            return true;
        }, 'AI 호출 기록이 없습니다.');
    }

    // ── 학습 활동 (막대 제출 수, 선 정답률) ──
    function loadLearning() {
        const chartBox = document.getElementById('learningChartBox');
        loadBlock(chartBox, API_BASE + '/learning', learning => {
            if (!hasLabels(learning)) return false;
            renderChart(document.getElementById('learningChart'), colors => ({
                type: 'bar',
                data: {
                    labels: learning.labels,
                    datasets: [
                        { type: 'bar', label: '제출', data: learning.submissionCounts, backgroundColor: colors.translucent('success', 0.7), yAxisID: 'y' },
                        { type: 'line', label: '정답률(%)', data: learning.correctRatePercents, borderColor: colors.primary, backgroundColor: colors.primary, yAxisID: 'y2' }
                    ]
                },
                options: {
                    scales: { y: { beginAtZero: true, ticks: INTEGER_TICKS, title: { display: true, text: '제출 수' } }, y2: buildRightAxis('정답률(%)', { min: 0, max: PERCENT_AXIS_MAXIMUM }) },
                    plugins: {
                        tooltip: {
                            callbacks: {
                                label: item => item.dataset.label + ': '
                                    + (item.dataset.yAxisID === 'y2' ? formatPercent(item.raw) : formatNumber(item.raw))
                            }
                        }
                    }
                }
            }));
            return true;
        }, '제출 기록이 없습니다.');
    }

    // ── 토론 활동 (14일 새 글 막대 + 최근 글 5건 표) ──
    function loadCommunity() {
        const communityBox = document.getElementById('communityBox');
        loadBlock(communityBox, API_BASE + '/community', community => {
            renderRecentPosts(community.recentPosts || []);
            if (hasLabels(community)) {
                renderChart(document.getElementById('communityChart'), colors => ({
                    type: 'bar',
                    data: { labels: community.labels, datasets: [{ label: '새 글', data: community.postCounts, backgroundColor: colors.primary }] },
                    options: { plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
                }));
            }
            return true;
        });
    }

    function renderRecentPosts(recentPosts) {
        const tableBody = document.getElementById('recentPostBody');
        if (recentPosts.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="5" class="text-center text-base-content/50 py-6">최근 글이 없습니다.</td></tr>';
            return;
        }
        tableBody.innerHTML = recentPosts.map(post => {
            const statusBadgeClass = labels.postStatusBadgeClassByCode[post.status] || 'badge-ghost';
            const reportBadge = post.reportCount > 0
                ? ' <span class="badge badge-xs badge-warning">신고 ' + formatNumber(post.reportCount) + '</span>' : '';
            return '<tr>'
                + '<td class="whitespace-nowrap">' + escapeHtml(labels.toLabel(labels.boardTypeLabelByCode, post.boardType)) + '</td>'
                + '<td class="truncate max-w-48" title="' + escapeHtml(post.contentPreview) + '">' + escapeHtml(post.contentPreview || '(내용 없음)') + '</td>'
                + '<td class="text-right">' + formatNumber(post.likeCount) + '</td>'
                + '<td class="text-right">' + formatNumber(post.commentCount) + '</td>'
                + '<td class="whitespace-nowrap"><span class="badge badge-xs ' + statusBadgeClass + '">'
                + escapeHtml(labels.toLabel(labels.postStatusLabelByCode, post.status)) + '</span>' + reportBadge + '</td></tr>';
        }).join('');
    }

    // ── 시간대별 접속 (0~23시 평균 방문자) ──
    function loadHourlyVisitors() {
        const chartBox = document.getElementById('hourlyVisitorChartBox');
        loadBlock(chartBox, API_BASE + '/hourly-visitors', hourlyVisitors => {
            const averageVisitorCounts = hourlyVisitors.averageVisitorCounts || [];
            if (averageVisitorCounts.length === 0) return false;
            const hourLabels = Array.from({ length: HOURS_PER_DAY }, (unused, hour) => hour + '시');
            renderChart(document.getElementById('hourlyVisitorChart'), colors => ({
                type: 'bar',
                data: { labels: hourLabels, datasets: [{ label: '평균 방문자', data: averageVisitorCounts, backgroundColor: colors.primary }] },
                options: {
                    plugins: { legend: { display: false }, tooltip: { callbacks: { label: item => '평균 방문자: ' + formatNumber(item.raw, 1) + '명' } } },
                    scales: { y: { beginAtZero: true } }
                }
            }));
            return true;
        }, '접속 기록이 없습니다.');
    }

    // ── 토픽별 문제 수·풀이 수 (가로 막대, 아래 축 문제 수 / 위 축 풀이 수) ──
    function loadTopics() {
        const chartBox = document.getElementById('topicChartBox');
        loadBlock(chartBox, API_BASE + '/topics', topics => {
            if (!Array.isArray(topics) || topics.length === 0) return false;
            chartBox.style.height = Math.max(TOPIC_CHART_MINIMUM_HEIGHT_PIXELS, topics.length * TOPIC_ROW_HEIGHT_PIXELS) + 'px';
            renderChart(document.getElementById('topicChart'), colors => ({
                type: 'bar',
                data: {
                    labels: topics.map(topic => topic.topicName || '-'),
                    datasets: [
                        { label: '문제 수', data: topics.map(topic => topic.questionCount), backgroundColor: colors.primary, xAxisID: 'x' },
                        { label: '풀이 수 (30일)', data: topics.map(topic => topic.submissionCount30Days), backgroundColor: colors.warning, xAxisID: 'x2' }
                    ]
                },
                options: {
                    indexAxis: 'y',
                    scales: {
                        x: { beginAtZero: true, position: 'bottom', ticks: INTEGER_TICKS, title: { display: true, text: '문제 수' } },
                        x2: { beginAtZero: true, position: 'top', ticks: INTEGER_TICKS, grid: { display: false }, title: { display: true, text: '풀이 수 (30일)' } },
                        // 토픽 이름 전부 표시 (자동 건너뛰기 끔)
                        y: { ticks: { autoSkip: false } }
                    }
                }
            }));
            return true;
        }, '토픽 데이터가 없습니다.');
    }

    // ── 시작: 일/월 토글 블록은 연결 시 1회 로드 ──
    bindRangeToggle(document.getElementById('growthRangeToggle'), loadGrowth);
    bindRangeToggle(document.getElementById('aiUsageRangeToggle'), loadAiUsage);
    loadLearning();
    loadCommunity();
    loadHourlyVisitors();
    loadTopics();
})();
