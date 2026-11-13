package com.passql.application.entitlement;

import java.time.LocalDate;

/**
 * 크레딧 사용 내역 하루치 (크레딧 1개 = 랜덤 풀기 1문제): 받은 수 4종, 쓴 수, 남은 수
 *
 * @param date                      날짜 KST
 * @param baseCredits               하루 기본 크레딧 (지금 기본 한도, 과거 설정값 이력 없음)
 * @param dailySetCompletionCredits 오늘의 세트 완료 보너스로 받은 크레딧 (못 받았으면 0)
 * @param dailySetAccuracyCredits   오늘의 세트 정답 80% 보너스로 받은 크레딧 (못 받았으면 0)
 * @param adBonusCount              광고 보너스 받은 횟수
 * @param adBonusCredits            광고 보너스로 받은 크레딧 (횟수 x 1회분)
 * @param usedCredits               그날 쓴 크레딧 (랜덤 풀기로 제출한 서로 다른 문제 수)
 * @param remainingCredits          남은 크레딧 (받은 합 - 쓴 수, 0 미만은 0, 지난 날짜는 그날이 끝난 시점 값)
 */
public record CreditHistoryDayResponse(
    LocalDate date,
    int baseCredits,
    int dailySetCompletionCredits,
    int dailySetAccuracyCredits,
    int adBonusCount,
    int adBonusCredits,
    int usedCredits,
    int remainingCredits
) {
}
