package com.passql.web.notification;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.dto.AppNoticePageResponse;
import com.passql.meta.dto.AppNoticeResponse;
import com.passql.meta.dto.AppNoticeSaveRequest;
import com.passql.meta.service.AppNoticeService;
import com.passql.web.PassqlApplication;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * 공지 목록·상세 쿼리 (실제 dev DB, 테스트 끝에 롤백, #529)
 * 지난 공지 포함, 노출 전·비활성 제외, 노출 중 중요 먼저 > 게시 최신 순
 */
@SpringBootTest(classes = PassqlApplication.class)
@ActiveProfiles("dev")
@Transactional
class PublishedNoticeQueryIntegrationTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    @Autowired AppNoticeService appNoticeService;
    @Autowired EntityManager entityManager;

    private UUID create(String title, LocalDateTime startsAt, LocalDateTime endsAt, boolean isActive, boolean isImportant) {
        return appNoticeService.createNotice(
                new AppNoticeSaveRequest(title, "본문", startsAt, endsAt, isActive, isImportant)).noticeUuid();
    }

    /** 모든 페이지를 이어 붙인 공지 uuid 목록 (페이지 경계 중복 없음 확인용) */
    private List<UUID> readAllPublishedUuids() {
        List<UUID> uuids = new ArrayList<>();
        int page = 0;
        AppNoticePageResponse current;
        do {
            current = appNoticeService.getPublishedNotices(page++, 7);
            current.notices().stream().map(AppNoticeResponse::noticeUuid).forEach(uuids::add);
        } while (current.hasNextPage());
        return uuids;
    }

    @Test
    void 목록은_지난_공지를_포함하고_노출_전_비활성은_뺀다() {
        LocalDateTime now = LocalDateTime.now(KST).withNano(0);
        UUID expired = create("지난 공지", now.minusDays(30), now.minusDays(20), true, false);
        UUID future = create("예약 공지", now.plusDays(1), null, true, false);
        UUID inactive = create("비활성 공지", null, null, false, false);
        entityManager.flush();

        List<UUID> uuids = readAllPublishedUuids();

        assertThat(uuids).contains(expired).doesNotContain(future, inactive);
        assertThat(uuids).doesNotHaveDuplicates();
    }

    @Test
    void 노출_중_중요_공지가_먼저_그다음_게시_최신_순() {
        LocalDateTime now = LocalDateTime.now(KST).withNano(0);
        UUID older = create("오래된 공지", now.minusDays(10), null, true, false);
        UUID recent = create("최근 공지", now.minusDays(1), null, true, false);
        UUID importantOld = create("중요 공지", now.minusDays(40), null, true, true);
        // 노출이 끝난 중요 공지는 맨 앞에 고정하지 않음
        UUID expiredImportant = create("끝난 중요 공지", now.minusDays(9), now.minusDays(5), true, true);
        entityManager.flush();

        List<UUID> uuids = readAllPublishedUuids();

        assertThat(uuids.indexOf(importantOld)).isLessThan(uuids.indexOf(recent));
        assertThat(uuids.indexOf(recent)).isLessThan(uuids.indexOf(expiredImportant));
        assertThat(uuids.indexOf(expiredImportant)).isLessThan(uuids.indexOf(older));
    }

    @Test
    void 상세는_지난_공지를_돌려주고_노출_전_공지는_APP_NOTICE_NOT_FOUND() {
        LocalDateTime now = LocalDateTime.now(KST).withNano(0);
        UUID expired = create("지난 공지", now.minusDays(30), now.minusDays(20), true, false);
        UUID future = create("예약 공지", now.plusDays(1), null, true, false);
        entityManager.flush();

        AppNoticeResponse detail = appNoticeService.getPublishedNotice(expired);

        assertThat(detail.publishedAt()).isEqualTo(now.minusDays(30));
        assertThatThrownBy(() -> appNoticeService.getPublishedNotice(future))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.APP_NOTICE_NOT_FOUND);
    }
}
