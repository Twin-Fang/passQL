package com.passql.web.controller.admin;

import com.passql.application.monitor.MonitorTimeseriesResponse;
import com.passql.common.dto.Author;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin - Monitor", description = "관리자 모니터링 시계열 (관리자 세션, 조회는 VIEWER 허용)")
public interface AdminMonitorApiControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.24", author = Author.SUHSAECHAN, issueNumber = 622, description = "모니터링 오류율·지연 시계열 API 추가"),
    })
    @Operation(summary = "오류율·지연 시계열", description = "hours: 1·6·24(기본)·72·168. 시간별 AI 호출·실패율·평균 지연, 서버 오류(5xx) 건수, SQL 실행·실패율·평균 소요")
    ResponseEntity<MonitorTimeseriesResponse> getTimeseries(Integer hours);
}
