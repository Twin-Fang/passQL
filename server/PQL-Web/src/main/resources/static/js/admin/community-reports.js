/**
 * 관리자 커뮤니티 신고 관리: 신고 글 목록, 숨김·복원·삭제·신고 기각
 * API: /admin/api/community/reports (AdminApi 공통 요청)
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/community/reports';
    const STATUS_LABEL = { VISIBLE: '노출', HIDDEN_AUTO: '자동 숨김', HIDDEN_ADMIN: '관리자 숨김', DELETED: '삭제' };
    const STATUS_BADGE = { VISIBLE: 'badge-ghost', HIDDEN_AUTO: 'badge-warning', HIDDEN_ADMIN: 'badge-error', DELETED: 'badge-neutral' };
    // 처리 동작: 키 > 버튼 문구, 확인 창 필요 여부
    const ACTIONS = {
        hide: { label: '숨김', isDanger: false },
        restore: { label: '복원', isDanger: false },
        dismiss: { label: '기각', isDanger: false },
        delete: { label: '삭제', isDanger: true }
    };

    const pendingOnlyToggle = document.getElementById('pendingOnly');
    const tableBody = document.getElementById('communityReportBody');
    const summaryBadges = document.getElementById('summaryBadges');
    const pager = document.getElementById('communityReportPager');
    const escapeHtml = AdminUi.escapeHtml;
    let currentPage = 0;

    pendingOnlyToggle.addEventListener('change', () => loadCommunityReports(0));

    async function loadCommunityReports(page = currentPage) {
        currentPage = page;
        const params = new URLSearchParams({ page: String(page), pendingOnly: String(pendingOnlyToggle.checked) });
        try {
            const data = await AdminApi.get(API_BASE + '?' + params.toString());
            renderSummary(data);
            renderRows(data.content);
            renderPager(data);
        } catch (error) {
            tableBody.innerHTML = '<tr><td colspan="6" class="text-center py-12 text-error">'
                + escapeHtml(error.message || '불러오지 못했습니다.') + '</td></tr>';
        }
    }

    function renderSummary(data) {
        summaryBadges.innerHTML =
            '<div class="badge badge-warning badge-lg">검토 대기 글 <span class="ml-1 font-bold">' + data.pendingPostCount + '</span></div>'
            + '<div class="badge badge-neutral badge-lg">현재 목록 <span class="ml-1 font-bold">' + data.totalElements + '</span></div>';
    }

    function renderRows(posts) {
        if (!posts || posts.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="6" class="text-center text-base-content/50 py-12">신고된 글이 없습니다.</td></tr>';
            return;
        }
        tableBody.innerHTML = posts.map(post => {
            const reasons = post.reports.map(report =>
                '<li><span class="badge badge-outline badge-xs mr-1">' + escapeHtml(report.categoryLabel) + '</span>'
                + escapeHtml(report.detail || '') + '</li>').join('');
            const content = post.content ? escapeHtml(post.content) : '<span class="text-base-content/40">(내용 없음)</span>';
            const buttons = Object.keys(ACTIONS).map(action =>
                '<button class="btn btn-xs ' + (ACTIONS[action].isDanger ? 'btn-error' : 'btn-outline') + '" data-action="' + action
                + '" data-uuid="' + post.postUuid + '">' + ACTIONS[action].label + '</button>').join(' ');
            return '<tr>'
                + '<td class="font-bold text-center">' + post.reportCount + '</td>'
                + '<td class="text-sm">' + escapeHtml(post.authorNickname) + '</td>'
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

    // 처리 버튼 위임: 삭제는 확인 창 후 실행
    tableBody.addEventListener('click', async event => {
        const button = event.target.closest('button[data-action]');
        if (!button) return;
        const action = ACTIONS[button.dataset.action];
        if (action.isDanger && !(await AdminUi.confirmDanger('이 글을 삭제할까요? 내용이 비워지고 되돌릴 수 없습니다.', { confirmLabel: action.label }))) {
            return;
        }
        try {
            await AdminApi.post(API_BASE + '/' + button.dataset.uuid + '/' + button.dataset.action);
            AdminUi.toast(action.label + ' 처리했습니다.');
            loadCommunityReports();
        } catch (error) {
            AdminUi.showError(error);
        }
    });

    pager.addEventListener('click', event => {
        const button = event.target.closest('button[data-page]');
        if (button && !button.disabled) loadCommunityReports(Number(button.dataset.page));
    });

    window.loadCommunityReports = loadCommunityReports;
    lucide.createIcons();
    loadCommunityReports(0);
})();
