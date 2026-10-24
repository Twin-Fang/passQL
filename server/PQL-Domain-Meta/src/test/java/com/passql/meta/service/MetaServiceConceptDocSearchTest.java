package com.passql.meta.service;

import com.passql.meta.constant.ConceptDocSortType;
import com.passql.meta.entity.ConceptDoc;
import com.passql.meta.entity.ConceptTag;
import com.passql.meta.repository.ConceptDocRepository;
import com.passql.meta.repository.ConceptTagRepository;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 개념 문서 검색·정렬 (#618): 제목·본문 부분 일치, 태그 미지정은 검색어가 있을 때만 전체 검색 */
class MetaServiceConceptDocSearchTest {

    private final ConceptTagRepository conceptTagRepository = mock(ConceptTagRepository.class);
    private final ConceptDocRepository conceptDocRepository = mock(ConceptDocRepository.class);
    private final MetaService metaService = new MetaService(mock(TopicRepository.class), mock(SubtopicRepository.class),
            conceptTagRepository, conceptDocRepository, event -> { });

    private ConceptDoc newDoc(String title, String bodyMd, LocalDateTime updatedAt) {
        ConceptDoc doc = ConceptDoc.builder().conceptDocUuid(UUID.randomUUID()).title(title).bodyMd(bodyMd).build();
        // 감사 시각은 JPA 가 채우는 값이라 리플렉션으로 설정
        ReflectionTestUtils.setField(doc, "updatedAt", updatedAt);
        return doc;
    }

    @Test
    void 태그_지정_시_검색어는_제목과_본문을_대소문자_무시로_거르고_정렬한다() {
        ConceptTag tag = ConceptTag.builder().conceptTagUuid(UUID.randomUUID()).tagKey("group_by").build();
        ConceptDoc oldDoc = newDoc("GROUP BY 기본", "집계 설명", LocalDateTime.of(2026, 1, 1, 0, 0));
        ConceptDoc newDoc = newDoc("집계 응용", "group by having", LocalDateTime.of(2026, 6, 1, 0, 0));
        ConceptDoc otherDoc = newDoc("JOIN", "조인", LocalDateTime.of(2026, 3, 1, 0, 0));
        when(conceptTagRepository.findByTagKey("group_by")).thenReturn(Optional.of(tag));
        when(conceptDocRepository.findByConceptTagUuid(tag.getConceptTagUuid())).thenReturn(List.of(oldDoc, otherDoc, newDoc));

        assertThat(metaService.searchDocs("group_by", "Group By", ConceptDocSortType.RECENTLY_UPDATED))
                .containsExactly(newDoc, oldDoc);
        assertThat(metaService.searchDocs("group_by", "Group By", ConceptDocSortType.OLDEST_UPDATED))
                .containsExactly(oldDoc, newDoc);
        assertThat(metaService.searchDocs("group_by", null, ConceptDocSortType.TITLE_ASCENDING))
                .containsExactly(oldDoc, otherDoc, newDoc);
    }

    @Test
    void 태그도_검색어도_없으면_빈_목록이고_검색어만_있으면_전체_문서에서_찾는다() {
        ConceptDoc doc = newDoc("윈도우 함수", "RANK", LocalDateTime.now());
        when(conceptDocRepository.findAll()).thenReturn(List.of(doc));

        assertThat(metaService.searchDocs(null, " ", ConceptDocSortType.RECENTLY_UPDATED)).isEmpty();
        assertThat(metaService.searchDocs(null, "rank", ConceptDocSortType.RECENTLY_UPDATED)).containsExactly(doc);
    }
}
