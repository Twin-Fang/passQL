package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.MemberPlan;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 회원 등급: 회원 1명당 1행, 프로는 expiresAt 까지
 * PK = member.member_uuid (회원과 1:1 이라 별도 생성 UUID 없음)
 */
@Entity
@Table(name = "member_entitlement")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberEntitlement extends BaseEntity {

    @Id
    @Column(updatable = false, nullable = false)
    private UUID memberUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private MemberPlan plan;

    // 프로 만료 시각 (FREE 면 null)
    private LocalDateTime expiresAt;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private EntitlementSource source;

    public static MemberEntitlement of(UUID memberUuid, MemberPlan plan, LocalDateTime expiresAt,
                                       EntitlementSource source) {
        MemberEntitlement entitlement = new MemberEntitlement();
        entitlement.memberUuid = memberUuid;
        entitlement.plan = plan;
        entitlement.expiresAt = expiresAt;
        entitlement.source = source;
        return entitlement;
    }

    /** 프로 만료일 연장 (등급은 PRO 로 유지) */
    public void extendTo(LocalDateTime newExpiresAt, EntitlementSource source) {
        this.plan = MemberPlan.PRO;
        this.expiresAt = newExpiresAt;
        this.source = source;
    }

    /** 등급 회수: FREE, 만료일 없음 (환불 등) */
    public void revoke() {
        this.plan = MemberPlan.FREE;
        this.expiresAt = null;
    }
}
