package com.passql.application.notification;

import com.passql.member.dto.NotificationPreferenceResponse;
import com.passql.member.dto.NotificationPreferenceUpdateRequest;
import com.passql.member.entity.MemberNotificationPreference;
import com.passql.member.repository.MemberNotificationPreferenceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/** 회원 본인의 자동 알림 수신 설정 조회·변경 (행이 없으면 전부 수신, 변경 때 처음 만듦) */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberNotificationPreferenceService {

    private final MemberNotificationPreferenceRepository memberNotificationPreferenceRepository;

    public NotificationPreferenceResponse getPreference(UUID memberUuid) {
        return memberNotificationPreferenceRepository.findById(memberUuid)
                .map(NotificationPreferenceResponse::from)
                .orElseGet(NotificationPreferenceResponse::allEnabled);
    }

    /** 변경: 행 조회·생성 > 넘어온 항목만 반영 > 변경 후 설정 반환 */
    @Transactional
    public NotificationPreferenceResponse updatePreference(UUID memberUuid, NotificationPreferenceUpdateRequest request) {
        MemberNotificationPreference preference = memberNotificationPreferenceRepository.findById(memberUuid)
                .orElseGet(() -> memberNotificationPreferenceRepository.save(MemberNotificationPreference.ofDefault(memberUuid)));
        preference.update(request.isStudyReminderEnabled(), request.isComebackEnabled(), request.isExamCountdownEnabled());
        log.info("[notification preference] updated : study={}, comeback={}, exam={}",
                preference.getIsStudyReminderEnabled(), preference.getIsComebackEnabled(), preference.getIsExamCountdownEnabled());
        return NotificationPreferenceResponse.from(preference);
    }
}
