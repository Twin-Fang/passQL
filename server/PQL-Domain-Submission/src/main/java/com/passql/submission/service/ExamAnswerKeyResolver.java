package com.passql.submission.service;

import com.passql.submission.constant.ExamAnswerItemStatus;
import com.passql.submission.entity.ExamAnswerItem;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 표시용 정답 결정 (순수 계산): 운영 가답안(LEADING·CONFIRMED·OFFICIAL) 우선 > 득표 1위 > 없음
 * 득표 집계: 답안 문자열 목록 > 문항별 보기 1~4 득표 수
 */
public final class ExamAnswerKeyResolver {

    // 보기 수 (4지선다, 득표 배열은 인덱스 1~4 사용)
    public static final int CHOICE_COUNT = 4;
    // 복수 정답 구분자 (예: "2,3")
    private static final String ALTERNATIVE_ANSWER_DELIMITER = ",";

    private ExamAnswerKeyResolver() {
    }

    /** 답안 목록 > [문항 인덱스][보기 번호] 득표 수 (형식이 다른 답안은 건너뜀) */
    public static int[][] countVotes(List<String> sheetAnswers, int questionCount) {
        int[][] voteCounts = new int[questionCount][CHOICE_COUNT + 1];
        for (String answers : sheetAnswers) {
            if (answers == null || answers.length() != questionCount) {
                continue;
            }
            for (int questionIndex = 0; questionIndex < questionCount; questionIndex++) {
                int choice = answers.charAt(questionIndex) - '0';
                if (choice >= 1 && choice <= CHOICE_COUNT) {
                    voteCounts[questionIndex][choice]++;
                }
            }
        }
        return voteCounts;
    }

    /** 문항 + 득표 수(인덱스 1~4) > 채점 기준 */
    public static ExamAnswerKey resolve(ExamAnswerItem item, int[] voteCountByChoice) {
        boolean isOperatorAnswerUsed = item.getOperatorAnswerStatus().isOperatorAnswerTrusted()
                && isValidChoice(item.getOperatorAnswer());
        Integer answer = isOperatorAnswerUsed ? item.getOperatorAnswer() : findLeadingChoice(voteCountByChoice);

        // 인정 보기: 표시용 정답 + 복수 정답
        Set<Integer> acceptedAnswers = new LinkedHashSet<>();
        if (answer != null) {
            acceptedAnswers.add(answer);
            acceptedAnswers.addAll(parseAlternativeAnswers(item.getAlternativeAnswers()));
        }
        return new ExamAnswerKey(item.getQuestionNo(), item.getSubjectNo(), answer, Set.copyOf(acceptedAnswers),
                isOperatorAnswerUsed);
    }

    /** 득표 1위 보기 (득표 없으면 null, 동률이면 낮은 번호) */
    public static Integer findLeadingChoice(int[] voteCountByChoice) {
        Integer leadingChoice = null;
        int leadingVoteCount = 0;
        for (int choice = 1; choice <= CHOICE_COUNT; choice++) {
            if (voteCountByChoice[choice] > leadingVoteCount) {
                leadingChoice = choice;
                leadingVoteCount = voteCountByChoice[choice];
            }
        }
        return leadingChoice;
    }

    /** 합의율 0~1 = 표시용 정답 득표 / 전체 득표 (득표·정답 없으면 0) */
    public static double calculateAgreementRate(Integer answer, int[] voteCountByChoice) {
        int voteCount = sumVotes(voteCountByChoice);
        if (answer == null || voteCount == 0) {
            return 0;
        }
        return Math.round(voteCountByChoice[answer] * 1000.0 / voteCount) / 1000.0;
    }

    public static int sumVotes(int[] voteCountByChoice) {
        int voteCount = 0;
        for (int choice = 1; choice <= CHOICE_COUNT; choice++) {
            voteCount += voteCountByChoice[choice];
        }
        return voteCount;
    }

    /** "2,3" > [2, 3] (1~4 밖·숫자 아닌 값은 무시) */
    public static List<Integer> parseAlternativeAnswers(String alternativeAnswers) {
        if (alternativeAnswers == null || alternativeAnswers.isBlank()) {
            return List.of();
        }
        Set<Integer> parsedAnswers = new LinkedHashSet<>();
        for (String token : alternativeAnswers.split(ALTERNATIVE_ANSWER_DELIMITER)) {
            String trimmedToken = token.trim();
            if (trimmedToken.length() == 1 && Character.isDigit(trimmedToken.charAt(0))) {
                int choice = trimmedToken.charAt(0) - '0';
                if (isValidChoice(choice)) {
                    parsedAnswers.add(choice);
                }
            }
        }
        return List.copyOf(parsedAnswers);
    }

    public static boolean isValidChoice(Integer choice) {
        return choice != null && choice >= 1 && choice <= CHOICE_COUNT;
    }
}
