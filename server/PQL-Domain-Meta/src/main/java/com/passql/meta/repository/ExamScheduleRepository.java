package com.passql.meta.repository;

import com.passql.meta.constant.CertType;
import com.passql.meta.entity.ExamSchedule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExamScheduleRepository extends JpaRepository<ExamSchedule, UUID> {
    List<ExamSchedule> findAllByOrderByCertTypeAscRoundAsc();
    List<ExamSchedule> findByCertTypeOrderByRoundAsc(CertType certType);
    Optional<ExamSchedule> findFirstByIsSelectedTrue();

    /** 기준일 당일 또는 그 이후의 가장 가까운 시험. */
    Optional<ExamSchedule> findFirstByExamDateGreaterThanEqualOrderByExamDateAsc(LocalDate date);
    Optional<ExamSchedule> findByCertTypeAndRound(CertType certType, Integer round);
    boolean existsByCertTypeAndRound(CertType certType, Integer round);
}
