package com.passql.meta.repository;

import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.entity.Feedback;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface FeedbackRepository extends JpaRepository<Feedback, UUID>, JpaSpecificationExecutor<Feedback> {

    Page<Feedback> findAllByOrderByCreatedAtDesc(Pageable pageable);

    Page<Feedback> findByStatusOrderByCreatedAtDesc(FeedbackStatus status, Pageable pageable);

    long countByStatus(FeedbackStatus status);

    @Query("SELECT f.status, COUNT(f) FROM Feedback f GROUP BY f.status")
    List<Object[]> countGroupByStatus();
}
