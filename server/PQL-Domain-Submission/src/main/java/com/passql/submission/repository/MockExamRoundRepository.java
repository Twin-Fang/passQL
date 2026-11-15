package com.passql.submission.repository;

import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.constant.MockExamRoundType;
import com.passql.submission.entity.MockExamRound;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface MockExamRoundRepository extends JpaRepository<MockExamRound, UUID> {

    List<MockExamRound> findByStatusOrderByRoundNumberAsc(MockExamRoundStatus status);

    List<MockExamRound> findAllByOrderByRoundNumberDesc();

    /** 자동 구성 겹침 회피: 같은 종류 최근 회차 (초안 제외 상태 목록) */
    List<MockExamRound> findTop3ByRoundTypeAndStatusInOrderByRoundNumberDesc(MockExamRoundType roundType,
                                                                           Collection<MockExamRoundStatus> statuses);

    /** 회차 번호 중복 (종류별 유일) */
    boolean existsByRoundTypeAndRoundNumber(MockExamRoundType roundType, Integer roundNumber);
}
