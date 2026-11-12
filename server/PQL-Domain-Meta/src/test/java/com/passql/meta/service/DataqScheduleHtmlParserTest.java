package com.passql.meta.service;

import com.passql.meta.constant.ExamScheduleSyncFailureReason;
import com.passql.meta.constant.ExamScheduleYearSource;
import com.passql.meta.dto.DataqScheduleParseResult;
import com.passql.meta.dto.ParsedExamRound;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 공식 일정 페이지 원본 3년치(2024·2025·2026) > SQLD 회차 기대값 고정 + 깨진 HTML 실패 사유 (#991)
 * 원본: src/test/resources/dataq/ (2026 직접 수집, 2025·2024 웹 아카이브)
 */
class DataqScheduleHtmlParserTest {

    @Test
    void 원본_2026_페이지를_제목_연도로_해석한다() throws IOException {
        DataqScheduleParseResult result = DataqScheduleHtmlParser.parse(readFixture("dataq-schedule-2026.html"),
                LocalDate.of(2026, 11, 12), Map.of());

        assertThat(result.isSuccess()).isTrue();
        assertThat(result.scheduleYear()).isEqualTo(2026);
        assertThat(result.yearSource()).isEqualTo(ExamScheduleYearSource.HEADING);
        assertThat(result.rounds()).containsExactly(
                round(60, "2026-02-02", "2026-02-06", "2026-02-20", "2026-03-07", "2026-03-20", "2026-03-24", "2026-03-27"),
                round(61, "2026-04-27", "2026-05-01", "2026-05-15", "2026-05-31", "2026-06-12", "2026-06-16", "2026-06-19"),
                round(62, "2026-07-20", "2026-07-24", "2026-08-07", "2026-08-22", "2026-09-04", "2026-09-08", "2026-09-11"),
                round(63, "2026-10-12", "2026-10-16", "2026-10-30", "2026-11-14", "2026-11-27", "2026-12-01", "2026-12-04"));
    }

    @Test
    void 원본_2025_페이지를_해석한다() throws IOException {
        DataqScheduleParseResult result = DataqScheduleHtmlParser.parse(readFixture("dataq-schedule-2025.html"),
                LocalDate.of(2025, 6, 1), Map.of());

        assertThat(result.isSuccess()).isTrue();
        assertThat(result.scheduleYear()).isEqualTo(2025);
        assertThat(result.rounds()).containsExactly(
                round(56, "2025-02-03", "2025-02-07", "2025-02-21", "2025-03-08", "2025-03-28", "2025-04-01", "2025-04-04"),
                round(57, "2025-04-28", "2025-05-02", "2025-05-16", "2025-05-31", "2025-06-20", "2025-06-24", "2025-06-27"),
                round(58, "2025-07-21", "2025-07-25", "2025-08-08", "2025-08-23", "2025-09-12", "2025-09-16", "2025-09-19"),
                round(59, "2025-10-13", "2025-10-17", "2025-10-31", "2025-11-16", "2025-12-05", "2025-12-09", "2025-12-12"));
    }

    @Test
    void 제목_없는_원본_2024_페이지는_수집_날짜로_연도를_정한다() throws IOException {
        DataqScheduleParseResult result = DataqScheduleHtmlParser.parse(readFixture("dataq-schedule-2024.html"),
                LocalDate.of(2024, 4, 17), Map.of());

        assertThat(result.isSuccess()).isTrue();
        assertThat(result.scheduleYear()).isEqualTo(2024);
        assertThat(result.yearSource()).isEqualTo(ExamScheduleYearSource.REFERENCE_DATE);
        assertThat(result.rounds()).containsExactly(
                round(52, "2024-01-29", "2024-02-02", "2024-02-23", "2024-03-09", "2024-03-29", "2024-04-02", "2024-04-05"),
                round(53, "2024-04-22", "2024-04-26", "2024-05-10", "2024-05-25", "2024-06-14", "2024-06-18", "2024-06-21"),
                round(54, "2024-07-22", "2024-07-26", "2024-08-09", "2024-08-24", "2024-09-06", "2024-09-10", "2024-09-20"),
                round(55, "2024-10-14", "2024-10-18", "2024-11-01", "2024-11-17", "2024-12-06", "2024-12-10", "2024-12-13"));
    }

    @Test
    void 제목_없는_페이지는_저장된_회차_연도를_따르고_새_회차는_다음_해로_보정한다() {
        String rowsOnly = tableWith(sqldRow("제52회", "1.29~2.2", "2.23", "3.9(토)", "3.29~4.2", "4.5"));

        // 같은 회차가 저장돼 있으면 그 연도 (수집 날짜가 2026 이어도)
        DataqScheduleParseResult knownRound = DataqScheduleHtmlParser.parse(rowsOnly,
                LocalDate.of(2026, 1, 10), Map.of(52, LocalDate.of(2024, 3, 9)));
        assertThat(knownRound.scheduleYear()).isEqualTo(2024);
        assertThat(knownRound.yearSource()).isEqualTo(ExamScheduleYearSource.KNOWN_ROUND);

        // 12월에 다음 해 일정이 먼저 올라온 경우: 저장된 마지막 시험(2026-11-14) 뒤로 > 2027, 접수 12.28~1.3 은 연도 넘김
        String nextYearRows = tableWith(sqldRow("제64회", "12.28~1.3", "1.20", "2.7(토)", "2.20~24", "2.27"));
        DataqScheduleParseResult nextYear = DataqScheduleHtmlParser.parse(nextYearRows,
                LocalDate.of(2026, 12, 20), Map.of(63, LocalDate.of(2026, 11, 14)));
        assertThat(nextYear.scheduleYear()).isEqualTo(2027);
        assertThat(nextYear.rounds().get(0).applicationStartDate()).isEqualTo(LocalDate.of(2026, 12, 28));
        assertThat(nextYear.rounds().get(0).applicationEndDate()).isEqualTo(LocalDate.of(2027, 1, 3));
    }

    @Test
    void 깨진_HTML은_실패_사유를_돌려준다() {
        assertThat(failureOf("<html><body><p>점검 중</p></body></html>"))
                .isEqualTo(ExamScheduleSyncFailureReason.TABLE_NOT_FOUND);
        assertThat(failureOf(tableWith("<tr><td rowspan=\"1\">SQL 전문가</td><td>제54회</td><td>-</td>"
                + "<td>2.2~6</td><td>2.20</td><td>3.7(토)</td><td>3.27~31</td><td>4.3</td><td>-</td></tr>")))
                .isEqualTo(ExamScheduleSyncFailureReason.SQLD_ROWS_NOT_FOUND);
        assertThat(failureOf(tableWith("<tr><td>SQL 개발자</td><td>제60회</td><td>-</td><td>2.2~6</td><td>3.7</td></tr>")))
                .isEqualTo(ExamScheduleSyncFailureReason.COLUMN_COUNT_MISMATCH);
        assertThat(failureOf(tableWith(sqldRow("제60회", "2월 2일", "2.20", "3.7(토)", "3.20~24", "3.27"))))
                .isEqualTo(ExamScheduleSyncFailureReason.DATE_PARSE_FAILED);
        assertThat(failureOf(tableWith(sqldRow("제61회", "4.27~5.1", "5.15", "5.31(일)", "6.12~16", "6.19")
                + "<tr><td>제60회</td><td>-</td><td>2.2~6</td><td>2.20</td><td>3.7(토)</td><td>3.20~24</td><td>3.27</td><td>-</td></tr>")))
                .isEqualTo(ExamScheduleSyncFailureReason.ROUND_ORDER_INVALID);
    }

    private static ExamScheduleSyncFailureReason failureOf(String html) {
        DataqScheduleParseResult result = DataqScheduleHtmlParser.parse(html, LocalDate.of(2026, 11, 12), Map.of());
        assertThat(result.isSuccess()).isFalse();
        assertThat(result.sourceExcerpt()).isNotBlank();
        return result.failureReason();
    }

    // 제목·caption 없는 최소 표 (2024 구조)
    private static String tableWith(String bodyRows) {
        return "<table class=\"table_schdule_all\"><caption></caption><thead><tr><th>구분</th><th colspan=\"2\">회차</th>"
                + "<th>접수기간</th><th>수험표발급</th><th>시험일</th><th>사전점수</th><th>결과발표</th><th>증빙서류</th></tr></thead>"
                + "<tbody>" + bodyRows + "</tbody></table>";
    }

    private static String sqldRow(String roundLabel, String application, String ticket, String exam, String preliminary,
                                  String result) {
        return "<tr><td rowspan=\"4\">SQL 개발자</td><td>" + roundLabel + "</td><td>-</td><td>" + application + "</td><td>"
                + ticket + "</td><td>" + exam + "</td><td>" + preliminary + "</td><td>" + result + "</td><td>-</td></tr>";
    }

    private static ParsedExamRound round(int round, String applicationStart, String applicationEnd, String ticket,
                                         String exam, String preliminaryStart, String preliminaryEnd, String result) {
        return new ParsedExamRound(round, LocalDate.parse(applicationStart), LocalDate.parse(applicationEnd),
                LocalDate.parse(ticket), LocalDate.parse(exam), LocalDate.parse(preliminaryStart),
                LocalDate.parse(preliminaryEnd), LocalDate.parse(result));
    }

    private static String readFixture(String fileName) throws IOException {
        try (InputStream inputStream = DataqScheduleHtmlParserTest.class.getResourceAsStream("/dataq/" + fileName)) {
            return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
}
