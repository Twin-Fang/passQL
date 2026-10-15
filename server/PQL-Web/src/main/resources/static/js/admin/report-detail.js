/**
 * 신고 상세 화면: 문제·신고 목록 렌더, 미처리 신고 일괄 처리, 선택지 세트 펼치기
 * questionUuid 는 report-detail.html 인라인 스크립트가 선언
 */
let pendingReportUuids = [];

// 신고 상태 > 배지 (PENDING 미처리, RESOLVED 처리완료, DISMISSED 기각)
const REPORT_STATUS_BADGE = {
    PENDING: '<span class="badge badge-warning badge-sm">미처리</span>',
    RESOLVED: '<span class="badge badge-success badge-sm">처리완료</span>',
    DISMISSED: '<span class="badge badge-ghost badge-sm">기각</span>'
};

/** 신고 1건 기각 (보정·비활성화 없이 종료) */
async function dismissReport(reportUuid) {
    if (!await AdminUi.confirmDanger('이 신고를 기각합니다. 제출 보정이나 문제 비활성화는 하지 않습니다.', { confirmLabel: '기각' })) return;
    try {
        await AdminApi.post(`/admin/api/reports/${reportUuid}/dismiss`);
        AdminUi.toast('신고를 기각했습니다.');
        loadDetail();
    } catch (error) {
        AdminUi.showError(error);
    }
}

async function loadDetail() {
    if (!questionUuid) {
        showError('questionUuid가 없습니다.');
        return;
    }

    try {
        const data = await AdminApi.get(`/admin/api/reports/${questionUuid}`);
        renderQuestionCard(data.question);
        renderReportList(data.reports);
        setupResolvePanel(data.reports);
    } catch (e) {
        showError('데이터를 불러오는 데 실패했습니다: ' + e.message);
    }
}

function renderQuestionCard(q) {
    const activeLabel = q.isActive
        ? '<span class="badge badge-success badge-sm">활성</span>'
        : '<span class="badge badge-error badge-sm">비활성</span>';
    const uuidShort = q.questionUuid ? q.questionUuid.substring(0, 8) : '-';

    document.getElementById('questionCard').innerHTML = `
                <div class="card-body">
                    <div class="flex items-start gap-3">
                        <div class="flex-1">
                            <div class="flex items-center gap-2 mb-2">
                                <span class="font-mono text-xs text-base-content/50">${uuidShort}…</span>
                                ${activeLabel}
                            </div>
                            <p class="text-sm whitespace-pre-wrap break-words">${escapeHtml(q.stem || '')}</p>
                        </div>
                        <a href="/admin/questions/${q.questionUuid}" class="btn btn-xs btn-outline gap-1" target="_blank">
                            <i data-lucide="external-link" class="size-3"></i>
                            문제 상세
                        </a>
                    </div>
                </div>`;
    lucide.createIcons();
}

function renderReportList(reports) {
    const reportList = document.getElementById('reportList');
    const reportCount = document.getElementById('reportCount');

    if (!reports || reports.length === 0) {
        reportList.innerHTML = `
                    <div class="py-8 text-center text-base-content/50">
                        <i data-lucide="flag" class="size-8 mx-auto mb-2 opacity-40"></i>
                        <p>신고가 없습니다.</p>
                    </div>`;
        lucide.createIcons();
        return;
    }

    reportCount.textContent = reports.length + '건';

    reportList.innerHTML = reports.map(r => {
        const statusBadge = REPORT_STATUS_BADGE[r.status] || REPORT_STATUS_BADGE.RESOLVED;
        // 미처리 건만 기각 버튼 (#479)
        const dismissButton = r.status === 'PENDING'
            ? `<button class="btn btn-xs btn-ghost text-base-content/60" onclick="dismissReport('${r.reportUuid}')">기각</button>`
            : '';

        const categories = (r.categories || []).map(c => {
            const labelMap = {
                WRONG_ANSWER: '정답 오류',
                WEIRD_QUESTION: '문제 이상',
                WEIRD_CHOICES: '선택지 이상',
                WEIRD_EXECUTION: '실행 오류',
                ETC: '기타'
            };
            return `<span class="badge badge-outline badge-sm">${labelMap[c] || c}</span>`;
        }).join(' ');

        const detail = r.detail
            ? `<p class="text-sm text-base-content/70 mt-1 ml-1">${escapeHtml(r.detail)}</p>`
            : '';

        const createdDate = r.createdAt
            ? r.createdAt.substring(0, 16).replace('T', ' ')
            : '-';

        // 회원 상세 링크 (#479)
        const memberLink = r.memberUuid
            ? `<a class="link link-hover" href="/admin/members/${r.memberUuid}">${r.memberUuid.substring(0, 8)}…</a>`
            : '-';

        const choiceSetShort = r.choiceSetUuid
            ? r.choiceSetUuid.substring(0, 8) + '…'
            : null;
        const choiceSetSection = r.choiceSetUuid
            ? `<div class="mt-2">
                           <button
                               class="text-xs text-primary underline underline-offset-2"
                               onclick="toggleChoiceSet(this, '${r.choiceSetUuid}')">
                               선택지 세트 보기 (${choiceSetShort})
                           </button>
                           <div class="choice-set-panel hidden mt-2"></div>
                       </div>`
            : '';

        return `<div class="py-3">
                    <div class="flex items-center justify-between gap-2 mb-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            ${statusBadge}
                            ${categories}
                        </div>
                        <span class="flex items-center gap-1 shrink-0">${dismissButton}<span class="text-xs text-base-content/40">${createdDate}</span></span>
                    </div>
                    ${detail}
                    <div class="text-xs text-base-content/40 mt-1">회원: ${memberLink}</div>
                    ${choiceSetSection}
                </div>`;
    }).join('');

    lucide.createIcons();
}

function setupResolvePanel(reports) {
    pendingReportUuids = (reports || [])
        .filter(r => r.status === 'PENDING')
        .map(r => r.reportUuid);

    const panel = document.getElementById('resolvePanel');
    if (pendingReportUuids.length > 0) {
        panel.classList.remove('hidden');
        document.getElementById('resolveAllBtn').textContent =
            `미처리 전체 처리완료 (${pendingReportUuids.length}건)`;

        // 버튼 텍스트에 아이콘 복원
        document.getElementById('resolveAllBtn').innerHTML =
            `<i data-lucide="check-check" class="size-4"></i> 미처리 전체 처리완료 (${pendingReportUuids.length}건)`;
        lucide.createIcons();
    }
}

document.getElementById('resolveAllBtn').addEventListener('click', async () => {
    if (pendingReportUuids.length === 0) return;

    const correctionScope = document.querySelector('input[name="correctionScope"]:checked').value;
    const deactivateQuestion = document.getElementById('deactivateQuestion').checked;

    const resultEl = document.getElementById('resolveResult');

    resultEl.textContent = '처리 중...';
    resultEl.className = 'text-sm ml-2 text-base-content/60';

    let successCount = 0;
    let failCount = 0;
    let lastErrorMessage = '';

    for (const reportUuid of pendingReportUuids) {
        try {
            // 처리자는 서버가 관리자 세션에서 읽음
            await AdminApi.post(`/admin/api/reports/${reportUuid}/resolve`, {
                correctionScope: correctionScope,
                deactivateQuestion: deactivateQuestion
            });
            successCount++;
        } catch (error) {
            failCount++;
            lastErrorMessage = error.message;
        }
    }

    if (failCount === 0) {
        resultEl.textContent = `${successCount}건 처리완료`;
        resultEl.className = 'text-sm ml-2 text-success';
        AdminUi.toast(`${successCount}건 처리완료`);
    } else {
        resultEl.textContent = `성공 ${successCount}건 / 실패 ${failCount}건`;
        resultEl.className = 'text-sm ml-2 text-warning';
        AdminUi.toast(`실패 ${failCount}건: ${lastErrorMessage}`, 'error');
    }

    // 완료 후 새로고침
    setTimeout(() => loadDetail(), 800);
});

// 선택지 세트 토글 — 처음 열 때 API 호출 후 캐시, 이후 토글만
async function toggleChoiceSet(btn, choiceSetUuid) {
    const panel = btn.nextElementSibling;
    const isHidden = panel.classList.contains('hidden');

    if (!isHidden) {
        panel.classList.add('hidden');
        btn.textContent = `선택지 세트 보기 (${choiceSetUuid.substring(0, 8)}…)`;
        return;
    }

    // 이미 로드된 경우 바로 표시
    if (panel.dataset.loaded) {
        panel.classList.remove('hidden');
        btn.textContent = `선택지 세트 접기`;
        return;
    }

    // 최초 로드
    btn.textContent = '불러오는 중...';
    try {
        const items = await AdminApi.get(`/admin/choice-sets/${choiceSetUuid}/items`);
        panel.innerHTML = renderChoiceItems(items);
        panel.dataset.loaded = '1';
        panel.classList.remove('hidden');
        btn.textContent = '선택지 세트 접기';
        lucide.createIcons();
    } catch (e) {
        btn.textContent = `선택지 세트 보기 (${choiceSetUuid.substring(0, 8)}…)`;
        panel.innerHTML = `<p class="text-xs text-error">불러오기 실패</p>`;
        panel.classList.remove('hidden');
    }
}

function renderChoiceItems(items) {
    if (!items || items.length === 0) return '<p class="text-xs text-base-content/40">선택지 없음</p>';
    return `<div class="border border-base-200 rounded-lg overflow-hidden text-sm">
                ${items.map(item => {
                    const correctBadge = item.isCorrect
                        ? '<span class="badge badge-success badge-xs ml-1">정답</span>'
                        : '';
                    return `<div class="px-3 py-2 ${item.isCorrect ? 'bg-success/10' : 'bg-base-100'} border-b border-base-200 last:border-b-0">
                <div class="flex items-center gap-1 font-mono font-bold text-xs mb-1">
                    ${escapeHtml(item.choiceKey)}${correctBadge}
                </div>
                <p class="text-xs text-base-content/80 whitespace-pre-wrap break-words">${escapeHtml(item.body || '')}</p>
            </div>`;
                }).join('')}
            </div>`;
}

function showError(msg) {
    document.getElementById('questionCard').innerHTML = `
                <div class="card-body text-error">${escapeHtml(msg)}</div>`;
}

const escapeHtml = AdminUi.escapeHtml;

// 초기 로드
loadDetail();
