/**
 * 회원 상세 화면: 탭 전환, 관리자 메모 저장, 제재 해제, 관리자 탈퇴 처리
 * 제재 적용·푸시 창은 member-moderation.js 공용
 * memberUuid, activeTab 은 members/detail.html 인라인 스크립트가 선언
 */

const DETAIL_TABS = ['submission', 'suspend', 'notification', 'purchase', 'community'];

// 탭 전환
function switchTab(tab) {
    DETAIL_TABS.forEach(t => {
        document.getElementById('panel-' + t).classList.toggle('hidden', t !== tab);
        document.getElementById('tab-' + t).classList.toggle('tab-active', t === tab);
        // 제출·알림 탭 페이지 이동 바 (패널 밖에 있어 탭과 함께 토글)
        document.getElementById('pager-' + t)?.classList.toggle('hidden', t !== tab);
    });
}

// 페이지 이동 뒤에도 보던 탭 유지 (?tab=)
if (DETAIL_TABS.includes(activeTab)) switchTab(activeTab);

function saveAdminMemo() {
    const adminMemo = document.getElementById('adminMemo').value;
    AdminApi.put(`/admin/members/${memberUuid}/memo`, { adminMemo })
        .then(() => AdminUi.toast('메모를 저장했습니다.'))
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
