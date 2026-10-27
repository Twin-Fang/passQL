package com.passql.meta.repository;

import com.passql.meta.entity.FeedbackImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FeedbackImageRepository extends JpaRepository<FeedbackImage, UUID> {

    List<FeedbackImage> findByFeedbackUuidOrderBySortOrderAsc(UUID feedbackUuid);

    Optional<FeedbackImage> findByFeedbackUuidAndSortOrder(UUID feedbackUuid, int sortOrder);

    // 관리자 목록용 의견별 이미지 개수: [feedbackUuid, count]
    @Query("SELECT i.feedbackUuid, COUNT(i) FROM FeedbackImage i WHERE i.feedbackUuid IN :feedbackUuids GROUP BY i.feedbackUuid")
    List<Object[]> countByFeedbackUuids(Collection<UUID> feedbackUuids);
}
