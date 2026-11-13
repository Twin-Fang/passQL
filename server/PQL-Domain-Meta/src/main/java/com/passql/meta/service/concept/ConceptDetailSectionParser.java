package com.passql.meta.service.concept;

import com.passql.meta.dto.concept.ConceptDetailSection;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 자세히 본문 > 문단 목록: "## 제목 {#앵커}" 줄로 나눔 (코드 블록 안 줄은 제외)
 * 형식 위반 3개(앵커 없는 제목, 앵커 중복, 첫 제목 앞 글) > 사유 문자열 (줄 번호 포함, 관리자 화면 표시용)
 */
@Component
public class ConceptDetailSectionParser {

    // 문단 제목 줄: "## 제목 {#anchor}" (앵커는 소문자·숫자·하이픈 1~80자)
    private static final Pattern SECTION_HEADING = Pattern.compile("^## (.+?) \\{#([a-z0-9-]{1,80})\\}\\s*$");
    // 제목처럼 보이는 줄 (앵커 누락 검출용)
    private static final String HEADING_PREFIX = "## ";
    // 코드 펜스 시작·끝
    private static final String CODE_FENCE = "```";

    /** 자세히 본문 > 문단 목록 (등장 순서), 형식 위반이면 IllegalArgumentException */
    public List<ConceptDetailSection> parse(String detailMd) {
        SectionScanResult scanResult = scan(detailMd);
        if (scanResult.violationReason() != null) {
            throw new IllegalArgumentException(scanResult.violationReason());
        }
        return scanResult.sections();
    }

    /** 자세히 본문 > 첫 형식 위반 사유 (예: "duplicate anchor 'x' at line 7"), 없으면 empty */
    public Optional<String> findFormatViolation(String detailMd) {
        return Optional.ofNullable(scan(detailMd).violationReason());
    }

    /** 자세히 본문 > 앵커 집합 (등장 순서 유지), 형식 위반이면 IllegalArgumentException */
    public Set<String> findAnchors(String detailMd) {
        Set<String> anchors = new LinkedHashSet<>();
        parse(detailMd).forEach(section -> anchors.add(section.anchor()));
        return anchors;
    }

    /** 줄 단위 훑기: 문단 목록 + 첫 위반 사유 (위반을 만나면 즉시 중단) */
    private SectionScanResult scan(String detailMd) {
        List<ConceptDetailSection> sections = new ArrayList<>();
        Set<String> seenAnchors = new LinkedHashSet<>();
        String currentAnchor = null;
        String currentTitle = null;
        StringBuilder currentBody = new StringBuilder();
        boolean isInsideCodeFence = false;

        String[] lines = detailMd == null ? new String[0] : detailMd.split("\n", -1);
        for (int index = 0; index < lines.length; index++) {
            String line = lines[index];
            int lineNumber = index + 1;

            // 코드 블록 안은 본문 그대로
            if (line.trim().startsWith(CODE_FENCE)) {
                isInsideCodeFence = !isInsideCodeFence;
            }
            boolean isHeadingCandidate = !isInsideCodeFence && line.startsWith(HEADING_PREFIX);
            if (!isHeadingCandidate) {
                if (currentAnchor == null && !line.isBlank()) {
                    return SectionScanResult.violation("text before first section at line " + lineNumber);
                }
                currentBody.append(line).append('\n');
                continue;
            }

            // 새 문단 시작 (앵커 형식·중복 검사)
            Matcher matcher = SECTION_HEADING.matcher(line);
            if (!matcher.matches()) {
                return SectionScanResult.violation("section heading without anchor at line " + lineNumber);
            }
            String anchor = matcher.group(2);
            if (!seenAnchors.add(anchor)) {
                return SectionScanResult.violation("duplicate anchor '" + anchor + "' at line " + lineNumber);
            }
            if (currentAnchor != null) {
                sections.add(new ConceptDetailSection(currentAnchor, currentTitle, currentBody.toString().strip()));
            }
            currentAnchor = anchor;
            currentTitle = matcher.group(1).strip();
            currentBody = new StringBuilder();
        }

        if (currentAnchor != null) {
            sections.add(new ConceptDetailSection(currentAnchor, currentTitle, currentBody.toString().strip()));
        }
        return new SectionScanResult(sections, null);
    }

    /** 훑기 결과: 위반 없으면 violationReason null */
    private record SectionScanResult(List<ConceptDetailSection> sections, String violationReason) {

        static SectionScanResult violation(String violationReason) {
            return new SectionScanResult(List.of(), violationReason);
        }
    }
}
