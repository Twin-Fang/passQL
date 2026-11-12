package com.passql.member.repository;

import com.passql.member.entity.MemberDailyAdBonus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/** 무료 한도 광고 보너스 기록 */
public interface MemberDailyAdBonusRepository extends JpaRepository<MemberDailyAdBonus, UUID> {

    /** 그날 받은 광고 보너스 횟수 */
    int countByMemberUuidAndBonusDate(UUID memberUuid, LocalDate bonusDate);

    /** 기간 [fromDate, toDate] 날짜별 받은 광고 보너스 횟수 (받은 날만, GROUP BY 1회) */
    @Query("select b.bonusDate as bonusDate, count(b) as adBonusCount from MemberDailyAdBonus b "
            + "where b.memberUuid = :memberUuid and b.bonusDate >= :fromDate and b.bonusDate <= :toDate "
            + "group by b.bonusDate")
    List<DailyAdBonusCountProjection> countGroupedByBonusDate(@Param("memberUuid") UUID memberUuid,
                                                              @Param("fromDate") LocalDate fromDate,
                                                              @Param("toDate") LocalDate toDate);

    /** 이 회원이 이 보상 표식으로 이미 받았는지 (앱 신고·서버 검증 콜백 중복 방지) */
    boolean existsByMemberUuidAndRewardNonce(UUID memberUuid, String rewardNonce);

    /** 이 AdMob 거래 ID 로 이미 기록했는지 (콜백 재전송·재사용 방지) */
    boolean existsBySsvTransactionId(String ssvTransactionId);
}
