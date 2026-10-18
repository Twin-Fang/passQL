package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.dto.AppNoticePageResponse;
import com.passql.meta.dto.AppNoticeResponse;
import com.passql.meta.entity.AppNotice;
import com.passql.meta.repository.AppNoticeRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 공지 목록·상세: 게시 시각 계산, 페이지 크기 보정, 다음 페이지 유무, 안 보이는 공지 404 (#529) */
class AppNoticeServiceTest {

    private static final LocalDateTime CREATED_AT = LocalDateTime.of(2026, 10, 1, 9, 30);
    private static final LocalDateTime STARTS_AT = LocalDateTime.of(2026, 10, 5, 0, 0);

    private AppNoticeRepository appNoticeRepository;
    private AppNoticeService service;

    @BeforeEach
    void setUp() {
        appNoticeRepository = mock(AppNoticeRepository.class);
        service = new AppNoticeService(appNoticeRepository, mock(ApplicationEventPublisher.class));
    }

    private static AppNotice notice(String title, LocalDateTime startsAt) {
        AppNotice notice = AppNotice.builder()
                .appNoticeUuid(UUID.randomUUID())
                .title(title)
                .body("**본문**")
                .startsAt(startsAt)
                .isActive(true)
                .isImportant(false)
                .build();
        ReflectionTestUtils.setField(notice, "createdAt", CREATED_AT);
        return notice;
    }

    @Test
    void 게시_시각은_노출_시작_없으면_등록_시각() {
        AppNoticeResponse scheduled = AppNoticeResponse.from(notice("예약", STARTS_AT));
        AppNoticeResponse immediate = AppNoticeResponse.from(notice("즉시", null));

        assertThat(scheduled.publishedAt()).isEqualTo(STARTS_AT);
        assertThat(immediate.publishedAt()).isEqualTo(CREATED_AT);
    }

    @Test
    void 목록은_페이지_크기를_보정하고_다음_페이지_유무를_돌려준다() {
        Pageable expectedPageable = PageRequest.of(0, AppNoticeService.MAX_PAGE_SIZE);
        when(appNoticeRepository.findPublishedNotices(any(), eq(expectedPageable)))
                .thenReturn(new PageImpl<>(List.of(notice("첫 공지", null)), expectedPageable, 120));

        AppNoticePageResponse page = service.getPublishedNotices(-3, 999);

        assertThat(page.page()).isZero();
        assertThat(page.hasNextPage()).isTrue();
        assertThat(page.notices()).extracting(AppNoticeResponse::title).containsExactly("첫 공지");
    }

    @Test
    void 목록_크기를_비우면_기본_크기로_조회한다() {
        when(appNoticeRepository.findPublishedNotices(any(), any()))
                .thenReturn(new PageImpl<>(List.of(), PageRequest.of(2, AppNoticeService.DEFAULT_PAGE_SIZE), 0));

        AppNoticePageResponse page = service.getPublishedNotices(2, null);

        ArgumentCaptor<Pageable> pageableCaptor = ArgumentCaptor.forClass(Pageable.class);
        verify(appNoticeRepository).findPublishedNotices(any(), pageableCaptor.capture());
        assertThat(pageableCaptor.getValue().getPageSize()).isEqualTo(AppNoticeService.DEFAULT_PAGE_SIZE);
        assertThat(pageableCaptor.getValue().getPageNumber()).isEqualTo(2);
        assertThat(page.hasNextPage()).isFalse();
    }

    @Test
    void 상세는_게시된_공지를_돌려준다() {
        AppNotice published = notice("게시됨", STARTS_AT);
        when(appNoticeRepository.findPublishedNotice(eq(published.getAppNoticeUuid()), any()))
                .thenReturn(Optional.of(published));

        AppNoticeResponse response = service.getPublishedNotice(published.getAppNoticeUuid());

        assertThat(response.title()).isEqualTo("게시됨");
        assertThat(response.publishedAt()).isEqualTo(STARTS_AT);
    }

    @Test
    void 상세는_비활성_노출_전_없는_공지면_APP_NOTICE_NOT_FOUND() {
        when(appNoticeRepository.findPublishedNotice(any(), any())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getPublishedNotice(UUID.randomUUID()))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.APP_NOTICE_NOT_FOUND);
    }
}
