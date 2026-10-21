package com.passql.member.service;

import com.passql.member.repository.MemberActivityHourRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 회원 시간대별 활동 저장 (#557): 별도 단일 스레드 INSERT(요청 지연·실패 전파 없음, 과부하 시 버림), 400일 보관 정리
 * 호출은 MemberActivityRecorder 가 시간당 회원 1회로 거른 뒤
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberActivityHourService {

    // 기록 전용 실행기 이름 (PQL-Web AsyncConfig 가 같은 이름으로 등록)
    public static final String RECORD_EXECUTOR_NAME = "memberActivityExecutor";
    // 보관 기간 (일, 월별 12개월 그래프용)
    public static final int RETENTION_DAYS = 400;

    private final MemberActivityHourRepository memberActivityHourRepository;

    /** 활동 1건 기록 (이미 있으면 무시, 실패는 로그만) */
    @Async(RECORD_EXECUTOR_NAME)
    @Transactional
    public void recordActivityHour(UUID memberUuid, LocalDateTime activityHour) {
        try {
            memberActivityHourRepository.insertIfAbsent(activityHour, memberUuid);
        } catch (Exception e) {
            log.warn("[member activity] record failed : {}", e.getClass().getSimpleName());
        }
    }

    @Transactional
    public int purgeExpired() {
        return memberActivityHourRepository.deleteOlderThan(LocalDateTime.now().minusDays(RETENTION_DAYS));
    }
}
