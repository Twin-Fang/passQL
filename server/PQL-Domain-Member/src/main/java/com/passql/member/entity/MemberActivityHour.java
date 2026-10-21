package com.passql.member.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 회원 시간대별 활동 (시간당 회원 1행, 방문자·시간대 집계용, 400일 보관, #557)
 * 복합 PK (activity_hour, member_uuid), 쓰기는 MemberActivityHourRepository.insertIfAbsent 만
 */
@Entity
@Table(
    name = "member_activity_hour",
    indexes = @Index(name = "idx_member_activity_hour_member", columnList = "member_uuid")
)
@IdClass(MemberActivityHour.Key.class)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberActivityHour {

    // 활동 시각을 시 단위로 자른 값 (서버 로컬 시간, 예: 2026-10-20T14:00)
    @Id
    @Column(nullable = false)
    private LocalDateTime activityHour;

    @Id
    @Column(nullable = false)
    private UUID memberUuid;

    /** 복합 PK 클래스 */
    @NoArgsConstructor
    @EqualsAndHashCode
    public static class Key implements Serializable {
        private LocalDateTime activityHour;
        private UUID memberUuid;
    }
}
