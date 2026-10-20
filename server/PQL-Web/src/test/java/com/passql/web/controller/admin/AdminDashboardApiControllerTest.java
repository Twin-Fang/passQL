package com.passql.web.controller.admin;

import com.passql.application.constant.StatisticsRange;
import com.passql.application.statistics.AdminAiStatisticsService;
import com.passql.application.statistics.AdminStatisticsService;
import com.passql.application.statistics.dto.DashboardGrowthResponse;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 대시보드 API 스모크 (#557): 요청 범위 그대로 서비스 위임, 응답 원형 200 */
class AdminDashboardApiControllerTest {

    private final AdminStatisticsService adminStatisticsService = mock(AdminStatisticsService.class);
    private final AdminAiStatisticsService adminAiStatisticsService = mock(AdminAiStatisticsService.class);
    private final AdminDashboardApiController adminDashboardApiController =
            new AdminDashboardApiController(adminStatisticsService, adminAiStatisticsService);

    @Test
    void 가입_추이는_요청_범위로_조회해_그대로_반환한다() {
        DashboardGrowthResponse growth = new DashboardGrowthResponse(List.of("2026.10"), List.of(1L), List.of(2L), List.of(3L));
        when(adminStatisticsService.getGrowth(StatisticsRange.MONTH)).thenReturn(growth);

        ResponseEntity<DashboardGrowthResponse> response = adminDashboardApiController.getGrowth(StatisticsRange.MONTH);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isEqualTo(growth);
        verify(adminStatisticsService).getGrowth(StatisticsRange.MONTH);
    }
}
