package com.passql.meta.repository;

import com.passql.meta.entity.AppNotice;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
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

    /**
     * 게시된 공지 목록 (지난 공지 포함): 활성 + 노출 시작 지남
     * 정렬: 노출 중 중요 공지 먼저 > 게시 시각(노출 시작, 없으면 등록) 최신 > uuid (페이지 경계 고정)
     */
    @Query(value = """
            SELECT n FROM AppNotice n
            WHERE n.isActive = true
              AND (n.startsAt IS NULL OR n.startsAt <= :now)
            ORDER BY CASE WHEN n.isImportant = true AND (n.endsAt IS NULL OR n.endsAt > :now) THEN 0 ELSE 1 END,
                     COALESCE(n.startsAt, n.createdAt) DESC,
                     n.appNoticeUuid
            """,
            countQuery = """
            SELECT COUNT(n) FROM AppNotice n
            WHERE n.isActive = true
              AND (n.startsAt IS NULL OR n.startsAt <= :now)
            """)
    Page<AppNotice> findPublishedNotices(@Param("now") LocalDateTime now, Pageable pageable);

    /** 게시된 공지 1건 (지난 공지 포함, 비활성·노출 전이면 빈 값) */
    @Query("""
            SELECT n FROM AppNotice n
            WHERE n.appNoticeUuid = :noticeUuid
              AND n.isActive = true
              AND (n.startsAt IS NULL OR n.startsAt <= :now)
            """)
    Optional<AppNotice> findPublishedNotice(@Param("noticeUuid") UUID noticeUuid, @Param("now") LocalDateTime now);
}
