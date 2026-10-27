/**
 * 개념 학습 관리 화면: 묶음 파일 읽기·검증·가져오기, 공개 상태 변경·일괄 공개, 본문 저장, 미리보기 마크다운 렌더
 */

/** 파일 > 묶음 입력칸 */
function loadConceptBundleFile(input) {
    const file = input.files && input.files[0];
    if (!file) return;
    file.text().then(text => { document.getElementById('conceptBundleText').value = text; });
}

/** 묶음 입력칸 > JSON (형식 오류면 null + 안내) */
function readConceptBundle() {
    try {
        return JSON.parse(document.getElementById('conceptBundleText').value);
    } catch (error) {
        AdminUi.toast('JSON 형식이 올바르지 않습니다: ' + error.message, 'error');
        return null;
    }
}

/** 검증 결과 표시 (문제 목록은 tagKey · 칸 · 사유) */
function showConceptBundleIssues(result) {
    const resultElement = document.getElementById('conceptBundleResult');
    if (result.isValid) {
        resultElement.innerHTML = '<p class="text-success">검증 통과: 가져오기를 눌러 저장하세요.</p>';
        return;
    }
    const rows = result.issues.map(issue => '<li><span class="font-mono">' + AdminUi.escapeHtml(issue.tagKey || '-')
        + '</span> · ' + AdminUi.escapeHtml(issue.field) + ' · ' + AdminUi.escapeHtml(issue.reason) + '</li>').join('');
    resultElement.innerHTML = '<p class="text-error">문제 ' + result.issues.length + '건</p><ul class="list-disc pl-5">' + rows + '</ul>';
}

function validateConceptBundle() {
    const bundle = readConceptBundle();
    if (!bundle) return;
    AdminApi.post('/admin/concepts/learning/import/validate', bundle)
        .then(showConceptBundleIssues)
        .catch(error => AdminUi.showError(error));
}

function importConceptBundle() {
    const bundle = readConceptBundle();
    if (!bundle) return;
    AdminApi.post('/admin/concepts/learning/import', bundle)
        .then(result => AdminUi.reloadWithToast('새 개념 ' + result.createdCount + '개, 갱신 ' + result.updatedCount + '개를 저장했습니다.'))
        .catch(error => AdminUi.showError(error));
}

function changeConceptStatus(conceptUuid, status) {
    AdminApi.put('/admin/concepts/learning/' + conceptUuid + '/status', { status })
        .then(() => AdminUi.reloadWithToast(status === 'PUBLISHED' ? '개념을 공개했습니다.' : '개념을 초안으로 돌렸습니다.'))
        .catch(error => AdminUi.showError(error));
}

async function publishAllConcepts() {
    if (!await AdminUi.confirmDanger('확인 문제 5개를 갖춘 초안을 모두 공개합니다.', { confirmLabel: '공개' })) return;
    AdminApi.post('/admin/concepts/learning/publish-all', {})
        .then(result => AdminUi.reloadWithToast('개념 ' + result.publishedCount + '개를 공개했습니다.'))
        .catch(error => AdminUi.showError(error));
}

function saveConceptContent() {
    const editor = document.getElementById('conceptContentEditor');
    AdminApi.put('/admin/concepts/learning/' + editor.dataset.uuid + '/content', {
        title: document.getElementById('conceptTitle').value,
        summary: document.getElementById('conceptSummary').value,
        coreMd: document.getElementById('conceptCoreMd').value,
        detailMd: document.getElementById('conceptDetailMd').value
    })
        .then(() => AdminUi.reloadWithToast('본문을 저장했습니다.'))
        .catch(error => AdminUi.showError(error));
}

/** 미리보기 마크다운 렌더 (data-markdown 원문 > DOMPurify 로 정화한 HTML) */
function renderConceptMarkdown() {
    if (typeof marked === 'undefined' || typeof DOMPurify === 'undefined') return;
    document.querySelectorAll('[data-markdown]').forEach(element => {
        element.innerHTML = DOMPurify.sanitize(marked.parse(element.textContent || ''));
    });
}
