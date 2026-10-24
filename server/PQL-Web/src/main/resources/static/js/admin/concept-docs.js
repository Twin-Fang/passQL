/**
 * 개념 문서 화면: 문서 저장·삭제, 마크다운 미리보기 전환, 태그 검색·순서 저장
 */

async function deleteDoc(dataset) {
    if (!await AdminUi.confirmDanger('"' + (dataset.title || '제목 없음') + '" 개념 문서를 삭제합니다. 되돌릴 수 없습니다.', { confirmLabel: '삭제' })) return;
    AdminApi.delete('/admin/concepts/' + dataset.uuid)
        .then(() => AdminUi.reloadWithToast('개념 문서를 삭제했습니다.'))
        .catch(error => AdminUi.showError(error));
}

function saveDoc(docId) {
    const body = document.getElementById('docBody_' + docId).value;
    AdminApi.put('/admin/concepts/' + docId, { bodyMd: body })
        .then(() => AdminUi.toast('개념 문서를 저장했습니다.'))
        .catch(error => AdminUi.showError(error));
}

/** 본문 입력 <-> 마크다운 미리보기 전환 (렌더 결과는 DOMPurify 로 정화) */
function toggleMarkdownPreview(bodyId, previewId, toggleButton) {
    const bodyTextarea = document.getElementById(bodyId);
    const previewElement = document.getElementById(previewId);
    const isShowingPreview = !previewElement.classList.contains('hidden');
    const buttonLabel = toggleButton.querySelector('span');
    if (isShowingPreview) {
        previewElement.classList.add('hidden');
        bodyTextarea.classList.remove('hidden');
        buttonLabel.textContent = '미리보기';
        return;
    }
    if (typeof marked === 'undefined' || typeof DOMPurify === 'undefined') {
        AdminUi.toast('미리보기 라이브러리를 불러오지 못했습니다. 네트워크를 확인해 주세요.', 'error');
        return;
    }
    previewElement.innerHTML = DOMPurify.sanitize(marked.parse(bodyTextarea.value));
    bodyTextarea.classList.add('hidden');
    previewElement.classList.remove('hidden');
    buttonLabel.textContent = '편집';
}

/** 태그 검색: 입력어가 이름·키에 포함된 태그만 표시 (화면 안에서만 거름) */
function filterConceptTags(query) {
    const lowerQuery = query.trim().toLowerCase();
    document.querySelectorAll('#conceptTagList .concept-tag-row').forEach(row => {
        row.classList.toggle('hidden', lowerQuery !== '' && !row.dataset.searchText.includes(lowerQuery));
    });
}

/** 태그 순서 저장 (활성 태그 전체 tagKey 를 새 순서로) */
function saveConceptTagOrder(orderedCodes) {
    AdminApi.post('/admin/concepts/tags/order', { orderedCodes })
        .then(() => AdminUi.reloadWithToast('개념 태그 순서를 바꿨습니다.'))
        .catch(error => AdminUi.showError(error));
}
