package com.passql.web.controller.admin;

import com.passql.application.monitor.AdminMonitorTimeseriesService;
import com.passql.application.monitor.MonitorFilter;
import com.passql.application.monitor.MonitorTimeseriesResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** 관리자 모니터링 시계열 API (#622): 시간별 AI·SQL 실패율·지연, 서버 오류 건수 */
@RestController
@RequestMapping("/admin/api/monitor")
@RequiredArgsConstructor
public class AdminMonitorApiController implements AdminMonitorApiControllerDocs {

    private final AdminMonitorTimeseriesService adminMonitorTimeseriesService;

    // hours 는 선택 가능한 값(1·6·24·72·168) 밖이면 24 로 보정
    @GetMapping("/timeseries")
    public ResponseEntity<MonitorTimeseriesResponse> getTimeseries(@RequestParam(required = false) Integer hours) {
        return ResponseEntity.ok(adminMonitorTimeseriesService.getTimeseries(MonitorFilter.of(hours, null, null)));
    }
}
