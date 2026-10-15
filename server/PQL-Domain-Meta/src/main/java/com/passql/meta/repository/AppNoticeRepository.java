package com.passql.meta.repository;

import com.passql.meta.entity.AppNotice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface AppNoticeRepository extends JpaRepository<AppNotice, UUID> {

    /** 관리자 목록: 최근 등록 순 */
    List<AppNotice> findAllByOrderByCreatedAtDesc();

    /** 지금 노출할 공지: 활성 + 기간 안, 중요 먼저 > 최근 등록 순 */
    @Query("""
            SELECT n FROM AppNotice n
            WHERE n.isActive = true
              AND (n.startsAt IS NULL OR n.startsAt <= :now)
              AND (n.endsAt IS NULL OR n.endsAt > :now)
            ORDER BY n.isImportant DESC, n.createdAt DESC
            """)
    List<AppNotice> findVisibleNotices(@Param("now") LocalDateTime now);
}
