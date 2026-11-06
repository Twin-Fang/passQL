/**
 * 관리자 모의고사 회차 목록 (#866): 회차 표, 자동 구성(회차 번호·제목·토픽별 문항 수, 과목 합계 검사), 출제 가능 문제 수
 * API: GET/POST /admin/api/mock-exams/rounds, GET /admin/api/mock-exams/eligible-counts
 */
(function () {
    'use strict';

    const mockExam = MockExamAdmin;
    const { formatNumber, formatPercent, formatDateTime } = AdminChart;
    const escapeHtml = AdminUi.escapeHtml;
    const ROUND_TABLE_COLUMN_COUNT = 9;
    const SUBJECT_CODES = Object.keys(mockExam.SUBJECT_QUESTION_COUNT_BY_CODE);

    const pageElement = document.getElementById('mockExamPage');
    const roundTableBody = document.getElementById('roundTableBody');
    const composeForm = document.getElementById('composeForm');
    const composeRoundNumberInput = document.getElementById('composeRoundNumber');
    const composeTitleInput = document.getElementById('composeTitle');
    const composeTopicBody = document.getElementById('composeTopicBody');
    const composeSubmitButton = document.getElementById('composeSubmitButton');
    const composeShortageNotice = document.getElementById('composeShortageNotice');
    const eligibleSummary = document.getElementById('eligibleSummary');
    // 조회 전용(VIEWER) 계정이면 구성 버튼 비활성
    const canWriteAdmin = pageElement.dataset.canWriteAdmin === 'true';

    // 토픽 코드 > 출제 가능 문제 수 행 (구성 입력 검사용)
    let eligibleCountByTopicCode = {};
    // 제목을 직접 고쳤으면 회차 번호가 바뀌어도 기본 제목으로 덮어쓰지 않음
    let isTitleEditedByAdmin = false;

    function toDefaultTitle(roundNumber) {
        return '제' + roundNumber + '회 모의고사';
    }

    // ── 회차 목록 ──
    async function loadRounds() {
        try {
            const rounds = await AdminApi.get(mockExam.API_BASE + '/rounds') || [];
            renderRounds(rounds);
            fillDefaultRoundNumber(rounds);
        } catch (error) {
            roundTableBody.innerHTML = '<tr><td colspan="' + ROUND_TABLE_COLUMN_COUNT + '" class="text-center py-12 text-error">'
                + escapeHtml(error.message || '불러오지 못했습니다.') + '</td></tr>';
        }
    }

    function renderRounds(rounds) {
        if (rounds.length === 0) {
            roundTableBody.innerHTML = '<tr><td colspan="' + ROUND_TABLE_COLUMN_COUNT + '" class="text-center py-12 text-base-content/50">'
                + '아직 회차가 없습니다. 아래에서 첫 회차를 자동 구성하세요.</td></tr>';
            return;
        }
        roundTableBody.innerHTML = rounds.map(round => {
            const checkBadge = round.publishCheckErrorCount > 0
                ? '<span class="badge badge-warning badge-sm whitespace-nowrap">점검 필요 ' + formatNumber(round.publishCheckErrorCount) + '</span>'
                : '<span class="text-base-content/40 text-xs">-</span>';
            return '<tr class="cursor-pointer hover:bg-base-200" data-href="' + escapeHtml(mockExam.toRoundDetailPath(round.roundUuid)) + '">'
                + '<td class="font-bold">' + formatNumber(round.roundNumber) + '</td>'
                + '<td>' + escapeHtml(round.title) + '</td>'
                + '<td>' + mockExam.toRoundStatusBadge(round.status) + '</td>'
                + '<td class="text-right">' + formatNumber(round.itemCount) + '</td>'
                + '<td class="text-right">' + formatNumber(round.attemptCount) + ' / ' + formatNumber(round.submittedCount) + '</td>'
                + '<td class="text-right">' + formatNumber(round.averageScore, 1) + '</td>'
                + '<td class="text-right">' + formatPercent(round.passRatePercent, 0) + '</td>'
                + '<td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(round.publishedAt)) + '</td>'
                + '<td>' + checkBadge + '</td></tr>';
        }).join('');
    }

    /** 회차 번호 기본값 = 가장 큰 번호 + 1 (입력이 비어 있을 때만) */
    function fillDefaultRoundNumber(rounds) {
        if (composeRoundNumberInput.value) return;
        const maximumRoundNumber = rounds.reduce((maximum, round) => Math.max(maximum, round.roundNumber), 0);
        composeRoundNumberInput.value = String(maximumRoundNumber + 1);
        if (!isTitleEditedByAdmin) composeTitleInput.value = toDefaultTitle(maximumRoundNumber + 1);
    }

    roundTableBody.addEventListener('click', event => {
        const row = event.target.closest('tr[data-href]');
        if (row) location.href = row.dataset.href;
    });

    // ── 출제 가능 문제 수 + 구성 입력 표 ──
    async function loadEligibleCounts() {
        try {
            const eligibleCounts = await AdminApi.get(mockExam.API_BASE + '/eligible-counts') || [];
            eligibleCountByTopicCode = {};
            eligibleCounts.forEach(eligibleCount => { eligibleCountByTopicCode[eligibleCount.topicCode] = eligibleCount; });
            renderComposeTopicRows(eligibleCounts);
            renderEligibleSummary(eligibleCounts);
            refreshComposeTotals();
        } catch (error) {
            composeTopicBody.innerHTML = '<tr><td colspan="4" class="text-center py-6 text-error">' + escapeHtml(error.message || '불러오지 못했습니다.') + '</td></tr>';
            eligibleSummary.innerHTML = '<p class="text-error">' + escapeHtml(error.message || '불러오지 못했습니다.') + '</p>';
        }
    }

    function renderComposeTopicRows(eligibleCounts) {
        composeTopicBody.innerHTML = eligibleCounts.map(eligibleCount =>
            '<tr data-topic-row="' + escapeHtml(eligibleCount.topicCode) + '">'
            + '<td class="text-xs whitespace-nowrap">' + escapeHtml(mockExam.toLabel(mockExam.SUBJECT_LABEL_BY_CODE, eligibleCount.subject)) + '</td>'
            + '<td>' + escapeHtml(eligibleCount.topicName) + ' <span class="text-xs text-base-content/40 font-mono">' + escapeHtml(eligibleCount.topicCode) + '</span></td>'
            + '<td class="text-right" data-role="eligible">' + formatNumber(eligibleCount.eligibleQuestionCount) + '</td>'
            + '<td><input type="number" min="0" class="input input-xs input-bordered w-20" aria-label="' + escapeHtml(eligibleCount.topicName) + ' 문항 수"'
            + ' data-topic-code="' + escapeHtml(eligibleCount.topicCode) + '" data-subject="' + escapeHtml(eligibleCount.subject) + '"'
            + ' value="' + Number(eligibleCount.defaultTargetCount) + '"/></td></tr>').join('')
            || '<tr><td colspan="4" class="text-center py-6 text-base-content/50">토픽이 없습니다.</td></tr>';
    }

    /** 과목별 출제 가능 합계 vs 필요 문항 수, 기본 비율보다 모자란 토픽 */
    function renderEligibleSummary(eligibleCounts) {
        eligibleSummary.innerHTML = SUBJECT_CODES.map(subjectCode => {
            const subjectTopics = eligibleCounts.filter(eligibleCount => eligibleCount.subject === subjectCode);
            const eligibleTotal = subjectTopics.reduce((sum, eligibleCount) => sum + eligibleCount.eligibleQuestionCount, 0);
            const requiredCount = mockExam.SUBJECT_QUESTION_COUNT_BY_CODE[subjectCode];
            const shortTopics = subjectTopics.filter(eligibleCount => eligibleCount.eligibleQuestionCount < eligibleCount.defaultTargetCount);
            const isSubjectShort = eligibleTotal < requiredCount;
            return '<div class="border border-base-300 rounded-lg p-3 space-y-2">'
                + '<div class="flex items-center justify-between">'
                + '<span class="font-semibold">' + escapeHtml(mockExam.SUBJECT_LABEL_BY_CODE[subjectCode]) + '</span>'
                + '<span class="badge badge-sm ' + (isSubjectShort ? 'badge-error' : 'badge-success') + '">'
                + formatNumber(eligibleTotal) + ' / 필요 ' + formatNumber(requiredCount) + '</span></div>'
                + '<ul class="space-y-1 text-xs">' + subjectTopics.map(eligibleCount => {
                    const isShort = eligibleCount.eligibleQuestionCount < eligibleCount.defaultTargetCount;
                    return '<li class="flex justify-between gap-2' + (isShort ? ' text-error font-semibold' : '') + '">'
                        + '<span>' + escapeHtml(eligibleCount.topicName) + '</span>'
                        + '<span class="whitespace-nowrap">' + formatNumber(eligibleCount.eligibleQuestionCount)
                        + ' <span class="text-base-content/40">/ 기본 ' + formatNumber(eligibleCount.defaultTargetCount) + '</span></span></li>';
                }).join('') + '</ul>'
                + (shortTopics.length > 0 ? '<p class="text-xs text-error">기본 비율보다 모자란 토픽 ' + shortTopics.length + '개, 문제 등록이 필요해요</p>' : '')
                + '</div>';
        }).join('');
    }

    function readTopicCountInputs() {
        return Array.from(composeTopicBody.querySelectorAll('input[data-topic-code]'));
    }

    /** 과목별 합계 배지 갱신, 출제 가능보다 많이 요청한 토픽 표시, 합계가 맞을 때만 구성 버튼 활성 */
    function refreshComposeTotals() {
        const totalBySubject = {};
        const shortTopicNames = [];
        readTopicCountInputs().forEach(input => {
            const requestedCount = Math.max(0, Number(input.value) || 0);
            totalBySubject[input.dataset.subject] = (totalBySubject[input.dataset.subject] || 0) + requestedCount;
            const eligibleCount = eligibleCountByTopicCode[input.dataset.topicCode];
            const isShort = eligibleCount && requestedCount > eligibleCount.eligibleQuestionCount;
            input.closest('tr').classList.toggle('bg-warning/10', Boolean(isShort));
            if (isShort) shortTopicNames.push(eligibleCount.topicName);
        });

        let isEverySubjectMatched = true;
        SUBJECT_CODES.forEach(subjectCode => {
            const total = totalBySubject[subjectCode] || 0;
            const requiredCount = mockExam.SUBJECT_QUESTION_COUNT_BY_CODE[subjectCode];
            const isMatched = total === requiredCount;
            isEverySubjectMatched = isEverySubjectMatched && isMatched;
            const badge = composeForm.querySelector('[data-subject-total="' + subjectCode + '"]');
            badge.className = 'badge ' + (isMatched ? 'badge-success' : 'badge-error');
            badge.textContent = mockExam.SUBJECT_LABEL_BY_CODE[subjectCode] + ' ' + total + ' / ' + requiredCount;
        });

        composeShortageNotice.hidden = shortTopicNames.length === 0;
        composeShortageNotice.textContent = '출제 가능보다 많이 요청: ' + shortTopicNames.join(', ') + ' (같은 과목 다른 토픽으로 채움)';
        composeSubmitButton.disabled = !canWriteAdmin || !isEverySubjectMatched || readTopicCountInputs().length === 0;
        composeSubmitButton.title = canWriteAdmin ? (isEverySubjectMatched ? '' : '과목 합계를 1과목 10, 2과목 40으로 맞추세요.')
            : '조회 전용 계정은 변경할 수 없습니다.';
    }

    composeTopicBody.addEventListener('input', refreshComposeTotals);
    composeTitleInput.addEventListener('input', () => { isTitleEditedByAdmin = true; });
    composeRoundNumberInput.addEventListener('input', () => {
        if (!isTitleEditedByAdmin && composeRoundNumberInput.value) composeTitleInput.value = toDefaultTitle(composeRoundNumberInput.value);
    });

    // ── 자동 구성: 요청 > 경고 있으면 결과 창, 없으면 바로 회차 상세 ──
    composeForm.addEventListener('submit', async event => {
        event.preventDefault();
        if (composeSubmitButton.disabled) return;
        const questionCountByTopicCode = {};
        readTopicCountInputs().forEach(input => { questionCountByTopicCode[input.dataset.topicCode] = Math.max(0, Number(input.value) || 0); });
        const request = {
            roundNumber: Number(composeRoundNumberInput.value),
            title: composeTitleInput.value.trim(),
            questionCountByTopicCode
        };
        composeSubmitButton.disabled = true;
        try {
            const composeResult = await AdminApi.post(mockExam.API_BASE + '/rounds', request);
            const detailPath = mockExam.toRoundDetailPath(composeResult.roundUuid);
            const summaryMessage = '제' + request.roundNumber + '회 초안 ' + composeResult.itemCount + '문항을 구성했습니다.';
            if (!composeResult.warnings || composeResult.warnings.length === 0) {
                AdminUi.navigateWithToast(detailPath, summaryMessage);
                return;
            }
            showComposeWarnings(summaryMessage, composeResult.warnings, detailPath);
        } catch (error) {
            AdminUi.showError(error);
            refreshComposeTotals();
        }
    });

    function showComposeWarnings(summaryMessage, warnings, detailPath) {
        document.getElementById('composeResultSummary').textContent = summaryMessage + ' 아래 경고를 확인한 뒤 상세에서 문항을 바꿀 수 있어요.';
        document.getElementById('composeResultWarningCount').textContent = formatNumber(warnings.length);
        document.getElementById('composeResultWarnings').innerHTML = warnings.map(warning => '<li>' + escapeHtml(warning) + '</li>').join('');
        document.getElementById('composeResultDetailLink').href = detailPath;
        // ESC 로 닫아도 회차 상세로 이동
        document.getElementById('composeResultModal').addEventListener('close', () => location.href = detailPath, { once: true });
        document.getElementById('composeResultModal').showModal();
    }

    document.getElementById('reloadRoundsButton').addEventListener('click', () => {
        loadRounds();
        loadEligibleCounts();
    });

    loadRounds();
    loadEligibleCounts();
})();
