/**
 * 관리자 모의고사 응시 기록 (#866): 회차·회원 UUID 필터, 페이지 목록(시작·제출·회원·회차·상태·이유·점수·결과)
 * 주소 ?roundUuid=&memberUuid= 로 진입·검색 상태 유지 (회차 상세 "이 회차 응시 기록" 링크)
 * API: GET /admin/api/mock-exams/rounds (회차 선택지), GET /admin/api/mock-exams/attempts (Spring Page: content·number·totalPages·totalElements)
 */
(function () {
    'use strict';

    const mockExam = MockExamAdmin;
    const { formatNumber, formatDateTime } = AdminChart;
    const escapeHtml = AdminUi.escapeHtml;
    const PAGE_SIZE = 20;
    const ATTEMPT_TABLE_COLUMN_COUNT = 10;
    // 회원 UUID 형식 (서버가 UUID 로 받아 형식 오류면 400)
    const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

    const filterForm = document.getElementById('attemptFilterForm');
    const roundFilter = document.getElementById('roundFilter');
    const memberUuidFilter = document.getElementById('memberUuidFilter');
    const totalElement = document.getElementById('attemptTotal');
    const tableBody = document.getElementById('attemptTableBody');
    const pager = document.getElementById('attemptPager');
    let currentPage = 0;

    /** 회차 선택지 채우기 (주소의 roundUuid 가 목록에 없어도 선택값 유지) */
    async function loadRoundOptions(selectedRoundUuid) {
        try {
            const rounds = await AdminApi.get(mockExam.API_BASE + '/rounds') || [];
            rounds.forEach(round => {
                const option = document.createElement('option');
                option.value = round.roundUuid;
                option.textContent = mockExam.toRoundName(round.roundNumber, round.title)
                    + ' (' + mockExam.toLabel(mockExam.ROUND_STATUS_LABEL_BY_CODE, round.status) + ')';
                roundFilter.appendChild(option);
            });
        } catch (error) {
            AdminUi.showError(error);
        }
        if (selectedRoundUuid && !roundFilter.querySelector('option[value="' + CSS.escape(selectedRoundUuid) + '"]')) {
            const option = document.createElement('option');
            option.value = selectedRoundUuid;
            option.textContent = selectedRoundUuid;
            roundFilter.appendChild(option);
        }
        roundFilter.value = selectedRoundUuid || '';
    }

    /** 현재 필터 > 검색 조건 (주소·API 공통) */
    function buildFilterParams() {
        const params = new URLSearchParams();
        if (roundFilter.value) params.set('roundUuid', roundFilter.value);
        const memberUuid = memberUuidFilter.value.trim();
        if (memberUuid) params.set('memberUuid', memberUuid);
        return params;
    }

    async function loadAttempts(page = currentPage) {
        currentPage = page;
        const memberUuid = memberUuidFilter.value.trim();
        if (memberUuid && !UUID_PATTERN.test(memberUuid)) {
            AdminUi.toast('회원 UUID 형식이 아닙니다.', 'warning');
            return;
        }
        const filterParams = buildFilterParams();
        // 새로고침·공유해도 같은 조건 (페이지 번호는 주소에 남기지 않음)
        history.replaceState(null, '', location.pathname + (filterParams.toString() ? '?' + filterParams : ''));
        const apiParams = new URLSearchParams(filterParams);
        apiParams.set('page', String(page));
        apiParams.set('size', String(PAGE_SIZE));
        try {
            const attemptPage = await AdminApi.get(mockExam.API_BASE + '/attempts?' + apiParams) || {};
            totalElement.textContent = '총 ' + formatNumber(attemptPage.totalElements || 0) + '건';
            renderRows(attemptPage.content || []);
            renderPager(attemptPage);
        } catch (error) {
            totalElement.textContent = '-';
            pager.innerHTML = '';
            tableBody.innerHTML = '<tr><td colspan="' + ATTEMPT_TABLE_COLUMN_COUNT + '" class="text-center py-12 text-error">'
                + escapeHtml(error.message || '불러오지 못했습니다.') + '</td></tr>';
        }
    }

    /** 결과 배지: 풀이 중이면 '-', 합격 / 과락 / 총점 미달 */
    function renderResultBadge(attempt) {
        if (attempt.status !== 'SUBMITTED' || !attempt.failReason) return '<span class="text-base-content/40">-</span>';
        return '<span class="badge badge-sm whitespace-nowrap ' + (mockExam.RESULT_BADGE_CLASS_BY_FAIL_REASON[attempt.failReason] || 'badge-ghost') + '">'
            + escapeHtml(mockExam.toLabel(mockExam.RESULT_LABEL_BY_FAIL_REASON, attempt.failReason)) + '</span>';
    }

    /** 닉네임 > 회원 상세 링크 (닉네임이 없으면 UUID 앞 8자) */
    function renderMemberLink(attempt) {
        const memberName = attempt.memberNickname || String(attempt.memberUuid || '').substring(0, 8);
        return '<a class="link link-hover" href="' + escapeHtml(mockExam.toMemberDetailPath(attempt.memberUuid)) + '"'
            + ' title="' + escapeHtml(attempt.memberUuid) + '">' + escapeHtml(memberName) + '</a>';
    }

    function renderRows(attempts) {
        if (attempts.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="' + ATTEMPT_TABLE_COLUMN_COUNT + '" class="text-center py-12 text-base-content/50">조건에 맞는 응시 기록이 없습니다.</td></tr>';
            return;
        }
        tableBody.innerHTML = attempts.map(attempt =>
            '<tr>'
            + '<td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(attempt.startedAt)) + '</td>'
            + '<td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(attempt.submittedAt)) + '</td>'
            + '<td class="text-sm">' + renderMemberLink(attempt) + '</td>'
            + '<td class="text-sm whitespace-nowrap"><a class="link link-hover" href="' + escapeHtml(mockExam.toRoundDetailPath(attempt.roundUuid)) + '">제'
            + formatNumber(attempt.roundNumber) + '회</a></td>'
            + '<td><span class="badge badge-sm whitespace-nowrap ' + (mockExam.ATTEMPT_STATUS_BADGE_CLASS_BY_CODE[attempt.status] || 'badge-ghost') + '">'
            + escapeHtml(mockExam.toLabel(mockExam.ATTEMPT_STATUS_LABEL_BY_CODE, attempt.status)) + '</span></td>'
            + '<td class="text-xs whitespace-nowrap">' + escapeHtml(mockExam.toLabel(mockExam.SUBMIT_REASON_LABEL_BY_CODE, attempt.submitReason)) + '</td>'
            + '<td class="text-right font-bold">' + formatNumber(attempt.totalScore) + '</td>'
            + '<td class="text-right">' + formatNumber(attempt.subjectOneScore) + '</td>'
            + '<td class="text-right">' + formatNumber(attempt.subjectTwoScore) + '</td>'
            + '<td>' + renderResultBadge(attempt) + '</td></tr>').join('');
    }

    function renderPager(attemptPage) {
        const totalPages = attemptPage.totalPages || 0;
        const page = attemptPage.number || 0;
        if (totalPages <= 1) { pager.innerHTML = ''; return; }
        pager.innerHTML = '<div class="join">'
            + '<button class="join-item btn btn-sm" data-page="' + (page - 1) + '"' + (page <= 0 ? ' disabled' : '') + '>«</button>'
            + '<button class="join-item btn btn-sm btn-active">' + (page + 1) + ' / ' + totalPages + '</button>'
            + '<button class="join-item btn btn-sm" data-page="' + (page + 1) + '"' + (page + 1 >= totalPages ? ' disabled' : '') + '>»</button></div>';
    }

    pager.addEventListener('click', event => {
        const button = event.target.closest('button[data-page]');
        if (button && !button.disabled) loadAttempts(Number(button.dataset.page));
    });

    // 검색 (Enter 포함) > 첫 페이지, 회차 변경 즉시 검색, 초기화 > 값 비운 뒤 첫 페이지
    filterForm.addEventListener('submit', event => {
        event.preventDefault();
        loadAttempts(0);
    });
    roundFilter.addEventListener('change', () => loadAttempts(0));
    filterForm.addEventListener('reset', () => setTimeout(() => {
        roundFilter.value = '';
        loadAttempts(0);
    }));

    // ── 시작: 주소 조건 반영 > 회차 선택지 > 첫 페이지 ──
    const initialParams = new URLSearchParams(location.search);
    memberUuidFilter.value = initialParams.get('memberUuid') || '';
    loadRoundOptions(initialParams.get('roundUuid') || '').then(() => loadAttempts(0));
})();
