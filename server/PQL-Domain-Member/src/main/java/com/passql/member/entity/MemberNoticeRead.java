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
 * 회원이 읽은 공지 (공지는 회원별로 복사하지 않고 읽음만 기록)
 * 복합 PK (member_uuid, app_notice_uuid)
 */
@Entity
@Table(
    name = "member_notice_read",
    indexes = @Index(name = "idx_member_notice_read_notice", columnList = "app_notice_uuid")
)
@IdClass(MemberNoticeRead.Key.class)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberNoticeRead {

    @Id
    @Column(nullable = false)
    private UUID memberUuid;

    @Id
    @Column(nullable = false)
    private UUID appNoticeUuid;

    @Column(nullable = false)
    private LocalDateTime readAt;

    public static MemberNoticeRead of(UUID memberUuid, UUID appNoticeUuid) {
        MemberNoticeRead noticeRead = new MemberNoticeRead();
        noticeRead.memberUuid = memberUuid;
        noticeRead.appNoticeUuid = appNoticeUuid;
        noticeRead.readAt = LocalDateTime.now();
        return noticeRead;
    }

    /** 복합 PK 클래스 */
    @NoArgsConstructor
    @EqualsAndHashCode
    public static class Key implements Serializable {
        private UUID memberUuid;
        private UUID appNoticeUuid;
    }
}
