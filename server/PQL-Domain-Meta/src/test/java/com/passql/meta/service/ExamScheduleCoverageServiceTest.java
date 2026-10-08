package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.CertType;
import com.passql.meta.dto.ExamCoverage;
import com.passql.meta.dto.ExamCoverage.Level;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;

/** 시험 일정 공고 확인 보조 (#411) — "지금 공식 공고를 확인해야 하는가" 판단을 날짜로 고정한다. */
class ExamScheduleCoverageServiceTest {

    private static final LocalDate TODAY = LocalDate.of(2026, 10, 8);

    private static ExamSchedule exam(CertType type, int round, LocalDate date, boolean selected) {
        return ExamSchedule.builder().certType(type).round(round).examDate(date).isSelected(selected).build();
    }

    private static ExamCoverage eval(CertType type, ExamSchedule... schedules) {
        return ExamScheduleCoverageService.evaluate(type, List.of(schedules), TODAY).orElseThrow();
    }

    @Test
    void 마지막_등록_회차가_60일_안이면_다음_공고_확인을_알린다() {
        // 운영 현재 상태: 제63회(11/14)가 마지막, 선택은 지난 제61회였다가 63회로 바꾼 뒤
        ExamCoverage c = eval(CertType.SQLD,
                exam(CertType.SQLD, 62, LocalDate.of(2026, 8, 22), false),
                exam(CertType.SQLD, 63, LocalDate.of(2026, 11, 14), true));

        assertThat(c.level()).isEqualTo(Level.WARN);
        assertThat(c.nextRound()).isEqualTo(63);
        assertThat(c.daysUntilNext()).isEqualTo(37);
        assertThat(c.daysUntilLast()).isEqualTo(37);
        assertThat(c.needsAction()).isTrue();
        assertThat(c.message()).contains("제63회").contains("37일");
    }

    @Test
    void 마지막_등록_회차가_충분히_남았으면_정상() {
        ExamCoverage c = eval(CertType.SQLD,
                exam(CertType.SQLD, 63, LocalDate.of(2026, 11, 14), false),
                exam(CertType.SQLD, 64, LocalDate.of(2027, 3, 6), true));

        assertThat(c.level()).isEqualTo(Level.OK);
        assertThat(c.needsAction()).isFalse();
        assertThat(c.nextRound()).isEqualTo(63);
    }

    @Test
    void 다가오는_시험이_하나도_없으면_오류() {
        ExamCoverage c = eval(CertType.SQLD, exam(CertType.SQLD, 63, TODAY.minusDays(1), true));

        assertThat(c.level()).isEqualTo(Level.ERROR);
        assertThat(c.nextRound()).isNull();
        assertThat(c.selectedExpiredRound()).isEqualTo(63);
    }

    @Test
    void 선택된_회차가_지났으면_알려_준다() {
        ExamCoverage c = eval(CertType.SQLD,
                exam(CertType.SQLD, 61, LocalDate.of(2026, 5, 31), true),
                exam(CertType.SQLD, 63, LocalDate.of(2026, 11, 14), false));

        assertThat(c.selectedExpiredRound()).isEqualTo(61);
        assertThat(c.nextRound()).isEqualTo(63);
    }

    @Test
    void 시험_당일은_다가오는_시험으로_본다() {
        ExamCoverage c = eval(CertType.SQLD, exam(CertType.SQLD, 63, TODAY, true));
        assertThat(c.nextRound()).isEqualTo(63);
        assertThat(c.daysUntilNext()).isZero();
    }

    @Test
    void SQLD만_일정이_없어도_평가하고_다른_자격증은_건너뛴다() {
        assertThat(ExamScheduleCoverageService.evaluate(CertType.SQLD, List.of(), TODAY))
                .hasValueSatisfying(c -> assertThat(c.level()).isEqualTo(Level.ERROR));
        assertThat(ExamScheduleCoverageService.evaluate(CertType.SQLP, List.of(), TODAY)).isEmpty();
    }

    @Test
    void 확인일_기록이_없거나_깨졌거나_오래됐으면_확인_필요() {
        AppSettingService settings = mock(AppSettingService.class);
        ExamScheduleCoverageService service = new ExamScheduleCoverageService(mock(ExamScheduleRepository.class), settings);

        // 이미 던지도록 설정한 목에는 when(...) 호출 자체가 예외를 내므로 doReturn/doThrow 로 다시 설정한다
        doReturn("").when(settings).getString(anyString());
        assertThat(service.getCheckedAt()).isEmpty();
        assertThat(service.isCheckStale()).isTrue();

        doReturn("not-a-date").when(settings).getString(anyString());
        assertThat(service.getCheckedAt()).isEmpty();

        doThrow(new CustomException(ErrorCode.SETTING_NOT_FOUND)).when(settings).getString(anyString());
        assertThat(service.getCheckedAt()).isEmpty();

        doReturn(LocalDate.now().minusDays(3).toString()).when(settings).getString(anyString());
        assertThat(service.isCheckStale()).isFalse();

        doReturn(LocalDate.now().minusDays(45).toString()).when(settings).getString(anyString());
        assertThat(service.isCheckStale()).isTrue();
    }
}
