/**
 * 관리자 계정 화면: 추가, 역할 저장, 사용 중지·재개, 비밀번호 재설정, 잠금 해제
 */
let passwordResetTargetUuid = null;

function createAccount() {
    const body = {
        username: document.getElementById('newUsername').value.trim(),
        password: document.getElementById('newPassword').value,
        role: document.getElementById('newRole').value
    };
    AdminApi.post('/admin/accounts', body)
        .then(() => AdminUi.reloadWithToast('관리자 계정을 추가했습니다.'))
        .catch(error => AdminUi.showError(error));
}

function saveAccount(dataset) {
    const role = document.getElementById('role-' + dataset.uuid).value;
    AdminApi.put('/admin/accounts/' + dataset.uuid, { role, isEnabled: dataset.enabled === 'true' })
        .then(() => AdminUi.reloadWithToast('역할을 저장했습니다.'))
        .catch(error => AdminUi.showError(error));
}

async function toggleEnabled(dataset) {
    const isEnabledNow = dataset.enabled === 'true';
    if (isEnabledNow && !await AdminUi.confirmDanger(dataset.username + ' 계정의 로그인을 막습니다.', { confirmLabel: '사용 중지' })) return;
    const role = document.getElementById('role-' + dataset.uuid).value;
    AdminApi.put('/admin/accounts/' + dataset.uuid, { role, isEnabled: !isEnabledNow })
        .then(() => AdminUi.reloadWithToast(isEnabledNow ? '사용을 중지했습니다.' : '사용을 재개했습니다.'))
        .catch(error => AdminUi.showError(error));
}

function resetPassword(dataset) {
    passwordResetTargetUuid = dataset.uuid;
    document.getElementById('passwordTargetName').textContent = dataset.username;
    document.getElementById('resetPassword').value = '';
    document.getElementById('passwordModal').showModal();
}

function submitPasswordReset() {
    const password = document.getElementById('resetPassword').value;
    AdminApi.post('/admin/accounts/' + passwordResetTargetUuid + '/password', { password })
        .then(() => {
            document.getElementById('passwordModal').close();
            AdminUi.reloadWithToast('비밀번호를 재설정했습니다.');
        })
        .catch(error => AdminUi.showError(error));
}

function unlockAccount(dataset) {
    AdminApi.post('/admin/accounts/' + dataset.uuid + '/unlock')
        .then(() => AdminUi.reloadWithToast(dataset.username + ' 잠금을 해제했습니다.'))
        .catch(error => AdminUi.showError(error));
}
