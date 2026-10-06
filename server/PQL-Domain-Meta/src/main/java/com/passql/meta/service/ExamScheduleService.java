package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.CertType;
import com.passql.meta.dto.ExamScheduleCreateRequest;
import com.passql.meta.dto.ExamScheduleResponse;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExamScheduleService {

    // 시험 날짜는 한국 기준이므로 서버 시간대와 무관하게 KST 로 오늘을 계산한다.
    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    private final ExamScheduleRepository examScheduleRepository;

    public List<ExamScheduleResponse> getSchedulesByCertType(CertType certType) {
        return examScheduleRepository.findByCertTypeOrderByRoundAsc(certType).stream()
                .map(ExamScheduleResponse::from)
                .toList();
    }

    public ExamScheduleResponse getSelectedSchedule() {
        return findEffectiveSchedule()
                .map(ExamScheduleResponse::from)
                .orElse(null);
    }

    /**
     * 화면에 보여 줄 시험 일정.
     *
     * 관리자가 고른 일정이 아직 지나지 않았으면 그것을 쓰고, 이미 지났으면 다가오는 가장 가까운 시험으로 넘어간다.
     * 시험이 끝난 뒤 관리자가 다음 회차로 바꾸지 않으면 홈에 "D+129" 처럼 지난 시험이 계속 보이던 문제를 막는다.
     * 다가오는 시험이 없으면 선택된 일정을 그대로 돌려준다(아무것도 없는 것보다 낫다).
     */
    public Optional<ExamSchedule> findEffectiveSchedule() {
        LocalDate today = LocalDate.now(KST);
        Optional<ExamSchedule> selected = examScheduleRepository.findFirstByIsSelectedTrue();
        if (selected.isPresent() && !selected.get().getExamDate().isBefore(today)) {
            return selected;
        }
        Optional<ExamSchedule> upcoming =
                examScheduleRepository.findFirstByExamDateGreaterThanEqualOrderByExamDateAsc(today);
        return upcoming.isPresent() ? upcoming : selected;
    }

    public List<ExamScheduleResponse> getAllSchedules(CertType certType) {
        if (certType == null) {
            return examScheduleRepository.findAllByOrderByCertTypeAscRoundAsc().stream()
                    .map(ExamScheduleResponse::from)
                    .toList();
        }
        return getSchedulesByCertType(certType);
    }

    @Transactional
    public ExamScheduleResponse createSchedule(ExamScheduleCreateRequest request) {
        CertType certType = CertType.valueOf(request.getCertType());

        if (examScheduleRepository.existsByCertTypeAndRound(certType, request.getRound())) {
            throw new CustomException(ErrorCode.EXAM_SCHEDULE_DUPLICATE);
        }

        ExamSchedule schedule = ExamSchedule.builder()
                .certType(certType)
                .round(request.getRound())
                .examDate(request.getExamDate())
                .isSelected(false)
                .build();

        ExamSchedule saved = examScheduleRepository.save(schedule);
        return ExamScheduleResponse.from(saved);
    }

    @Transactional
    public void selectSchedule(UUID examScheduleUuid) {
        ExamSchedule target = examScheduleRepository.findById(examScheduleUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.EXAM_SCHEDULE_NOT_FOUND));

        examScheduleRepository.findFirstByIsSelectedTrue()
                .ifPresent(current -> current.setIsSelected(false));

        target.setIsSelected(true);
    }

    @Transactional
    public void deleteSchedule(UUID examScheduleUuid) {
        ExamSchedule schedule = examScheduleRepository.findById(examScheduleUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.EXAM_SCHEDULE_NOT_FOUND));

        examScheduleRepository.delete(schedule);
    }
}
