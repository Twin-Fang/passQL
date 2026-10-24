package com.passql.application.monitor;

import com.passql.application.monitor.AdminMonitorQueryRepository.HourlyCallRow;
import com.passql.application.monitor.AdminMonitorQueryRepository.HourlyCountRow;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.function.ToDoubleFunction;
import java.util.function.ToLongFunction;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

/**
 * 모니터링 시계열: 시간 축 생성 > AI·SQL·서버 오류 시간별 조회 > 빈 시간 0 채움 > 실패율·평균 지연 계산
 * 축 = 현재 시각이 속한 정시를 마지막으로 hours 개
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminMonitorTimeseriesService {

    private static final DateTimeFormatter HOUR_LABEL_FORMATTER = DateTimeFormatter.ofPattern("MM/dd HH시");

    private final AdminMonitorQueryRepository monitorQueryRepository;

    public MonitorTimeseriesResponse getTimeseries(MonitorFilter filter) {
        LocalDateTime lastHourStart = LocalDateTime.now().truncatedTo(ChronoUnit.HOURS);
        List<LocalDateTime> hourStarts = IntStream.range(0, filter.hours())
                .mapToObj(offset -> lastHourStart.minusHours(filter.hours() - 1L - offset))
                .toList();
        LocalDateTime start = hourStarts.getFirst();
        LocalDateTime end = lastHourStart.plusHours(1);

        Map<LocalDateTime, HourlyCallRow> aiByHour = toMapByHour(monitorQueryRepository.countAiCallsByHour(start, end));
        Map<LocalDateTime, HourlyCallRow> sqlByHour = toMapByHour(monitorQueryRepository.countSqlExecutionsByHour(start, end));
        Map<LocalDateTime, Long> serverErrorCountByHour = monitorQueryRepository.countServerErrorsByHour(start, end).stream()
                .collect(Collectors.toMap(HourlyCountRow::hourStart, HourlyCountRow::count));

        return new MonitorTimeseriesResponse(
                hourStarts.stream().map(HOUR_LABEL_FORMATTER::format).toList(),
                toLongSeries(hourStarts, aiByHour, HourlyCallRow::callCount),
                toDoubleSeries(hourStarts, aiByHour, AdminMonitorTimeseriesService::toFailureRatePercent),
                toLongSeries(hourStarts, aiByHour, AdminMonitorTimeseriesService::toAverageMilliseconds),
                hourStarts.stream().map(hourStart -> serverErrorCountByHour.getOrDefault(hourStart, 0L)).toList(),
                toLongSeries(hourStarts, sqlByHour, HourlyCallRow::callCount),
                toDoubleSeries(hourStarts, sqlByHour, AdminMonitorTimeseriesService::toFailureRatePercent),
                toLongSeries(hourStarts, sqlByHour, AdminMonitorTimeseriesService::toAverageMilliseconds));
    }

    private static Map<LocalDateTime, HourlyCallRow> toMapByHour(List<HourlyCallRow> rows) {
        return rows.stream().collect(Collectors.toMap(HourlyCallRow::hourStart, Function.identity()));
    }

    /** 시간 축 순서로 정수 값 변환 (행 없는 시간은 0) */
    private static List<Long> toLongSeries(List<LocalDateTime> hourStarts, Map<LocalDateTime, HourlyCallRow> rowByHour,
                                           ToLongFunction<HourlyCallRow> converter) {
        return hourStarts.stream()
                .map(hourStart -> rowByHour.containsKey(hourStart) ? converter.applyAsLong(rowByHour.get(hourStart)) : 0L)
                .toList();
    }

    /** 시간 축 순서로 실수 값 변환 (행 없는 시간은 0) */
    private static List<Double> toDoubleSeries(List<LocalDateTime> hourStarts, Map<LocalDateTime, HourlyCallRow> rowByHour,
                                               ToDoubleFunction<HourlyCallRow> converter) {
        return hourStarts.stream()
                .map(hourStart -> rowByHour.containsKey(hourStart) ? converter.applyAsDouble(rowByHour.get(hourStart)) : 0.0)
                .toList();
    }

    private static double toFailureRatePercent(HourlyCallRow row) {
        return row.callCount() == 0 ? 0 : Math.round(row.failureCount() * 1000.0 / row.callCount()) / 10.0;
    }

    private static long toAverageMilliseconds(HourlyCallRow row) {
        return row.callCount() == 0 ? 0 : Math.round(row.totalLatencyMilliseconds() / (double) row.callCount());
    }
}
