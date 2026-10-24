/**
 * 관리자 커뮤니티 신고 관리: 신고 글 목록(사유·정렬 필터), 처리 통계, 숨김·복원·삭제·기각(글 단위·일괄), 신고 1건 기각, 처리 사유 메모·이력
 * API: /admin/api/community/reports (AdminApi 공통 요청)
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/community/reports';
    const STATUS_LABEL = { VISIBLE: '노출', HIDDEN_AUTO: '자동 숨김', HIDDEN_ADMIN: '관리자 숨김', DELETED: '삭제' };
    const STATUS_BADGE = { VISIBLE: 'badge-ghost', HIDDEN_AUTO: 'badge-warning', HIDDEN_ADMIN: 'badge-error', DELETED: 'badge-neutral' };
    // 신고 1건 처리 상태: 코드 > 표시 이름, 배지 색
    const REPORT_STATUS_LABEL = { PENDING: '대기', RESOLVED: '처리 완료', DISMISSED: '기각' };
    const REPORT_STATUS_BADGE = { PENDING: 'badge-warning', RESOLVED: 'badge-success', DISMISSED: 'badge-ghost' };
    // 신고 사유 필터: 서버 CommunityReportCategory 와 같은 코드
    const CATEGORY_LABEL_BY_CODE = { ABUSE: '욕설·비방', SPAM: '광고·스팸', ANSWER_SPOILER: '정답 노출', ETC: '기타' };
    // 정렬: 서버 CommunityAdminPostSort 와 같은 코드 (기본 신고 많은 순)
    const SORT_LABEL_BY_CODE = { MOST_REPORTED: '신고 많은 순', NEWEST: '최신순', OLDEST: '오래된순' };
    // 글 단위 처리 동작: 키 > 버튼 문구, 안내 문구, 삭제처럼 위험한 동작 여부
    const ACTIONS = {
        hide: { label: '숨김', message: '이 글을 숨깁니다. 대기 신고는 처리 완료로 닫힙니다.', isDanger: false },
        restore: { label: '복원', message: '이 글을 다시 노출합니다. 대기 신고는 기각으로 닫힙니다.', isDanger: false },
        dismiss: { label: '기각', message: '대기 신고를 모두 기각합니다. 자동 숨김 글은 복원됩니다.', isDanger: false },
        delete: { label: '삭제', message: '이 글을 삭제합니다. 내용이 비워지고 되돌릴 수 없습니다.', isDanger: true }
    };
    // 일괄 처리 동작 (서버 bulk API 의 action 값)
    const BULK_ACTION_LABEL = { dismiss: '기각', hide: '숨김' };
    // 통계 평균 처리 시간 소수 자리
    const AVERAGE_HOURS_FRACTION_DIGITS = 1;
    const TABLE_COLUMN_COUNT = 7;

    const pendingOnlyToggle = document.getElementById('pendingOnly');
    const categoryFilter = document.getElementById('categoryFilter');
    const sortFilter = document.getElementById('reportSortFilter');
    const tableBody = document.getElementById('communityReportBody');
    const summaryBadges = document.getElementById('summaryBadges');
    const statsElement = document.getElementById('reportStats');
    const pager = document.getElementById('communityReportPager');
    const bulkBar = document.getElementById('communityReportBulkBar');
    const bulkCount = document.getElementById('communityReportBulkCount');
    // 조회 전용(VIEWER) 계정이면 처리 버튼 비활성
    const canWriteAdmin = document.getElementById('communityReportCard').dataset.canWriteAdmin === 'true';
    const escapeHtml = AdminUi.escapeHtml;
    let currentPage = 0;

    // 선택 수가 0이면 일괄 작업 바 숨김 (조회 전용 계정은 항상 숨김)
    const bulkSelection = AdminBulkSelect.attach(document.getElementById('communityReportCard'), selectedCount => {
        bulkCount.textContent = selectedCount;
        bulkBar.classList.toggle('hidden', selectedCount === 0 || !canWriteAdmin);
    });

    function fillSelectOptions(selectElement, labelByCode) {
        Object.keys(labelByCode).forEach(code => {
            const option = document.createElement('option');
            option.value = code;
            option.textContent = labelByCode[code];
            selectElement.appendChild(option);
        });
    }

    async function loadCommunityReports(page = currentPage) {
        currentPage = page;
        const params = new URLSearchParams({ page: String(page), pendingOnly: String(pendingOnlyToggle.checked) });
        if (categoryFilter.value) params.set('category', categoryFilter.value);
        if (sortFilter.value) params.set('sort', sortFilter.value);
        try {
            const data = await AdminApi.get(API_BASE + '?' + params.toString());
            renderSummary(data);
            renderRows(data.content);
            renderPager(data);
        } catch (error) {
            tableBody.innerHTML = '<tr><td colspan="' + TABLE_COLUMN_COUNT + '" class="text-center py-12 text-error">'
                + escapeHtml(error.message || '불러오지 못했습니다.') + '</td></tr>';
        }
        bulkSelection.refresh();
        loadReportStats();
    }

    function renderSummary(data) {
        summaryBadges.innerHTML =
            '<div class="badge badge-warning badge-lg">검토 대기 글 <span class="ml-1 font-bold">' + data.pendingPostCount + '</span></div>'
            + '<div class="badge badge-neutral badge-lg">현재 목록 <span class="ml-1 font-bold">' + data.totalElements + '</span></div>';
    }

    /** 처리 통계: 대기 신고 수, 최근 N일 처리 완료·기각 건수, 평균 처리 시간 */
    async function loadReportStats() {
        try {
            const stats = await AdminApi.get(API_BASE + '/stats');
            const averageHours = stats.averageHandlingHours === null || stats.averageHandlingHours === undefined
                ? '-' : stats.averageHandlingHours.toFixed(AVERAGE_HOURS_FRACTION_DIGITS) + '시간';
            statsElement.innerHTML =
                '<span>대기 신고 <b>' + stats.pendingReportCount + '</b>건</span>'
                + '<span>· 최근 ' + stats.handledDays + '일 처리 완료 <b>' + stats.resolvedCount + '</b>건</span>'
                + '<span>· 기각 <b>' + stats.dismissedCount + '</b>건</span>'
                + '<span>· 평균 처리 시간 <b>' + averageHours + '</b></span>'
                + '<span class="text-base-content/40">(처리 기록 도입 이후 처리분 기준)</span>';
        } catch (error) {
            statsElement.innerHTML = '';
        }
    }

    /** 신고 1건: 사유 배지·상세, 처리 상태, 처리 기록(처리자·사유·시각), 대기 신고면 건별 기각 버튼 */
    function buildReportItem(report) {
        const handledInfo = report.handledAt
            ? '<div class="text-base-content/50 ml-1">' + escapeHtml(report.handledBy || '-') + ' · ' + escapeHtml(report.handledAt.substring(0, 16).replace('T', ' '))
                + (report.handledNote ? ' · 사유: ' + escapeHtml(report.handledNote) : '') + '</div>'
            : '';
        const dismissButton = report.status === 'PENDING'
            ? ' <button class="btn btn-ghost btn-xs" data-report-action="dismiss" data-report-uuid="' + escapeHtml(report.reportUuid) + '"'
                + (canWriteAdmin ? '' : ' disabled') + '>이 신고만 기각</button>'
            : '';
        return '<li class="mb-1"><span class="badge badge-outline badge-xs mr-1">' + escapeHtml(report.categoryLabel) + '</span>'
            + '<span class="badge badge-xs mr-1 ' + (REPORT_STATUS_BADGE[report.status] || '') + '">'
            + (REPORT_STATUS_LABEL[report.status] || report.status) + '</span>'
            + escapeHtml(report.detail || '') + dismissButton + handledInfo + '</li>';
    }

    function renderRows(posts) {
        if (!posts || posts.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="' + TABLE_COLUMN_COUNT + '" class="text-center text-base-content/50 py-12">신고된 글이 없습니다.</td></tr>';
            return;
        }
        tableBody.innerHTML = posts.map(post => {
            const reasons = post.reports.map(buildReportItem).join('');
            const content = post.content ? escapeHtml(post.content) : '<span class="text-base-content/40">(내용 없음)</span>';
            const buttons = Object.keys(ACTIONS).map(action =>
                '<button class="btn btn-xs ' + (ACTIONS[action].isDanger ? 'btn-error' : 'btn-outline') + '" data-action="' + action
                + '" data-uuid="' + post.postUuid + '"' + (canWriteAdmin ? '' : ' disabled') + '>' + ACTIONS[action].label + '</button>').join(' ');
            const author = post.authorMemberUuid
                ? '<a class="link link-hover" href="/admin/members/' + encodeURIComponent(post.authorMemberUuid) + '" title="작성자 회원 상세(제재)">'
                    + escapeHtml(post.authorNickname) + '</a>'
                : escapeHtml(post.authorNickname);
            return '<tr>'
                + '<td><input type="checkbox" class="checkbox checkbox-xs bulk-row-checkbox" value="' + escapeHtml(post.postUuid) + '"'
                + (canWriteAdmin ? '' : ' disabled') + ' aria-label="글 선택"/></td>'
                + '<td class="font-bold text-center">' + post.reportCount + '</td>'
                + '<td class="text-sm">' + author + '</td>'
                + '<td><div class="text-sm whitespace-pre-line break-words">' + content + '</div>'
                + '<ul class="text-xs text-base-content/60 mt-1">' + reasons + '</ul></td>'
                + '<td><span class="badge badge-sm ' + (STATUS_BADGE[post.status] || '') + '">' + (STATUS_LABEL[post.status] || post.status) + '</span></td>'
                + '<td class="text-xs">' + (post.createdAt ? post.createdAt.substring(0, 10) : '-') + '</td>'
                + '<td class="flex flex-wrap gap-1">' + buttons + '</td></tr>';
        }).join('');
    }

    function renderPager(data) {
        if (data.totalPages <= 1) { pager.innerHTML = ''; return; }
        pager.innerHTML = '<div class="join">'
            + '<button class="join-item btn btn-sm" data-page="' + (data.page - 1) + '"' + (data.page <= 0 ? ' disabled' : '') + '>«</button>'
            + '<button class="join-item btn btn-sm btn-active">' + (data.page + 1) + ' / ' + data.totalPages + '</button>'
            + '<button class="join-item btn btn-sm" data-page="' + (data.page + 1) + '"' + (data.page + 1 >= data.totalPages ? ' disabled' : '') + '>»</button></div>';
    }

    // 처리 버튼 위임: 글 단위 동작은 사유 입력 창 > POST, 신고 1건 기각도 같은 방식
    tableBody.addEventListener('click', async event => {
        const reportButton = event.target.closest('button[data-report-action]');
        if (reportButton && !reportButton.disabled) {
            const reason = await AdminReasonPrompt.ask({ title: '이 신고만 기각', message: '이 신고 1건만 기각합니다. 글 상태는 그대로입니다.', confirmLabel: '기각' });
            if (reason === null) return;
            await runAndReload(() => AdminApi.post(API_BASE + '/items/' + reportButton.dataset.reportUuid + '/dismiss', { reason }), '신고를 기각했습니다.');
            return;
        }
        const button = event.target.closest('button[data-action]');
        if (!button || button.disabled) return;
        const action = ACTIONS[button.dataset.action];
        const reason = await AdminReasonPrompt.ask({ title: '글 ' + action.label, message: action.message,
            confirmLabel: action.label, isDanger: action.isDanger });
        if (reason === null) return;
        await runAndReload(() => AdminApi.post(API_BASE + '/' + button.dataset.uuid + '/' + button.dataset.action, { reason }),
            action.label + ' 처리했습니다.');
    });

    // 일괄 작업 바: 사유 입력 > 일괄 API > 결과 토스트
    bulkBar.addEventListener('click', async event => {
        const button = event.target.closest('button[data-bulk-action]');
        if (!button) return;
        const actionKey = button.dataset.bulkAction;
        const postUuids = bulkSelection.getSelectedValues();
        const reason = await AdminReasonPrompt.ask({ title: '선택한 ' + postUuids.length + '건 ' + BULK_ACTION_LABEL[actionKey],
            message: ACTIONS[actionKey].message, confirmLabel: BULK_ACTION_LABEL[actionKey] });
        if (reason === null) return;
        try {
            const result = await AdminApi.post(API_BASE + '/bulk?action=' + actionKey, { postUuids, reason });
            AdminUi.toast(BULK_ACTION_LABEL[actionKey] + ' ' + result.succeededCount + '건'
                + (result.skippedCount > 0 ? ', 건너뜀 ' + result.skippedCount + '건' : ''));
            loadCommunityReports();
        } catch (error) {
            AdminUi.showError(error);
        }
    });

    /** 처리 요청 실행 > 토스트 > 현재 페이지 다시 조회 */
    async function runAndReload(requestAction, successMessage) {
        try {
            await requestAction();
            AdminUi.toast(successMessage);
            loadCommunityReports();
        } catch (error) {
            AdminUi.showError(error);
        }
    }

    pager.addEventListener('click', event => {
        const button = event.target.closest('button[data-page]');
        if (button && !button.disabled) loadCommunityReports(Number(button.dataset.page));
    });

    pendingOnlyToggle.addEventListener('change', () => loadCommunityReports(0));
    categoryFilter.addEventListener('change', () => loadCommunityReports(0));
    sortFilter.addEventListener('change', () => loadCommunityReports(0));

    fillSelectOptions(categoryFilter, CATEGORY_LABEL_BY_CODE);
    fillSelectOptions(sortFilter, SORT_LABEL_BY_CODE);
    window.loadCommunityReports = loadCommunityReports;
    lucide.createIcons();
    loadCommunityReports(0);
})();
