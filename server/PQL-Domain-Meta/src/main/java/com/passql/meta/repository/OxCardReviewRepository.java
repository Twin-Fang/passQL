package com.passql.meta.repository;

import com.passql.meta.entity.OxCardReview;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OxCardReviewRepository extends JpaRepository<OxCardReview, UUID> {

    List<OxCardReview> findByMemberUuid(UUID memberUuid);

    // 답 저장용 행 잠금 조회 (같은 카드 동시 답이 칸을 서로 덮어쓰지 않게)
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select review from OxCardReview review"
        + " where review.memberUuid = :memberUuid and review.cardKey = :cardKey")
    Optional<OxCardReview> findForUpdate(@Param("memberUuid") UUID memberUuid, @Param("cardKey") String cardKey);

    /** 오늘 푼 카드 수 (같은 카드 여러 번은 1장) */
    long countByMemberUuidAndLastAnsweredAtGreaterThanEqual(UUID memberUuid, LocalDateTime answeredFrom);
}
