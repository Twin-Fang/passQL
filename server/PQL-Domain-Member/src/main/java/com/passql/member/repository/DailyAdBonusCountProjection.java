package com.passql.member.repository;

import java.time.LocalDate;

/** 날짜별 광고 보너스 횟수 (GROUP BY 조회 결과 한 행) */
public interface DailyAdBonusCountProjection {

    LocalDate getBonusDate();

    long getAdBonusCount();
}
