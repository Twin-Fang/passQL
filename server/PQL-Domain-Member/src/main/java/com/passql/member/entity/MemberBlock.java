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

import java.util.UUID;

/**
 * 회원 차단 1건 (#525): 차단한 회원 > 차단당한 회원, 차단한 쪽 화면에서만 상대 의견을 숨김
 * 앱에는 차단당한 회원 UUID 를 주지 않고 memberBlockUuid 로 해제
 */
@Entity
@Table(
    name = "member_block",
    uniqueConstraints = @UniqueConstraint(name = "uk_member_block_pair", columnNames = {"blocker_member_uuid", "blocked_member_uuid"})
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberBlock extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID memberBlockUuid;

    @Column(nullable = false)
    private UUID blockerMemberUuid;

    @Column(nullable = false)
    private UUID blockedMemberUuid;

    public static MemberBlock of(UUID blockerMemberUuid, UUID blockedMemberUuid) {
        MemberBlock block = new MemberBlock();
        block.blockerMemberUuid = blockerMemberUuid;
        block.blockedMemberUuid = blockedMemberUuid;
        return block;
    }
}
