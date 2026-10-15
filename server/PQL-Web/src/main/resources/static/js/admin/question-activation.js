/**
 * 문제 비활성화·복구 (목록·상세 공통): 확인 창 > 요청 > 새로고침 토스트
 */
async function deactivateQuestion(uuid) {
    if (!await AdminUi.confirmDanger('문제 목록·추천·오늘의 문제 후보에서 빠집니다.\n회원의 제출·실행·신고 기록은 그대로 보존됩니다.',
        { title: '문제를 비활성화할까요?', confirmLabel: '비활성화' })) return;
    AdminApi.post('/admin/questions/' + uuid + '/deactivate')
        .then(() => AdminUi.reloadWithToast('문제를 비활성화했습니다.'))
        .catch(error => AdminUi.showError(error));
}

async function restoreQuestion(uuid) {
    if (!await AdminUi.confirmDanger('문제를 다시 회원에게 노출하고 추천 색인에 적재합니다.',
        { title: '문제를 복구할까요?', confirmLabel: '복구' })) return;
    AdminApi.post('/admin/questions/' + uuid + '/restore')
        .then(() => AdminUi.reloadWithToast('문제를 복구했습니다.'))
        .catch(error => AdminUi.showError(error));
}
