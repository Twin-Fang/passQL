package com.passql.submission.service;

import java.util.Set;

/**
 * 문항 1개 채점 기준: 표시용 정답·인정 보기·확정 여부
 * isDetermined false (UNKNOWN·DISPUTED·운영 답 없음) > 점수 범위에서 틀림/맞음 둘 다 가정
 *
 * @param answer          표시용 정답 1~4 (없으면 null)
 * @param acceptedAnswers 정답 인정 보기 (표시용 정답 + 복수 정답, 정답 없으면 빈 집합)
 */
public record ExamAnswerKey(int questionNo, int subjectNo, Integer answer, Set<Integer> acceptedAnswers,
                            boolean isDetermined) {

    /** 내 답(0 모름, 1~4)이 인정 보기에 드는지 */
    public boolean isAccepted(int myAnswer) {
        return myAnswer != 0 && acceptedAnswers.contains(myAnswer);
    }
}
