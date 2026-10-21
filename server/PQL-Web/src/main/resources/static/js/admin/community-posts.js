/**
 * 관리자 토론 게시글 관리: 필터(게시판·상태·키워드) 목록, 페이지 이동, 숨김·복구·삭제
 * API: GET /admin/api/community/posts, POST /admin/api/community/reports/{postUuid}/{hide|restore|delete}
 */
(function () {
    'use strict';

    const LIST_API = '/admin/api/community/posts';
    const ACTION_API_BASE = '/admin/api/community/reports';
    const PAGE_SIZE = 20;
    // 목록에 보여 줄 내용 최대 글자 수 (전체는 툴팁)
    const CONTENT_PREVIEW_MAXIMUM_LENGTH = 80;
    const TABLE_COLUMN_COUNT = 9;
    // 처리 동작 3개: 키 > 버튼 문구, 확인 창 문구, 버튼 색, 보이는 상태 조건
    const POST_ACTIONS = {
        hide: { label: '숨김', confirmMessage: '이 글을 숨길까요? 회원에게 보이지 않게 됩니다.', buttonClass: 'btn-outline',
            isAvailable: status => status === 'VISIBLE' },
        restore: { label: '복구', confirmMessage: '이 글을 다시 노출할까요?', buttonClass: 'btn-outline',
            isAvailable: status => status === 'HIDDEN_AUTO' || status === 'HIDDEN_ADMIN' },
        delete: { label: '삭제', confirmMessage: '이 글을 삭제할까요? 내용이 비워지고 되돌릴 수 없습니다.', buttonClass: 'btn-error',
            isAvailable: status => status !== 'DELETED' }
    };

    const labels = AdminDisplayLabels;
    const { formatNumber, formatDateTime } = AdminChart;
    const escapeHtml = AdminUi.escapeHtml;
    const filterForm = document.getElementById('communityPostFilterForm');
    const boardTypeFilter = document.getElementById('boardTypeFilter');
    const postStatusFilter = document.getElementById('postStatusFilter');
    const keywordFilter = document.getElementById('keywordFilter');
    const totalElement = document.getElementById('communityPostTotal');
    const tableBody = document.getElementById('communityPostBody');
    const pager = document.getElementById('communityPostPager');
    // 조회 전용(VIEWER) 계정이면 동작 버튼 비활성
    const canWriteAdmin = document.getElementById('communityPostCard').dataset.canWriteAdmin === 'true';
    let currentPage = 0;

    /** 코드 > 표시 이름 매핑으로 select 선택지 채우기 */
    function fillSelectOptions(selectElement, labelByCode) {
        Object.keys(labelByCode).forEach(code => {
            const option = document.createElement('option');
            option.value = code;
            option.textContent = labelByCode[code];
            selectElement.appendChild(option);
        });
    }

    function buildListUrl(page) {
        const params = new URLSearchParams({ page: String(page), size: String(PAGE_SIZE) });
        if (boardTypeFilter.value) params.set('boardType', boardTypeFilter.value);
        if (postStatusFilter.value) params.set('status', postStatusFilter.value);
        const keyword = keywordFilter.value.trim();
        if (keyword) params.set('keyword', keyword);
        return LIST_API + '?' + params.toString();
    }

    async function loadCommunityPosts(page = currentPage) {
        currentPage = page;
        try {
            const postPage = await AdminApi.get(buildListUrl(page)) || {};
            totalElement.textContent = '총 ' + formatNumber(postPage.totalElements || 0) + '건';
            renderRows(postPage.content || []);
            renderPager(postPage);
        } catch (error) {
            totalElement.textContent = '-';
            pager.innerHTML = '';
            tableBody.innerHTML = '<tr><td colspan="' + TABLE_COLUMN_COUNT + '" class="text-center py-12 text-error">'
                + escapeHtml(error.message || '불러오지 못했습니다.') + '</td></tr>';
        }
    }

    function toContentPreview(content) {
        if (!content) return '<span class="text-base-content/40">(내용 없음)</span>';
        const preview = content.length > CONTENT_PREVIEW_MAXIMUM_LENGTH ? content.substring(0, CONTENT_PREVIEW_MAXIMUM_LENGTH) + '…' : content;
        return '<span title="' + escapeHtml(content) + '">' + escapeHtml(preview) + '</span>';
    }

    /** 상태별 가능한 동작 버튼 (조회 전용이면 disabled) */
    function buildActionButtons(post) {
        return Object.keys(POST_ACTIONS)
            .filter(actionKey => POST_ACTIONS[actionKey].isAvailable(post.status))
            .map(actionKey => '<button type="button" class="btn btn-xs ' + POST_ACTIONS[actionKey].buttonClass + '"'
                + ' data-action="' + actionKey + '" data-uuid="' + escapeHtml(post.postUuid) + '"'
                + (canWriteAdmin ? '' : ' disabled title="조회 전용 계정은 변경할 수 없습니다."') + '>'
                + POST_ACTIONS[actionKey].label + '</button>').join(' ');
    }

    function renderRows(posts) {
        if (posts.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="' + TABLE_COLUMN_COUNT + '" class="text-center text-base-content/50 py-12">조건에 맞는 글이 없습니다.</td></tr>';
            return;
        }
        tableBody.innerHTML = posts.map(post => {
            const statusBadgeClass = labels.postStatusBadgeClassByCode[post.status] || 'badge-ghost';
            const reportCountClass = post.reportCount > 0 ? ' text-warning font-bold' : '';
            return '<tr>'
                + '<td class="text-xs whitespace-nowrap">' + escapeHtml(labels.toLabel(labels.boardTypeLabelByCode, post.boardType)) + '</td>'
                + '<td class="text-sm break-words max-w-md">' + toContentPreview(post.content) + '</td>'
                + '<td class="text-sm">' + escapeHtml(post.authorNickname || '-') + '</td>'
                + '<td class="text-right">' + formatNumber(post.likeCount) + '</td>'
                + '<td class="text-right">' + formatNumber(post.commentCount) + '</td>'
                + '<td class="text-right' + reportCountClass + '">' + formatNumber(post.reportCount) + '</td>'
                + '<td><span class="badge badge-sm whitespace-nowrap ' + statusBadgeClass + '">'
                + escapeHtml(labels.toLabel(labels.postStatusLabelByCode, post.status)) + '</span></td>'
                + '<td class="text-xs whitespace-nowrap">' + escapeHtml(formatDateTime(post.createdAt)) + '</td>'
                + '<td><div class="flex flex-wrap gap-1">' + buildActionButtons(post) + '</div></td></tr>';
        }).join('');
    }

    function renderPager(postPage) {
        const totalPages = postPage.totalPages || 0;
        const page = postPage.page || 0;
        if (totalPages <= 1) { pager.innerHTML = ''; return; }
        pager.innerHTML = '<div class="join">'
            + '<button class="join-item btn btn-sm" data-page="' + (page - 1) + '"' + (page <= 0 ? ' disabled' : '') + '>«</button>'
            + '<button class="join-item btn btn-sm btn-active">' + (page + 1) + ' / ' + totalPages + '</button>'
            + '<button class="join-item btn btn-sm" data-page="' + (page + 1) + '"' + (page + 1 >= totalPages ? ' disabled' : '') + '>»</button></div>';
    }

    // 동작 버튼 위임: 확인 창 > POST > 토스트 > 현재 페이지 다시 조회
    tableBody.addEventListener('click', async event => {
        const button = event.target.closest('button[data-action]');
        if (!button || button.disabled) return;
        const action = POST_ACTIONS[button.dataset.action];
        const isConfirmed = await AdminUi.confirmDanger(action.confirmMessage, { title: '글 ' + action.label, confirmLabel: action.label });
        if (!isConfirmed) return;
        button.disabled = true;
        try {
            await AdminApi.post(ACTION_API_BASE + '/' + encodeURIComponent(button.dataset.uuid) + '/' + button.dataset.action);
            AdminUi.toast(action.label + ' 처리했습니다.');
            loadCommunityPosts();
        } catch (error) {
            button.disabled = false;
            AdminUi.showError(error);
        }
    });

    pager.addEventListener('click', event => {
        const button = event.target.closest('button[data-page]');
        if (button && !button.disabled) loadCommunityPosts(Number(button.dataset.page));
    });

    // 검색 (Enter 포함) > 첫 페이지, 초기화 > 값 비운 뒤 첫 페이지
    filterForm.addEventListener('submit', event => {
        event.preventDefault();
        loadCommunityPosts(0);
    });
    filterForm.addEventListener('reset', () => setTimeout(() => loadCommunityPosts(0)));
    boardTypeFilter.addEventListener('change', () => loadCommunityPosts(0));
    postStatusFilter.addEventListener('change', () => loadCommunityPosts(0));

    fillSelectOptions(boardTypeFilter, labels.boardTypeLabelByCode);
    fillSelectOptions(postStatusFilter, labels.postStatusLabelByCode);
    loadCommunityPosts(0);
})();
