package com.passql.meta.service;

import com.passql.common.util.TextPreview;
import com.passql.meta.constant.ExamScheduleSyncFailureReason;
import com.passql.meta.constant.ExamScheduleYearSource;
import com.passql.meta.dto.DataqScheduleParseResult;
import com.passql.meta.dto.ParsedExamRound;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import java.time.LocalDate;
import java.time.MonthDay;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 데이터자격검정 시험 일정 HTML > SQLD 회차 목록 (#991, 규칙 기반, LLM 미사용)
 * 표 찾기 > 헤더 열 수 검사 > SQL 개발자 행 수집 > 날짜 칸 해석 > 연도 결정 > 날짜 확정 > 순서 검사
 *
 * <p>열은 이름이 아니라 위치로 읽는다 (2024 는 열 이름이 달랐음). 회차 칸 뒤 7칸:
 * 구분(필기/실기/-) | 원서접수 | 수험표발급 | 시험일 | 사전점수공개·재검토 | 합격발표 | 응시자격 서류제출(미사용)
 *
 * <p>연도 결정 (ExamScheduleYearSource 우선순위):
 * 1) "N년도 일정" 제목 2) 표 caption "N년" 3) 이미 저장된 같은 회차의 시험 연도
 * 4) 수집 날짜의 연도 > 저장된 회차보다 새 회차면 저장된 마지막 시험 뒤가 될 때까지 +1년, 옛 회차면 저장된 첫 시험 앞이 될 때까지 -1년 (최대 3년)
 * 회차 안 날짜는 시험일 기준: 시험일보다 늦은 접수·수험표는 전년도, 시험일보다 이른 사전점수·발표는 다음 해 (12.28~1.3 같은 연도 넘김)
 */
public final class DataqScheduleHtmlParser {

    // 공식 일정 표 선택자
    static final String SCHEDULE_TABLE_SELECTOR = "table.table_schdule_all";
    // 헤더 논리 열 수: 구분 1 + 회차 2(colspan) + 일정 6
    static final int EXPECTED_HEADER_COLUMN_COUNT = 9;
    // 회차 칸 뒤 칸 수 (구분·원서접수·수험표·시험일·사전점수·발표·서류)
    static final int EXPECTED_CELLS_AFTER_ROUND = 7;
    // 구분 칸 이름 (공백 제거 후 비교)
    static final String SQLD_CATEGORY_NAME = "SQL개발자";
    // 연도 보정 최대 폭 (년)
    private static final int MAX_YEAR_ADJUSTMENT = 3;
    // 행 원문 일부 길이 (자)
    private static final int ROW_EXCERPT_LENGTH = 500;

    // 회차 칸 "제60회"
    private static final Pattern ROUND_LABEL = Pattern.compile("^제\\s*(\\d+)\\s*회$");
    // 회차 하위 구분 칸 (필기·실기·-)
    private static final Pattern ROUND_SUBTYPE_LABEL = Pattern.compile("^(필기|실기|-)$");
    // 날짜처럼 보이는 칸 (구분 칸 오인 방지)
    private static final Pattern DATE_LIKE = Pattern.compile("^\\d{1,2}\\..*");
    private static final Pattern YEAR_HEADING = Pattern.compile("(\\d{4})\\s*년도\\s*일정");
    private static final Pattern YEAR_CAPTION = Pattern.compile("(\\d{4})\\s*년");
    private static final Pattern WHITESPACE = Pattern.compile("\\s+");

    // 회차 칸 뒤 위치
    private static final int APPLICATION_CELL_INDEX = 1;
    private static final int ADMISSION_TICKET_CELL_INDEX = 2;
    private static final int EXAM_CELL_INDEX = 3;
    private static final int PRELIMINARY_SCORE_CELL_INDEX = 4;
    private static final int RESULT_CELL_INDEX = 5;

    private DataqScheduleHtmlParser() {
    }

    /** 표 1행에서 읽은 SQLD 회차 (날짜는 월·일만) */
    private record RawRound(int round, DataqScheduleDateText application, DataqScheduleDateText admissionTicket,
                            DataqScheduleDateText exam, DataqScheduleDateText preliminaryScore,
                            DataqScheduleDateText result, String rowExcerpt) {
    }

    private record YearDecision(int year, ExamScheduleYearSource source) {
    }

    /**
     * HTML > SQLD 회차 목록
     *
     * @param referenceDate          수집 날짜 (연도 단서가 없을 때 기준)
     * @param knownExamDateByRound   이미 저장된 SQLD 회차 > 시험일 (연도 보정용, 비어도 됨)
     */
    public static DataqScheduleParseResult parse(String html, LocalDate referenceDate,
                                                 Map<Integer, LocalDate> knownExamDateByRound) {
        Document document = Jsoup.parse(html == null ? "" : html);
        Element table = document.selectFirst(SCHEDULE_TABLE_SELECTOR);
        if (table == null) {
            return DataqScheduleParseResult.failure(ExamScheduleSyncFailureReason.TABLE_NOT_FOUND,
                    SCHEDULE_TABLE_SELECTOR + " not found", document.text());
        }
        int headerColumnCount = countHeaderColumns(table);
        if (headerColumnCount != EXPECTED_HEADER_COLUMN_COUNT) {
            return DataqScheduleParseResult.failure(ExamScheduleSyncFailureReason.COLUMN_COUNT_MISMATCH,
                    "header columns expected " + EXPECTED_HEADER_COLUMN_COUNT + " but " + headerColumnCount,
                    excerpt(table.selectFirst("thead")));
        }

        // SQL 개발자 행 수집 (칸 수 다르면 즉시 실패)
        List<RawRound> rawRounds = new ArrayList<>();
        String currentCategory = null;
        for (Element row : table.select("tbody > tr")) {
            List<Element> cells = row.children().stream().filter(cell -> cell.tagName().equals("td")).toList();
            int cellIndex = 0;
            if (!cells.isEmpty() && isCategoryCell(cells.get(0))) {
                currentCategory = WHITESPACE.matcher(cells.get(0).text()).replaceAll("");
                cellIndex = 1;
            }
            if (!SQLD_CATEGORY_NAME.equals(currentCategory) || cellIndex >= cells.size()) {
                continue;
            }
            Optional<Integer> round = parseRoundLabel(cells.get(cellIndex).text());
            if (round.isEmpty()) {
                continue;
            }
            List<Element> valueCells = cells.subList(cellIndex + 1, cells.size());
            if (valueCells.size() != EXPECTED_CELLS_AFTER_ROUND) {
                return DataqScheduleParseResult.failure(ExamScheduleSyncFailureReason.COLUMN_COUNT_MISMATCH,
                        "round " + round.get() + " cells expected " + EXPECTED_CELLS_AFTER_ROUND + " but " + valueCells.size(),
                        excerpt(row));
            }
            Optional<RawRound> rawRound = toRawRound(round.get(), valueCells, row);
            if (rawRound.isEmpty()) {
                return DataqScheduleParseResult.failure(ExamScheduleSyncFailureReason.DATE_PARSE_FAILED,
                        "round " + round.get() + " has unreadable date", excerpt(row));
            }
            rawRounds.add(rawRound.get());
        }
        if (rawRounds.isEmpty()) {
            return DataqScheduleParseResult.failure(ExamScheduleSyncFailureReason.SQLD_ROWS_NOT_FOUND,
                    "no " + SQLD_CATEGORY_NAME + " rows", excerpt(table));
        }

        YearDecision yearDecision = resolveYear(document, table, rawRounds, referenceDate,
                knownExamDateByRound == null ? Map.of() : knownExamDateByRound);
        List<ParsedExamRound> rounds = new ArrayList<>();
        for (RawRound rawRound : rawRounds) {
            Optional<ParsedExamRound> parsedRound = toParsedRound(rawRound, yearDecision.year());
            if (parsedRound.isEmpty()) {
                return DataqScheduleParseResult.failure(ExamScheduleSyncFailureReason.DATE_PARSE_FAILED,
                        "round " + rawRound.round() + " exam date invalid in " + yearDecision.year(), rawRound.rowExcerpt());
            }
            Optional<String> dateOrderProblem = findDateOrderProblem(parsedRound.get());
            if (dateOrderProblem.isPresent()) {
                return DataqScheduleParseResult.failure(ExamScheduleSyncFailureReason.DATE_ORDER_INVALID,
                        "round " + rawRound.round() + " " + dateOrderProblem.get(), rawRound.rowExcerpt());
            }
            rounds.add(parsedRound.get());
        }
        Optional<String> roundOrderProblem = findRoundOrderProblem(rounds);
        if (roundOrderProblem.isPresent()) {
            return DataqScheduleParseResult.failure(ExamScheduleSyncFailureReason.ROUND_ORDER_INVALID,
                    roundOrderProblem.get(), excerpt(table));
        }
        return DataqScheduleParseResult.success(yearDecision.year(), yearDecision.source(), rounds);
    }

    /** 헤더 첫 행 th 의 colspan 합 */
    private static int countHeaderColumns(Element table) {
        Element headerRow = table.selectFirst("thead tr");
        if (headerRow == null) {
            return 0;
        }
        return headerRow.select("th").stream()
                .mapToInt(headerCell -> parsePositiveIntOrOne(headerCell.attr("colspan")))
                .sum();
    }

    // 구분 칸: 회차·하위 구분(필기/실기/-)·날짜가 아닌 첫 칸
    private static boolean isCategoryCell(Element cell) {
        String text = cell.text().trim();
        return !text.isEmpty() && parseRoundLabel(text).isEmpty()
                && !ROUND_SUBTYPE_LABEL.matcher(text).matches() && !DATE_LIKE.matcher(text).matches();
    }

    private static Optional<Integer> parseRoundLabel(String text) {
        Matcher matcher = ROUND_LABEL.matcher(text.trim());
        return matcher.matches() ? Optional.of(Integer.parseInt(matcher.group(1))) : Optional.empty();
    }

    // 날짜 칸 5개 해석 (시험일 빈 칸·해석 불가 > empty)
    private static Optional<RawRound> toRawRound(int round, List<Element> valueCells, Element row) {
        Optional<DataqScheduleDateText> application = DataqScheduleDateText.parse(valueCells.get(APPLICATION_CELL_INDEX).text());
        Optional<DataqScheduleDateText> admissionTicket = DataqScheduleDateText.parse(valueCells.get(ADMISSION_TICKET_CELL_INDEX).text());
        Optional<DataqScheduleDateText> exam = DataqScheduleDateText.parse(valueCells.get(EXAM_CELL_INDEX).text());
        Optional<DataqScheduleDateText> preliminaryScore = DataqScheduleDateText.parse(valueCells.get(PRELIMINARY_SCORE_CELL_INDEX).text());
        Optional<DataqScheduleDateText> result = DataqScheduleDateText.parse(valueCells.get(RESULT_CELL_INDEX).text());
        boolean isAnyUnreadable = application.isEmpty() || admissionTicket.isEmpty() || exam.isEmpty()
                || preliminaryScore.isEmpty() || result.isEmpty();
        if (isAnyUnreadable || exam.get().isBlank()) {
            return Optional.empty();
        }
        return Optional.of(new RawRound(round, application.get(), admissionTicket.get(), exam.get(),
                preliminaryScore.get(), result.get(), excerpt(row)));
    }

    /** 연도 결정 (클래스 주석의 우선순위 1~4) */
    private static YearDecision resolveYear(Document document, Element table, List<RawRound> rawRounds,
                                            LocalDate referenceDate, Map<Integer, LocalDate> knownExamDateByRound) {
        for (Element heading : document.select("h1, h2, h3, h4, h5")) {
            Matcher headingMatcher = YEAR_HEADING.matcher(heading.text());
            if (headingMatcher.find()) {
                return new YearDecision(Integer.parseInt(headingMatcher.group(1)), ExamScheduleYearSource.HEADING);
            }
        }
        Element caption = table.selectFirst("caption");
        if (caption != null) {
            Matcher captionMatcher = YEAR_CAPTION.matcher(caption.text());
            if (captionMatcher.find()) {
                return new YearDecision(Integer.parseInt(captionMatcher.group(1)), ExamScheduleYearSource.CAPTION);
            }
        }
        for (RawRound rawRound : rawRounds) {
            LocalDate knownExamDate = knownExamDateByRound.get(rawRound.round());
            if (knownExamDate != null) {
                return new YearDecision(knownExamDate.getYear(), ExamScheduleYearSource.KNOWN_ROUND);
            }
        }
        return new YearDecision(adjustReferenceYear(rawRounds, referenceDate.getYear(), knownExamDateByRound),
                ExamScheduleYearSource.REFERENCE_DATE);
    }

    // 저장된 회차보다 새 회차면 저장된 마지막 시험 뒤로, 옛 회차면 저장된 첫 시험 앞으로 (최대 3년)
    private static int adjustReferenceYear(List<RawRound> rawRounds, int referenceYear,
                                           Map<Integer, LocalDate> knownExamDateByRound) {
        if (knownExamDateByRound.isEmpty()) {
            return referenceYear;
        }
        MonthDay firstExamMonthDay = rawRounds.get(0).exam().startMonthDay();
        int firstParsedRound = rawRounds.get(0).round();
        int lastParsedRound = rawRounds.get(rawRounds.size() - 1).round();
        LocalDate latestKnownExamDate = Collections.max(knownExamDateByRound.values());
        LocalDate earliestKnownExamDate = Collections.min(knownExamDateByRound.values());
        int year = referenceYear;
        if (firstParsedRound > Collections.max(knownExamDateByRound.keySet())) {
            while (!firstExamMonthDay.atYear(year).isAfter(latestKnownExamDate) && year < referenceYear + MAX_YEAR_ADJUSTMENT) {
                year++;
            }
        } else if (lastParsedRound < Collections.min(knownExamDateByRound.keySet())) {
            while (!firstExamMonthDay.atYear(year).isBefore(earliestKnownExamDate) && year > referenceYear - MAX_YEAR_ADJUSTMENT) {
                year--;
            }
        }
        return year;
    }

    /** 월·일 > 날짜 (시험일 기준 연도 넘김 보정, 시험일이 그 해에 없는 날이면 empty) */
    private static Optional<ParsedExamRound> toParsedRound(RawRound rawRound, int year) {
        MonthDay examMonthDay = rawRound.exam().startMonthDay();
        if (!examMonthDay.isValidYear(year)) {
            return Optional.empty();
        }
        LocalDate examDate = examMonthDay.atYear(year);
        return Optional.of(new ParsedExamRound(rawRound.round(),
                toDateBeforeExam(rawRound.application().startMonthDay(), examDate),
                toDateBeforeExam(rawRound.application().endMonthDay(), examDate),
                toDateBeforeExam(rawRound.admissionTicket().startMonthDay(), examDate),
                examDate,
                toDateAfterExam(rawRound.preliminaryScore().startMonthDay(), examDate),
                toDateAfterExam(rawRound.preliminaryScore().endMonthDay(), examDate),
                toDateAfterExam(rawRound.result().startMonthDay(), examDate)));
    }

    // 시험 전 일정: 시험일보다 늦은 월·일이면 전년도
    private static LocalDate toDateBeforeExam(MonthDay monthDay, LocalDate examDate) {
        if (monthDay == null) {
            return null;
        }
        int year = monthDay.isAfter(MonthDay.from(examDate)) ? examDate.getYear() - 1 : examDate.getYear();
        return monthDay.atYear(year);
    }

    // 시험 뒤 일정: 시험일보다 이른 월·일이면 다음 해
    private static LocalDate toDateAfterExam(MonthDay monthDay, LocalDate examDate) {
        if (monthDay == null) {
            return null;
        }
        int year = monthDay.isBefore(MonthDay.from(examDate)) ? examDate.getYear() + 1 : examDate.getYear();
        return monthDay.atYear(year);
    }

    // 회차 안 순서: 접수 시작 <= 접수 마감 <= 수험표 <= 시험 <= 사전점수 시작 <= 사전점수 마감 <= 발표 (빈 칸 제외)
    private static Optional<String> findDateOrderProblem(ParsedExamRound round) {
        List<LocalDate> datesInOrder = new ArrayList<>();
        for (LocalDate date : new LocalDate[]{round.applicationStartDate(), round.applicationEndDate(),
                round.admissionTicketDate(), round.examDate(), round.preliminaryScoreStartDate(),
                round.preliminaryScoreEndDate(), round.resultAnnouncementDate()}) {
            if (date != null) {
                datesInOrder.add(date);
            }
        }
        for (int index = 1; index < datesInOrder.size(); index++) {
            if (datesInOrder.get(index).isBefore(datesInOrder.get(index - 1))) {
                return Optional.of("dates out of order : " + datesInOrder.get(index - 1) + " -> " + datesInOrder.get(index));
            }
        }
        return Optional.empty();
    }

    // 회차·시험일 모두 위에서 아래로 커져야 함 (중복 회차 포함)
    private static Optional<String> findRoundOrderProblem(List<ParsedExamRound> rounds) {
        for (int index = 1; index < rounds.size(); index++) {
            ParsedExamRound previous = rounds.get(index - 1);
            ParsedExamRound current = rounds.get(index);
            if (current.round() <= previous.round() || !current.examDate().isAfter(previous.examDate())) {
                return Optional.of("round order invalid : " + previous.round() + "(" + previous.examDate() + ") -> "
                        + current.round() + "(" + current.examDate() + ")");
            }
        }
        return Optional.empty();
    }

    private static int parsePositiveIntOrOne(String text) {
        try {
            int value = Integer.parseInt(text.trim());
            return value > 0 ? value : 1;
        } catch (NumberFormatException e) {
            return 1;
        }
    }

    // 원문 일부 (HTML 그대로, 관리자 화면에서 이스케이프 표시)
    private static String excerpt(Element element) {
        return element == null ? "" : TextPreview.truncate(element.outerHtml(), ROW_EXCERPT_LENGTH);
    }
}
