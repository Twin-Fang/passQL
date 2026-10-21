/**
 * 문제 목록 화면: 대량 JSON 가이드 모달(AI 변환 프롬프트 복사), 단건 비활성화 모달
 */
// ── 대량 JSON 가이드 모달 ────────────────────────────────────
const BULK_AI_PROMPT = `당신은 SQLD 문제를 passQL 대량 JSON 배열 명세로 변환하는 전문가입니다.
아래 규칙을 엄격히 따라 JSON 배열 코드블록 하나만 출력하세요.
설명, 주석, 마크다운 없이 오직 JSON 배열만 출력합니다.

=== 출력 형식 ===
반드시 JSON 배열: [{...}, {...}, ...]
questionUuid는 포함하지 않음 (신규 등록용)

=== stem 작성 핵심 규칙 ===
stem에는 질문 문장만 작성한다. 선택지(①②③④, 1. 2. 3. 4., A B C D)는 절대 포함하지 않는다.
AI가 stem을 읽고 선택지를 동적으로 생성하므로, 선택지가 stem에 있으면 중복 문제가 발생한다.

나쁜 예: "다음 설명 중 맞는 것은?\\n1. 테이블은 하나만 존재한다.\\n2. 데이터는 파일에 저장된다."
좋은 예 (CONCEPT_ONLY): "엔터티(Entity)의 특성에 대한 설명 중 옳지 않은 것은?"
좋은 예 (EXECUTABLE AI_ONLY): "다음 SQL의 실행 결과로 올바른 것은?\\n\\nSELECT * FROM TAB WHERE COL IS NULL;"
좋은 예 (EXECUTABLE ODD_ONE_OUT): "다음 중 SQL 실행 결과가 나머지와 다른 것은?\\n\\n테이블: PLAYER (TEAM VARCHAR, WEIGHT INT)"

=== EXECUTABLE 필드 규칙 ===

choiceSetPolicy 선택:
  "AI_ONLY"     → "다음 SQL의 실행 결과로 올바른 것은?" 유형
                   stem에 SQL 포함 / answerSql = stem의 SQL과 동일한 쿼리 (한 줄)
  "ODD_ONE_OUT" → "다음 중 SQL 실행 결과가 다른 것은?" 유형
                   stem에 SQL 미포함, 테이블·조건만 설명
                   answerSql = 나머지 3개와 다른 결과를 내는 SQL (소수 쪽)

schemaDdl 작성:
  - MariaDB 호환 필수: ROWNUM→LIMIT, VARCHAR2→VARCHAR, NUMBER→INT, DUAL 사용 금지
  - 부모 테이블 먼저 생성 (FK 순서)
  - 문제에서 쓰는 컬럼만 포함
  - 줄바꿈은 \\n
  - [테이블 이름] 각 문제는 독립 Sandbox(격리 DB)에서 실행되므로 시험 회차/번호를 테이블명에 포함하지 않는다
    나쁜 예: SQLD_14, SQLD46_01_EMP / 좋은 예: EMP, DEPT, T1, T2, TAB_A

schemaSampleData 작성:
  - answerSql 실행 시 의미 있는 결과가 나오는 최소 INSERT 문
  - NULL 포함 문제 → NULL 행 필수
  - OUTER JOIN 문제 → 매칭 안 되는 행 필수
  - ODD_ONE_OUT → 조건 분기가 명확히 나뉘는 데이터

answerSql 작성:
  - SELECT 문만, 한 줄로 작성
  - AI_ONLY: stem의 SQL 그대로 복사
  - ODD_ONE_OUT: 나머지와 다른 결과를 내는 SQL

=== 공통 필드 규칙 ===

topicCode: data_modeling | sql_basic_select | sql_ddl_dml_tcl | sql_function |
           sql_join | sql_subquery | sql_group_aggregate | sql_window | sql_hierarchy_pivot

difficulty: 1=개념 암기, 2=단순 SQL, 3=실행 추적, 4=복합 JOIN/서브쿼리, 5=윈도우/계층/PIVOT

executionMode:
  "EXECUTABLE"   → SQL 실행 결과를 묻는 문제
  "CONCEPT_ONLY" → 개념·이론·용어 문제. 모든 스키마 필드 null.

hint: 핵심 개념 또는 함정 포인트 한 줄. 없으면 null.
schemaDisplay: "테이블명 (컬럼명, ...)" 형태. CONCEPT_ONLY면 null.
schemaIntent: 스키마가 테스트하는 개념 한 줄. CONCEPT_ONLY면 null.

=== 날카로운 문제 기준 (2026 경향: 결과 추적형, 두 보기 사이에서 헷갈리는 함정) ===
1. 개념 2~3개를 결합한다 (예: NULL + 집계 + GROUP BY, 외부 조인 + WHERE 조건 위치).
2. 오답 3개는 각자 다른 "학습자가 실제로 하는 착각" 하나씩에서 만든다. 같은 착각을 두 번 쓰지 않는다.
3. 바로 지워지는 오답 금지: 데이터상 나올 수 없는 결과(행이 있는데 0행, 표에 없는 값, 열 개수가 다른 표),
   오류 문제가 아닌데 문법부터 틀린 SQL.
4. 정답과 가장 헷갈리는 오답 1개는 정답과 한 행 또는 한 값만 다르게 만든다.
5. 보기끼리 내용이 같으면 안 된다 (서버 가져오기·생성 검증이 거부).
6. 숫자 보기는 오름차순, 보기 길이는 비슷하게, 정답 위치(A~D)는 묶음 안에서 고르게.
7. 샘플 데이터에는 함정이 드러나는 행을 반드시 넣는다: NULL, 동점, 조인 짝이 없는 행, 중복 값 중 해당되는 것.
8. 지문에 표를 보여줄 때는 마크다운 표(| 열 | 열 | 다음 줄 | --- | --- |)를 쓴다. NULL 칸은 NULL 로 적는다.
9. difficulty 는 1~5 (결합 개념 수와 추적 단계 수로 정한다).
10. hint 에 정답이나 정답 결과를 적지 않는다. 함정이 어디 있는지만 가리킨다.

=== 변환할 문제들 ===

[여기에 SQLD 문제들 붙여넣기]`;

function openBulkGuideModal() {
    document.getElementById('bulkGuidePromptText').value = BULK_AI_PROMPT;
    document.getElementById('bulkGuideModal').showModal();
    lucide.createIcons();
}

function copyBulkPrompt() {
    const btn = document.getElementById('copyBulkPromptBtn');
    const icon = document.getElementById('copyBulkPromptIcon');
    const label = document.getElementById('copyBulkPromptLabel');

    function onCopied() {
        // 버튼을 초록색 체크 아이콘으로 전환
        btn.classList.add('btn-success', 'text-success-content');
        btn.classList.remove('btn-ghost');
        icon.setAttribute('data-lucide', 'check');
        label.textContent = '복사됨';
        lucide.createIcons();

        setTimeout(() => {
            // 원래 상태로 복구
            btn.classList.remove('btn-success', 'text-success-content');
            btn.classList.add('btn-ghost');
            icon.setAttribute('data-lucide', 'copy');
            label.textContent = 'AI 프롬프트 복사';
            lucide.createIcons();
        }, 2000);
    }

    navigator.clipboard.writeText(BULK_AI_PROMPT).then(onCopied).catch(() => {
        const ta = document.getElementById('bulkGuidePromptText');
        ta.select();
        document.execCommand('copy');
        onCopied();
    });
}

function openDeleteModal(btn) {
    const uuid = btn.dataset.uuid;
    const title = btn.dataset.title || '(제목 없음)';
    document.getElementById('deleteTargetTitle').textContent = title;
    const form = document.getElementById('deleteForm');
    form.action = '/admin/questions/' + uuid;
    document.getElementById('deleteModal').showModal();
}
