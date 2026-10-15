/**
 * 회원 상세 화면: 탭 전환, 제재 적용·해제, 관리자 탈퇴 처리
 * memberUuid 는 members/detail.html 인라인 스크립트가 선언
 */

// 탭 전환
function switchTab(tab) {
    ['submission', 'suspend'].forEach(t => {
        document.getElementById('panel-' + t).classList.toggle('hidden', t !== tab);
        document.getElementById('tab-' + t).classList.toggle('tab-active', t === tab);
    });
}

function suspendMember() {
    const reason = document.getElementById('suspendReason').value;
    const suspendUntil = document.getElementById('suspendUntil').value;
    if (!suspendUntil) {
        AdminUi.toast('제재 만료 일시를 입력해주세요.', 'warning');
        return;
    }
    AdminApi.post(`/admin/members/${memberUuid}/suspend`, { reason, suspendUntil: suspendUntil + ':00' })
        .then(() => AdminUi.reloadWithToast('제재를 적용했습니다.'))
        .catch(error => AdminUi.showError(error));
}

async function unsuspendMember() {
    if (!await AdminUi.confirmDanger('제재를 해제합니다. 회원이 바로 앱을 다시 쓸 수 있습니다.', { confirmLabel: '해제' })) return;
    AdminApi.post(`/admin/members/${memberUuid}/unsuspend`)
        .then(() => AdminUi.reloadWithToast('제재를 해제했습니다.'))
        .catch(error => AdminUi.showError(error));
}

async function withdrawMember() {
    if (!await AdminUi.confirmDanger('닉네임·이메일·소셜 식별자를 익명화하고 로그인을 막습니다.\n풀이 기록은 통계용으로 남고, 되돌릴 수 없습니다.',
        { title: '회원을 탈퇴 처리할까요?', confirmLabel: '탈퇴 처리' })) return;
    AdminApi.post(`/admin/members/${memberUuid}/withdraw`)
        .then(() => AdminUi.navigateWithToast('/admin/members', '탈퇴 처리했습니다.'))
        .catch(error => AdminUi.showError(error));
}
