package com.passql.application.entitlement;

import com.passql.member.entity.MemberDailyAdBonus;
import com.passql.member.repository.MemberDailyAdBonusRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.OptionalInt;
import java.util.UUID;

/**
 * 광고 보너스 기록 (#808): 오늘 다음 빈 칸(1·2) 저장 (보상 표식·거래 ID 함께, #860)
 * unique 충돌(같은 칸·표식·거래 ID 동시 저장) > false (호출부가 다시 확인해 재시도), 바깥 트랜잭션 없이 saveAndFlush 자체 트랜잭션
 */
@Slf4j
@Component
public class DailyAdBonusRecorder {

    private final MemberDailyAdBonusRepository memberDailyAdBonusRepository;
    private final DailyFreeBonusReader dailyFreeBonusReader;
    private final Clock clock;

    @Autowired
    public DailyAdBonusRecorder(MemberDailyAdBonusRepository memberDailyAdBonusRepository,
                                DailyFreeBonusReader dailyFreeBonusReader) {
        this(memberDailyAdBonusRepository, dailyFreeBonusReader, Clock.system(FeatureAccessPolicy.SERVICE_ZONE));
    }

    DailyAdBonusRecorder(MemberDailyAdBonusRepository memberDailyAdBonusRepository,
                         DailyFreeBonusReader dailyFreeBonusReader, Clock clock) {
        this.memberDailyAdBonusRepository = memberDailyAdBonusRepository;
        this.dailyFreeBonusReader = dailyFreeBonusReader;
        this.clock = clock;
    }

    /** 다음 빈 칸에 광고 보너스 저장, 오늘 칸이 없거나 동시 저장에 졌으면 false (표식·거래 ID 는 없으면 null) */
    public boolean saveNextAdBonus(UUID memberUuid, String rewardNonce, String ssvTransactionId) {
        OptionalInt nextSlot = DailyFreeBonusRule.nextAdBonusSlot(dailyFreeBonusReader.countAdBonusUsedToday(memberUuid));
        if (nextSlot.isEmpty()) {
            return false;
        }
        try {
            memberDailyAdBonusRepository.saveAndFlush(MemberDailyAdBonus.of(
                memberUuid, dailyFreeBonusReader.today(), nextSlot.getAsInt(), LocalDateTime.now(clock),
                rewardNonce, ssvTransactionId));
        } catch (DataIntegrityViolationException e) {
            log.info("[pro access] ad bonus slot taken, retrying : member={}, slot={}", memberUuid, nextSlot.getAsInt());
            return false;
        }
        log.info("[pro access] ad bonus granted : member={}, slot={}, isServerVerified={}",
            memberUuid, nextSlot.getAsInt(), ssvTransactionId != null);
        return true;
    }
}
