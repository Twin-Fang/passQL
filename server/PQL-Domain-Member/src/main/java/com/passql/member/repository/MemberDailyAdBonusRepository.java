package com.passql.member.repository;

import com.passql.member.entity.MemberDailyAdBonus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.UUID;

/** 무료 한도 광고 보너스 기록 */
public interface MemberDailyAdBonusRepository extends JpaRepository<MemberDailyAdBonus, UUID> {

    /** 그날 받은 광고 보너스 횟수 */
    int countByMemberUuidAndBonusDate(UUID memberUuid, LocalDate bonusDate);
}
