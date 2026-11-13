package com.passql.meta.client;

import com.passql.meta.dto.DataqScheduleParseResult;
import com.passql.meta.service.DataqScheduleHtmlParser;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;

import java.time.LocalDate;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 실제 공식 페이지 1회 호출 > 해석 성공 확인 (#991, 외부 네트워크라 기본 비활성)
 * 실행: LIVE_DATAQ=true ./gradlew :PQL-Domain-Meta:test --tests '*DataqSchedulePageLiveTest*' --no-daemon
 */
@EnabledIfEnvironmentVariable(named = "LIVE_DATAQ", matches = "true")
class DataqSchedulePageLiveTest {

    @Test
    void 실제_공식_페이지를_가져와_SQLD_회차를_해석한다() {
        DataqSchedulePageClient.FetchResult fetchResult = new DataqSchedulePageClient().fetchSchedulePage();
        assertThat(fetchResult.isSuccess()).as(fetchResult.failureDetail()).isTrue();

        DataqScheduleParseResult parseResult = DataqScheduleHtmlParser.parse(fetchResult.html(), LocalDate.now(), Map.of());
        System.out.println("[live dataq] " + parseResult);
        assertThat(parseResult.isSuccess()).as(parseResult.failureDetail()).isTrue();
        assertThat(parseResult.rounds()).isNotEmpty();
    }
}
