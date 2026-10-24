package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.meta.constant.CertType;
import com.passql.meta.dto.ExamScheduleBulkResult;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 시험 일정 일괄 등록·지난 일정 정리 (#618): 텍스트 해석, 중복 건너뜀, 잘못된 줄 전체 거부 */
class ExamScheduleBulkImportTest {

    private final ExamScheduleRepository repository = mock(ExamScheduleRepository.class);
    private final ExamScheduleService service = new ExamScheduleService(repository, event -> { });

    @Test
    void 줄마다_자격증_회차_시험일을_해석하고_날짜_구분자_3종과_주석_빈줄을_허용한다() {
        var result = ExamScheduleBulkTextParser.parse("""
                # 2026 하반기
                SQLD 63 2026-11-14

                sqlp, 64, 2027.02.27
                SQLD\t65\t2027/05/29
                """);

        assertThat(result.errors()).isEmpty();
        assertThat(result.entries()).extracting(ExamScheduleBulkTextParser.Entry::certType)
                .containsExactly(CertType.SQLD, CertType.SQLP, CertType.SQLD);
        assertThat(result.entries().get(1).examDate()).isEqualTo(LocalDate.of(2027, 2, 27));
    }

    @Test
    void 잘못된_줄은_줄_번호와_사유로_모은다() {
        var result = ExamScheduleBulkTextParser.parse("SQLD 63\nXXX 1 2026-01-01\nSQLD 0 2026-01-01\nSQLD 1 2026-13-40");

        assertThat(result.errors()).hasSize(4);
        assertThat(result.errors().get(0)).startsWith("1번째 줄");
        assertThat(result.errors().get(3)).startsWith("4번째 줄");
    }

    @Test
    void 이미_있는_회차와_붙여넣기_안_중복은_건너뛰고_나머지만_등록한다() {
        when(repository.existsByCertTypeAndRound(CertType.SQLD, 63)).thenReturn(true);

        ExamScheduleBulkResult result = service.importSchedules("SQLD 63 2026-11-14\nSQLD 64 2027-02-27\nSQLD 64 2027-02-27");

        assertThat(result.count()).isEqualTo(1);
        assertThat(result.skippedDuplicateCount()).isEqualTo(2);
        verify(repository).save(any(ExamSchedule.class));
    }

    @Test
    void 잘못된_줄이_하나라도_있으면_아무것도_등록하지_않는다() {
        assertThatThrownBy(() -> service.importSchedules("SQLD 63 2026-11-14\n오타 줄"))
                .isInstanceOf(CustomException.class);
        verify(repository, never()).save(any(ExamSchedule.class));
    }

    @Test
    void 지난_일정_정리는_시험일이_오늘_이전인_일정만_삭제한다() {
        ExamSchedule pastSchedule = ExamSchedule.builder().certType(CertType.SQLD).round(61).examDate(LocalDate.now().minusDays(30)).build();
        when(repository.findByExamDateBefore(service.getTodayInKorea())).thenReturn(List.of(pastSchedule));

        ExamScheduleBulkResult result = service.deletePastSchedules();

        assertThat(result.count()).isEqualTo(1);
        verify(repository).deleteAll(List.of(pastSchedule));
    }
}
