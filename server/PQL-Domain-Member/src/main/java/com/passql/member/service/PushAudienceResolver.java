package com.passql.member.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.MemberStatus;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushPlatform;
import com.passql.member.dto.PushDevice;
import com.passql.member.entity.MemberPushToken;
import com.passql.member.repository.MemberPushTokenRepository;
import com.passql.member.repository.PushSegmentMemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 푸시 세그먼트 해석: 대상 종류 > 회원 UUID 목록, 회원 목록 > 수신 동의 기기 (플랫폼 제한 가능)
 * 알림함 저장 대상과 푸시 기기 대상이 같은 회원 목록을 쓰도록 한 곳에서만 계산
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PushAudienceResolver {

    // 미접속 일수 허용 범위 (일)
    public static final int MIN_INACTIVE_DAYS = 1;
    public static final int MAX_INACTIVE_DAYS = 365;
    // 회원 IN 조회 한 번에 넘기는 회원 수 (DB 바인딩 파라미터 한도 보호)
    private static final int MEMBER_QUERY_CHUNK_SIZE = 1_000;

    private final PushSegmentMemberRepository pushSegmentMemberRepository;
    private final MemberPushTokenRepository memberPushTokenRepository;

    /** 세그먼트 > 대상 회원 UUID (세그먼트가 아닌 대상은 INVALID_INPUT_VALUE) */
    public List<UUID> resolveMemberUuids(PushAudience audience, Integer inactiveDays) {
        LocalDateTime now = LocalDateTime.now();
        return switch (audience) {
            case PRO_MEMBERS -> pushSegmentMemberRepository.findProMemberUuids(MemberStatus.WITHDRAWN, MemberPlan.PRO, now);
            case FREE_MEMBERS -> pushSegmentMemberRepository.findFreeMemberUuids(MemberStatus.WITHDRAWN, MemberPlan.PRO, now);
            case INACTIVE_MEMBERS -> pushSegmentMemberRepository.findInactiveMemberUuids(
                    MemberStatus.WITHDRAWN, now.minusDays(requireInactiveDays(inactiveDays)));
            case ANDROID_DEVICES -> pushSegmentMemberRepository.findMemberUuidsWithPushDevice(MemberStatus.WITHDRAWN, PushPlatform.ANDROID);
            case IOS_DEVICES -> pushSegmentMemberRepository.findMemberUuidsWithPushDevice(MemberStatus.WITHDRAWN, PushPlatform.IOS);
            default -> throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "audience");
        };
    }

    /** 플랫폼 세그먼트면 그 플랫폼, 아니면 null (기기를 플랫폼으로 제한할지 판단) */
    public PushPlatform findPlatformFilter(PushAudience audience) {
        return switch (audience) {
            case ANDROID_DEVICES -> PushPlatform.ANDROID;
            case IOS_DEVICES -> PushPlatform.IOS;
            default -> null;
        };
    }

    /** 회원 목록의 수신 동의 기기 (platformFilter 가 있으면 그 플랫폼만) */
    public List<PushDevice> findDevices(List<UUID> memberUuids, PushPlatform platformFilter) {
        List<PushDevice> devices = new ArrayList<>();
        for (int start = 0; start < memberUuids.size(); start += MEMBER_QUERY_CHUNK_SIZE) {
            List<UUID> memberChunk = memberUuids.subList(start, Math.min(start + MEMBER_QUERY_CHUNK_SIZE, memberUuids.size()));
            for (MemberPushToken token : memberPushTokenRepository.findAllByMemberUuidInAndIsPushEnabledTrue(memberChunk)) {
                if (platformFilter == null || token.getPlatform() == platformFilter) {
                    devices.add(new PushDevice(token.getMemberUuid(), token.getToken()));
                }
            }
        }
        return devices;
    }

    /** 미접속 일수 검증 (1~365) */
    public static int requireInactiveDays(Integer inactiveDays) {
        if (inactiveDays == null || inactiveDays < MIN_INACTIVE_DAYS || inactiveDays > MAX_INACTIVE_DAYS) {
            throw new CustomException(ErrorCode.PUSH_INACTIVE_DAYS_INVALID);
        }
        return inactiveDays;
    }
}
