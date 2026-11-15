package com.passql.meta.service;

import com.passql.meta.dto.SqldExamGuideResponse.CertificationComparison;
import com.passql.meta.dto.SqldExamGuideResponse.Faq;
import com.passql.meta.dto.SqldExamGuideResponse.RoundNote;
import com.passql.meta.dto.SqldExamGuideResponse.Source;
import com.passql.meta.dto.SqldExamGuideResponse.Subject;
import com.passql.meta.dto.SqldExamGuideResponse.YearlyStatistic;

import java.util.List;

/**
 * SQLD 알아보기 원본 (resources exam-guide/sqld-exam-guide.json) 모양
 * 인사이트는 원본에 두지 않음 (SqldExamGuideService 가 통계에서 계산)
 */
record SqldExamGuideContent(
        String oneLineDefinition,
        String organizerName,
        String certificationNumber,
        List<String> recommendedFor,
        List<Subject> subjects,
        int examDurationMinutes,
        int passingTotalScore,
        int failingSubjectPercent,
        int examFeeWon,
        String validityDescription,
        List<Faq> faqs,
        List<YearlyStatistic> yearlyStatistics,
        List<RoundNote> roundNotes,
        List<CertificationComparison> comparisons,
        List<Source> sources
) {}
