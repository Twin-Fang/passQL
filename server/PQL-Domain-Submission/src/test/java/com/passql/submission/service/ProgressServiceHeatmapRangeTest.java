package com.passql.submission.service;

import com.passql.member.repository.MemberRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.meta.service.ExamScheduleService;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 히트맵 조회 범위: KST 날짜 자정 그대로 전달 (submitted_at 은 서버 로컬 KST 저장값, UTC 변환 금지) (#560)
 */
class ProgressServiceHeatmapRangeTest {

    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final ProgressService progressService = new ProgressService(
            submissionRepository, memberRepository, mock(TopicRepository.class), mock(ExamScheduleService.class));

    @Test
    void 히트맵_범위는_KST_자정_그대로_9시간_변환_없음() {
        UUID memberUuid = UUID.randomUUID();
        when(memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(true);
        when(submissionRepository.findHeatmapByMemberUuid(any(), any(), any())).thenReturn(List.of());

        progressService.getHeatmap(memberUuid, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 20));

        verify(submissionRepository).findHeatmapByMemberUuid(
                eq(memberUuid.toString()),
                eq(LocalDateTime.of(2026, 10, 1, 0, 0)),
                eq(LocalDateTime.of(2026, 10, 21, 0, 0)));
    }
}
