package com.passql.submission.repository;

import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.entity.MockExamAttempt;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MockExamAttemptRepository extends JpaRepository<MockExamAttempt, UUID> {

    /** 행 잠금 조회: 답 저장·제출·자동 채점이 겹쳐도 한 번만 채점 (두 기기·스케줄러 동시 요청) */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT a FROM MockExamAttempt a WHERE a.mockExamAttemptUuid = :mockExamAttemptUuid")
    Optional<MockExamAttempt> findByIdForUpdate(@Param("mockExamAttemptUuid") UUID mockExamAttemptUuid);

    Optional<MockExamAttempt> findFirstByMemberUuidAndStatusOrderByStartedAtDesc(UUID memberUuid, MockExamAttemptStatus status);

    List<MockExamAttempt> findByMemberUuidAndStatus(UUID memberUuid, MockExamAttemptStatus status);

    List<MockExamAttempt> findByMemberUuidOrderByStartedAtAsc(UUID memberUuid);

    List<MockExamAttempt> findByMemberUuidAndStatusOrderBySubmittedAtAsc(UUID memberUuid, MockExamAttemptStatus status);

    /** 무료 체험 소진 판정: 응시 기록이 하나라도 있는지 (회차·제출 여부 무관) */
    boolean existsByMemberUuid(UUID memberUuid);

    long countByMockExamRoundUuid(UUID mockExamRoundUuid);

    List<MockExamAttempt> findByMockExamRoundUuidAndStatus(UUID mockExamRoundUuid, MockExamAttemptStatus status);

    /** 마감이 지난 풀이 중 응시 (자동 채점 대상) */
    List<MockExamAttempt> findTop100ByStatusAndDeadlineAtBeforeOrderByDeadlineAtAsc(MockExamAttemptStatus status,
                                                                                  LocalDateTime deadlineBefore);

    /** 관리자 응시 기록: 회차·회원 필터 (null 이면 전체), 시작 최신순 */
    @Query("""
            SELECT a FROM MockExamAttempt a
            WHERE (:mockExamRoundUuid IS NULL OR a.mockExamRoundUuid = :mockExamRoundUuid)
              AND (:memberUuid IS NULL OR a.memberUuid = :memberUuid)
            ORDER BY a.startedAt DESC
            """)
    Page<MockExamAttempt> searchForAdmin(@Param("mockExamRoundUuid") UUID mockExamRoundUuid,
                                         @Param("memberUuid") UUID memberUuid,
                                         Pageable pageable);
}
