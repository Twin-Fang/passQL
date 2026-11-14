package com.passql.submission.repository;

import com.passql.meta.constant.CertType;
import com.passql.submission.entity.ExamAnswerRound;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExamAnswerRoundRepository extends JpaRepository<ExamAnswerRound, UUID> {

    Optional<ExamAnswerRound> findByCertTypeAndRoundNumber(CertType certType, Integer roundNumber);

    boolean existsByCertTypeAndRoundNumber(CertType certType, Integer roundNumber);

    List<ExamAnswerRound> findAllByOrderByExamDateDescRoundNumberDesc();
}
