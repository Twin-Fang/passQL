package com.passql.web.architecture;

import com.passql.question.dto.SseErrorEvent;
import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.core.importer.ImportOption;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Stream;

import static com.tngtech.archunit.core.domain.JavaClass.Predicates.resideInAPackage;
import static com.tngtech.archunit.core.domain.JavaClass.Predicates.simpleNameEndingWith;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noMethods;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * 서버 구조 규칙 강제: 표현 계층 Repository 의존 금지, 컨트롤러 인프라(Client·Executor·Pool) 의존 금지, 컨트롤러 트랜잭션 금지, 오류 응답은 ErrorCode 경유만
 * 예외는 각 allow-list 에만 (이유 주석 필수)
 */
class ArchitectureRuleTest {

    // 표현 계층: 요청 진입점·기동 작업·스케줄러
    private static final String[] PRESENTATION_PACKAGES = {
            "com.passql.web.controller..",
            "com.passql.web.init..",
            "com.passql.web.scheduler.."
    };

    // Repository 직접 의존 허용 클래스 (현재 없음, 추가 시 이유 주석 필수)
    private static final Set<String> REPOSITORY_ACCESS_ALLOW_LIST = Set.of();

    // 컨트롤러 인프라(외부 호출 Client·샌드박스 Executor·Pool) 직접 의존 허용 클래스 (현재 없음, 추가 시 이유 주석 필수)
    private static final Set<String> INFRASTRUCTURE_ACCESS_ALLOW_LIST = Set.of();

    // 알림 저장소(member_notification, member_notice_read) 직접 사용 허용 클래스: 알림 생성·조회 서비스 2개만 (#491)
    private static final Set<String> NOTIFICATION_REPOSITORY_ACCESS_ALLOW_LIST = Set.of(
            "com.passql.application.notification.MemberNotificationService",
            "com.passql.application.notification.MemberNotificationQueryService");

    // 서버 모듈 루트 (Gradle 테스트 작업 디렉터리 = PQL-Web)
    private static final Path SERVER_ROOT = Paths.get("..").toAbsolutePath().normalize();

    // 오류 응답 우회 패턴 > 금지 이유
    private static final Map<Pattern, String> FORBIDDEN_ERROR_RESPONSE_PATTERNS = Map.of(
            Pattern.compile("Map\\.of\\(\\s*\"error\""), "Map 오류 본문 대신 CustomException(ErrorCode)",
            Pattern.compile("\\.errorCode\\(\\s*\""), "문자열 오류 코드 대신 ErrorCode enum",
            Pattern.compile("put\\(\\s*\"errorCode\"\\s*,\\s*\""), "문자열 오류 코드 대신 ErrorCode enum",
            Pattern.compile("ResponseEntity\\s*\\.\\s*status\\(\\s*[45]\\d\\d\\s*\\)"), "숫자 상태 코드 대신 CustomException(ErrorCode)",
            Pattern.compile("ResponseEntity\\s*\\.\\s*(badRequest|notFound|internalServerError|unprocessableEntity)\\(\\)"),
            "본문 없는 오류 응답 대신 CustomException(ErrorCode)"
    );

    // 소스 스캔 예외 파일 (서버 상대 경로, 현재 없음, 추가 시 이유 주석 필수)
    private static final Set<String> ERROR_RESPONSE_SCAN_ALLOW_LIST = Set.of();

    private static JavaClasses productionClasses;

    @BeforeAll
    static void importProductionClasses() {
        productionClasses = new ClassFileImporter()
                .withImportOption(ImportOption.Predefined.DO_NOT_INCLUDE_TESTS)
                .importPackages("com.passql");
    }

    @Test
    void 표현_계층은_Repository에_의존하지_않는다() {
        noClasses().that().resideInAnyPackage(PRESENTATION_PACKAGES)
                .and().haveNameNotMatching(toAlternation(REPOSITORY_ACCESS_ALLOW_LIST))
                .should().dependOnClassesThat().resideInAPackage("..repository..")
                .because("컨트롤러·초기화·스케줄러는 Service 를 거쳐야 함 (server/CLAUDE.md Controller 역할 제한)")
                .check(productionClasses);
    }

    @Test
    void 컨트롤러는_Client_Executor_Pool에_직접_의존하지_않는다() {
        noClasses().that().resideInAPackage("com.passql.web.controller..")
                .and().haveNameNotMatching(toAlternation(INFRASTRUCTURE_ACCESS_ALLOW_LIST))
                .should().dependOnClassesThat(resideInAPackage("com.passql..").and(
                        simpleNameEndingWith("Client")
                                .or(simpleNameEndingWith("Executor"))
                                .or(simpleNameEndingWith("Pool"))))
                .because("외부 호출·샌드박스 실행은 Service 를 거쳐야 함 (server/CLAUDE.md Controller 역할 제한)")
                .check(productionClasses);
    }

    @Test
    void 알림_저장소는_알림_서비스_2개만_사용한다() {
        noClasses().that().haveNameNotMatching(toAlternation(NOTIFICATION_REPOSITORY_ACCESS_ALLOW_LIST))
                .should().dependOnClassesThat().haveFullyQualifiedName("com.passql.member.repository.MemberNotificationRepository")
                .orShould().dependOnClassesThat().haveFullyQualifiedName("com.passql.member.repository.MemberNoticeReadRepository")
                .because("알림 생성은 MemberNotificationService, 조회·읽음은 MemberNotificationQueryService 로만 (캐시 삭제·푸시 전달 누락 방지)")
                .check(productionClasses);
    }

    @Test
    void 컨트롤러에는_Transactional을_두지_않는다() {
        noClasses().that().resideInAPackage("com.passql.web.controller..")
                .should().beAnnotatedWith(Transactional.class)
                .check(productionClasses);
        noMethods().that().areDeclaredInClassesThat().resideInAPackage("com.passql.web.controller..")
                .should().beAnnotatedWith(Transactional.class)
                .check(productionClasses);
    }

    @Test
    void SSE_오류_이벤트는_ErrorCode_팩토리로만_만든다() {
        noClasses().that().doNotHaveFullyQualifiedName(SseErrorEvent.class.getName())
                .should().callConstructor(SseErrorEvent.class, String.class, String.class, String.class, boolean.class)
                .because("errorCode·code 를 ErrorCode 하나에서 채우기 위해 SseErrorEvent.of 만 사용")
                .check(productionClasses);
    }

    @Test
    void 오류_응답은_문자열_코드나_임의_본문으로_만들지_않는다() throws IOException {
        List<String> violations = new ArrayList<>();
        for (Path sourceFile : findMainJavaSources()) {
            String relativePath = SERVER_ROOT.relativize(sourceFile).toString();
            if (ERROR_RESPONSE_SCAN_ALLOW_LIST.contains(relativePath)) {
                continue;
            }
            String source = Files.readString(sourceFile);
            FORBIDDEN_ERROR_RESPONSE_PATTERNS.forEach((pattern, reason) -> {
                if (pattern.matcher(source).find()) {
                    violations.add(relativePath + " : " + reason);
                }
            });
        }
        assertThat(violations).as("오류 응답 우회").isEmpty();
    }

    /** server/{모듈}/src/main/java 아래 .java 전체 */
    private static List<Path> findMainJavaSources() throws IOException {
        try (Stream<Path> paths = Files.walk(SERVER_ROOT)) {
            return paths
                    .filter(path -> path.toString().endsWith(".java"))
                    .filter(path -> path.toString().contains("/src/main/java/"))
                    .filter(path -> !path.toString().contains("/build/"))
                    .toList();
        }
    }

    /** 클래스 이름 목록 > 정규식 (빈 목록이면 아무것도 맞지 않는 식) */
    private static String toAlternation(Set<String> classNames) {
        if (classNames.isEmpty()) {
            return "(?!)";
        }
        return String.join("|", classNames.stream().map(Pattern::quote).toList());
    }
}
