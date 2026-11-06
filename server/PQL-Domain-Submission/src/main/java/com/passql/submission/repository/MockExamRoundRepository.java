package com.passql.submission.repository;

import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.entity.MockExamRound;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MockExamRoundRepository extends JpaRepository<MockExamRound, UUID> {

    List<MockExamRound> findByStatusOrderByRoundNumberAsc(MockExamRoundStatus status);

    List<MockExamRound> findAllByOrderByRoundNumberDesc();

    /** 무료 체험 회차 = 공개 회차 중 번호가 가장 작은 회차 */
    Optional<MockExamRound> findFirstByStatusOrderByRoundNumberAsc(MockExamRoundStatus status);

    /** 자동 구성 겹침 회피: 최근 회차 (초안 제외 상태 목록) */
    List<MockExamRound> findTop3ByStatusInOrderByRoundNumberDesc(Collection<MockExamRoundStatus> statuses);

    boolean existsByRoundNumber(Integer roundNumber);
}
