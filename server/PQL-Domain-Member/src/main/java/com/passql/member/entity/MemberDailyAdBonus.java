package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 무료 한도 광고 보너스 기록 (#808): 시청 1회당 1행
 * 회원·날짜(KST)·칸(1·2) unique > 동시 요청에도 하루 칸 수를 넘지 않음
 */
@Entity
@Table(
    name = "member_daily_ad_bonus",
    uniqueConstraints = @UniqueConstraint(
        name = "uk_member_daily_ad_bonus_member_date_slot",
        columnNames = {"member_uuid", "bonus_date", "slot"})
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberDailyAdBonus extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID memberDailyAdBonusUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    // 보너스를 받은 날 (KST)
    @Column(nullable = false)
    private LocalDate bonusDate;

    // 그날 몇 번째 광고 보너스인지 (1부터)
    @Column(nullable = false)
    private int slot;

    @Column(nullable = false)
    private LocalDateTime grantedAt;

    /** 광고 보너스 1회 기록 */
    public static MemberDailyAdBonus of(UUID memberUuid, LocalDate bonusDate, int slot, LocalDateTime grantedAt) {
        MemberDailyAdBonus adBonus = new MemberDailyAdBonus();
        adBonus.memberUuid = memberUuid;
        adBonus.bonusDate = bonusDate;
        adBonus.slot = slot;
        adBonus.grantedAt = grantedAt;
        return adBonus;
    }
}
