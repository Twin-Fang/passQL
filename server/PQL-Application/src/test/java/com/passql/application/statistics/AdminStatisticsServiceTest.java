package com.passql.application.statistics;

import com.passql.application.community.CommunityAdminService;
import com.passql.application.constant.StatisticsRange;
import com.passql.application.service.AdminDashboardService;
import com.passql.application.statistics.AdminStatisticsQueryRepository.BucketCountRow;
import com.passql.application.statistics.AdminStatisticsQueryRepository.SignupBucketRow;
import com.passql.application.statistics.dto.DashboardGrowthResponse;
import com.passql.member.service.MemberActivityRecorder;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 가입·방문 추이: 축 길이 고정, 빈 날 0, 누적 회원 수 = 축 이전 회원 수 + 남아 있는 가입 누적 */
class AdminStatisticsServiceTest {

    private final AdminStatisticsQueryRepository statisticsQueryRepository = mock(AdminStatisticsQueryRepository.class);
    private final AdminStatisticsService adminStatisticsService = new AdminStatisticsService(
            statisticsQueryRepository, mock(AdminAiStatisticsQueryRepository.class), mock(MemberActivityRecorder.class),
            mock(CommunityAdminService.class), mock(AdminDashboardService.class));

    @Test
    void 일별_추이는_30일을_0으로_채우고_누적_회원_수를_이어_더한다() {
        LocalDate today = LocalDate.now();
        when(statisticsQueryRepository.countSignupsByBucket(eq(StatisticsRange.DAY), any(), any())).thenReturn(List.of(
                new SignupBucketRow(today.minusDays(2), 3, 2),
                new SignupBucketRow(today, 1, 1)));
        when(statisticsQueryRepository.countVisitorsByBucket(eq(StatisticsRange.DAY), any(), any())).thenReturn(List.of(
                new BucketCountRow(today, 7)));
        when(statisticsQueryRepository.countRemainingMembersCreatedBefore(today.minusDays(29).atStartOfDay()))
                .thenReturn(100L);

        DashboardGrowthResponse growth = adminStatisticsService.getGrowth(StatisticsRange.DAY);

        assertThat(growth.labels()).hasSize(30)
                .startsWith(today.minusDays(29).format(DateTimeFormatter.ofPattern("MM/dd")))
                .endsWith(today.format(DateTimeFormatter.ofPattern("MM/dd")));
        assertThat(growth.signupCounts()).hasSize(30).endsWith(3L, 0L, 1L);
        assertThat(growth.signupCounts().subList(0, 27)).containsOnly(0L);
        assertThat(growth.visitorCounts()).hasSize(30).endsWith(0L, 7L);
        assertThat(growth.cumulativeMemberCounts()).startsWith(100L).endsWith(102L, 102L, 103L);
    }

    @Test
    void 월별_추이는_이번_달까지_12개월이다() {
        LocalDate thisMonthStart = LocalDate.now().withDayOfMonth(1);

        DashboardGrowthResponse growth = adminStatisticsService.getGrowth(StatisticsRange.MONTH);

        assertThat(growth.labels()).hasSize(12)
                .startsWith(thisMonthStart.minusMonths(11).format(DateTimeFormatter.ofPattern("yyyy.MM")))
                .endsWith(thisMonthStart.format(DateTimeFormatter.ofPattern("yyyy.MM")));
        assertThat(growth.signupCounts()).hasSize(12).containsOnly(0L);
    }
}
