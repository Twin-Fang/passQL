package com.passql.member.repository;

import com.passql.member.constant.AutoNotificationRuleType;
import com.passql.member.entity.AutoNotificationRule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AutoNotificationRuleRepository extends JpaRepository<AutoNotificationRule, UUID> {

    List<AutoNotificationRule> findAllByOrderByRuleTypeAsc();

    Optional<AutoNotificationRule> findByRuleType(AutoNotificationRuleType ruleType);

    /** 지금 시각(시)에 발송할 켜진 규칙 */
    List<AutoNotificationRule> findAllByIsEnabledTrueAndSendHour(Integer sendHour);
}
