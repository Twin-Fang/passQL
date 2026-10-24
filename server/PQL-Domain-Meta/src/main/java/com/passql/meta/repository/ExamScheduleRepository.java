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

    /** 자격증 종류별, 기준일 당일 또는 그 이후의 가장 가까운 시험. */
    Optional<ExamSchedule> findFirstByCertTypeAndExamDateGreaterThanEqualOrderByExamDateAsc(CertType certType, LocalDate date);

    /** 자격증 종류별, 기준일 이후(당일 제외)의 가장 가까운 시험. */
    Optional<ExamSchedule> findFirstByCertTypeAndExamDateGreaterThanOrderByExamDateAsc(CertType certType, LocalDate date);
    /** 기준일 이전(당일 제외)에 치른 시험 전부 (지난 일정 정리용). */
    List<ExamSchedule> findByExamDateBefore(LocalDate date);

    long countByExamDateBefore(LocalDate date);
    Optional<ExamSchedule> findByCertTypeAndRound(CertType certType, Integer round);
    boolean existsByCertTypeAndRound(CertType certType, Integer round);
}
