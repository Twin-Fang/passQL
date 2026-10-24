package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AdminAccountSort;
import com.passql.meta.constant.AdminRole;
import com.passql.meta.dto.AdminAccountCreateRequest;
import com.passql.meta.dto.AdminAccountUpdateRequest;
import com.passql.meta.dto.AdminAccountView;
import com.passql.meta.entity.AdminAccount;
import com.passql.meta.repository.AdminAccountRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * 관리자 계정: 조회, 기본 계정 동기화, 로그인 성공·실패 기록(5회 실패 15분 잠금), 계정 추가·역할·비밀번호 관리
 * 기본 계정(yml) 은 화면에서 역할·사용 여부·비밀번호 변경 불가 (환경변수로만 관리)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminAccountService {

    // 연속 로그인 실패 허용 횟수 (이 횟수째 실패 시 잠금)
    public static final int MAX_FAILED_LOGIN_COUNT = 5;
    // 잠금 유지 시간 (분)
    public static final int LOGIN_LOCK_MINUTES = 15;
    // 비밀번호 규칙: 10자 이상, 영문·숫자 각 1자 이상
    private static final Pattern PASSWORD_RULE = Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{10,}$");

    private final AdminAccountRepository adminAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final ApplicationEventPublisher eventPublisher;

    public Optional<AdminAccount> findByUsername(String username) {
        return adminAccountRepository.findByUsername(username);
    }

    public List<AdminAccountView> findAllAsView() {
        LocalDateTime now = LocalDateTime.now();
        return adminAccountRepository.findAllByOrderByCreatedAtAsc().stream()
                .map(account -> AdminAccountView.from(account, now))
                .toList();
    }

    /** 계정 UUID > 아이디 (없으면 ADMIN_ACCOUNT_NOT_FOUND) */
    public String getUsername(UUID adminAccountUuid) {
        return adminAccountRepository.findById(adminAccountUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.ADMIN_ACCOUNT_NOT_FOUND))
                .getUsername();
    }

    /** 목록 검색·정렬: 아이디 부분 일치(대소문자 무시) > 정렬 (기본 생성순) */
    public List<AdminAccountView> searchAsView(String usernameKeyword, AdminAccountSort sort) {
        String normalizedKeyword = usernameKeyword == null ? "" : usernameKeyword.trim().toLowerCase();
        return findAllAsView().stream()
                .filter(view -> view.username().toLowerCase().contains(normalizedKeyword))
                .sorted(sort.getComparator())
                .toList();
    }

    /** 기본 계정 동기화: 없으면 생성, 있으면 해시·ADMIN·사용으로 맞춤 (yml 이 원본) */
    @Transactional
    public void syncEnvironmentAccount(String username, String passwordHash) {
        AdminAccount account = adminAccountRepository.findByUsername(username).orElse(null);
        if (account == null) {
            adminAccountRepository.save(AdminAccount.create(username, passwordHash, AdminRole.ADMIN, true));
            log.info("[admin account] environment account seeded : username={}", username);
            return;
        }
        account.setPasswordHash(passwordHash);
        account.setRole(AdminRole.ADMIN);
        account.setIsEnabled(true);
        account.setIsEnvironmentManaged(true);
        log.info("[admin account] environment account synced : username={}", username);
    }

    /** 로그인 성공: 실패 수·잠금 초기화, 마지막 로그인 기록 (기록 실패가 로그인을 막지 않게 예외 삼킴) */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordLoginSuccess(String username, String clientIp) {
        try {
            adminAccountRepository.findByUsername(username)
                    .ifPresent(account -> account.recordLoginSuccess(LocalDateTime.now(), clientIp));
        } catch (Exception e) {
            log.warn("[admin auth] login success record failed : {}", e.getClass().getSimpleName());
        }
    }

    /** 로그인 실패: 없는 아이디는 기록 안 함, 5회째 15분 잠금 > 잠겼으면 true */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public boolean recordLoginFailure(String username) {
        try {
            Optional<AdminAccount> accountOptional = adminAccountRepository.findByUsername(username);
            if (accountOptional.isEmpty()) {
                return false;
            }
            boolean isLocked = accountOptional.get().recordLoginFailure(
                    MAX_FAILED_LOGIN_COUNT, LocalDateTime.now().plusMinutes(LOGIN_LOCK_MINUTES));
            if (isLocked) {
                log.warn("[admin auth] account locked : username={}, minutes={}", username, LOGIN_LOCK_MINUTES);
            }
            return isLocked;
        } catch (Exception e) {
            log.warn("[admin auth] login failure record failed : {}", e.getClass().getSimpleName());
            return false;
        }
    }

    /** 계정 추가: 아이디 중복·비밀번호 규칙 검사 > BCrypt 저장 */
    @Transactional
    public AdminAccount createAccount(AdminAccountCreateRequest request) {
        AdminRole role = AdminRole.fromRequestValue(request.role());
        if (adminAccountRepository.existsByUsername(request.username())) {
            throw new CustomException(ErrorCode.ADMIN_ACCOUNT_DUPLICATE);
        }
        validatePasswordRule(request.password());
        AdminAccount account = adminAccountRepository.save(
                AdminAccount.create(request.username(), passwordEncoder.encode(request.password()), role, false));
        log.info("[admin account] created : username={}, role={}", account.getUsername(), role);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.ADMIN_ACCOUNT, account.getUsername(),
                AdminAuditAction.CREATE, null, AdminAuditEvent.summary("role", role)));
        return account;
    }

    /** 역할·사용 여부 변경 (기본 계정·자기 계정 거부) */
    @Transactional
    public AdminAccount updateAccount(UUID adminAccountUuid, AdminAccountUpdateRequest request, String actingAdminUsername) {
        AdminAccount account = findEditableAccount(adminAccountUuid);
        if (account.getUsername().equals(actingAdminUsername)) {
            throw new CustomException(ErrorCode.ADMIN_ACCOUNT_SELF_CHANGE_FORBIDDEN);
        }
        Map<String, Object> before = AdminAuditEvent.summary("role", account.getRole(), "isEnabled", account.getIsEnabled());
        account.setRole(AdminRole.fromRequestValue(request.role()));
        account.setIsEnabled(request.isEnabled());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.ADMIN_ACCOUNT, account.getUsername(),
                AdminAuditAction.UPDATE, before, AdminAuditEvent.summary("role", account.getRole(), "isEnabled", account.getIsEnabled())));
        log.info("[admin account] updated : username={}, role={}, enabled={}",
                account.getUsername(), account.getRole(), account.getIsEnabled());
        return account;
    }

    /** 비밀번호 재설정 (기본 계정 거부) + 잠금 해제 */
    @Transactional
    public AdminAccount resetPassword(UUID adminAccountUuid, String newPassword) {
        AdminAccount account = findEditableAccount(adminAccountUuid);
        validatePasswordRule(newPassword);
        account.setPasswordHash(passwordEncoder.encode(newPassword));
        account.unlock();
        log.info("[admin account] password reset : username={}", account.getUsername());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.ADMIN_ACCOUNT, account.getUsername(), AdminAuditAction.PASSWORD_RESET));
        return account;
    }

    /** 로그인 잠금 해제 (기본 계정 포함) */
    @Transactional
    public AdminAccount unlockAccount(UUID adminAccountUuid) {
        AdminAccount account = adminAccountRepository.findById(adminAccountUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.ADMIN_ACCOUNT_NOT_FOUND));
        account.unlock();
        log.info("[admin account] unlocked : username={}", account.getUsername());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.ADMIN_ACCOUNT, account.getUsername(), AdminAuditAction.UNLOCK));
        return account;
    }

    /**
     * 계정 삭제: 기본 계정·자기 계정·사용 중인 계정·마지막 ADMIN 거부 > 삭제
     * 사용 중지 먼저(비활성 우선 정책), 감사 로그는 아이디 문자열로 남아 삭제 뒤에도 조회 가능
     */
    @Transactional
    public void deleteAccount(UUID adminAccountUuid, String actingAdminUsername) {
        AdminAccount account = findEditableAccount(adminAccountUuid);
        if (account.getUsername().equals(actingAdminUsername)) {
            throw new CustomException(ErrorCode.ADMIN_ACCOUNT_SELF_DELETE_FORBIDDEN);
        }
        if (Boolean.TRUE.equals(account.getIsEnabled())) {
            throw new CustomException(ErrorCode.ADMIN_ACCOUNT_DELETE_REQUIRES_DISABLED);
        }
        if (account.getRole() == AdminRole.ADMIN && adminAccountRepository.countByRole(AdminRole.ADMIN) <= 1) {
            throw new CustomException(ErrorCode.ADMIN_ACCOUNT_LAST_ADMIN_FORBIDDEN);
        }
        adminAccountRepository.delete(account);
        log.info("[admin account] deleted : username={}, role={}, by={}", account.getUsername(), account.getRole(), actingAdminUsername);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.ADMIN_ACCOUNT, account.getUsername(),
                AdminAuditAction.DELETE, AdminAuditEvent.summary("role", account.getRole()), null));
    }

    private AdminAccount findEditableAccount(UUID adminAccountUuid) {
        AdminAccount account = adminAccountRepository.findById(adminAccountUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.ADMIN_ACCOUNT_NOT_FOUND));
        if (Boolean.TRUE.equals(account.getIsEnvironmentManaged())) {
            throw new CustomException(ErrorCode.ADMIN_ACCOUNT_ENVIRONMENT_MANAGED);
        }
        return account;
    }

    private void validatePasswordRule(String password) {
        if (password == null || !PASSWORD_RULE.matcher(password).matches()) {
            throw new CustomException(ErrorCode.ADMIN_PASSWORD_TOO_WEAK);
        }
    }
}
