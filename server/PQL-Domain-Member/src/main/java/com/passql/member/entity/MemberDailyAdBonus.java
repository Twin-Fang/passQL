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
 * unique 3개: 회원·날짜(KST)·칸(1부터, 횟수 제한 없음) 같은 칸 동시 저장, 보상 표식·AdMob 거래 ID 같은 광고 중복 기록 (#860)
 */
@Entity
@Table(
    name = "member_daily_ad_bonus",
    uniqueConstraints = {
        @UniqueConstraint(
            name = "uk_member_daily_ad_bonus_member_date_slot",
            columnNames = {"member_uuid", "bonus_date", "slot"}),
        @UniqueConstraint(name = "uk_member_daily_ad_bonus_reward_nonce", columnNames = {"reward_nonce"}),
        @UniqueConstraint(name = "uk_member_daily_ad_bonus_ssv_transaction_id", columnNames = {"ssv_transaction_id"})
    }
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

    // 앱이 광고마다 만든 보상 표식 (AdMob custom_data 와 같은 값, 옛 앱 신고는 null)
    @Column(length = 64)
    private String rewardNonce;

    // AdMob 서버 검증 콜백 거래 ID (앱 신고로 기록했으면 null)
    @Column(length = 128)
    private String ssvTransactionId;

    /** 광고 보너스 1회 기록 (보상 표식·거래 ID 는 없으면 null) */
    public static MemberDailyAdBonus of(UUID memberUuid, LocalDate bonusDate, int slot, LocalDateTime grantedAt,
                                        String rewardNonce, String ssvTransactionId) {
        MemberDailyAdBonus adBonus = new MemberDailyAdBonus();
        adBonus.memberUuid = memberUuid;
        adBonus.bonusDate = bonusDate;
        adBonus.slot = slot;
        adBonus.grantedAt = grantedAt;
        adBonus.rewardNonce = rewardNonce;
        adBonus.ssvTransactionId = ssvTransactionId;
        return adBonus;
    }
}
