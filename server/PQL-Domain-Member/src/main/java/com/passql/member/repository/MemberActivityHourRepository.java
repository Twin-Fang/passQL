package com.passql.member.repository;

import com.passql.member.entity.MemberActivityHour;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.UUID;

/** 회원 시간대별 활동 (#557) */
public interface MemberActivityHourRepository extends JpaRepository<MemberActivityHour, MemberActivityHour.Key> {

    /** 활동 기록 (같은 시간·회원이 이미 있으면 무시, 동시 요청에도 안전) */
    @Modifying
    @Query(value = """
            INSERT INTO member_activity_hour (activity_hour, member_uuid)
            VALUES (:activityHour, :memberUuid)
            ON CONFLICT (activity_hour, member_uuid) DO NOTHING
            """, nativeQuery = true)
    int insertIfAbsent(@Param("activityHour") LocalDateTime activityHour, @Param("memberUuid") UUID memberUuid);

    /** 보관 기간 지난 활동 삭제 */
    @Modifying
    @Query("DELETE FROM MemberActivityHour a WHERE a.activityHour < :cutoff")
    int deleteOlderThan(@Param("cutoff") LocalDateTime cutoff);
}
