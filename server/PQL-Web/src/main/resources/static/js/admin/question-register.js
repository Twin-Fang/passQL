/**
 * 문제 직접 등록 화면: 실행 모드별 스키마 입력 전환, 등록 가이드 모달, 샌드박스 실행 테스트
 */
initQuestionJsonLoader({ confirmOverwrite: false });

// 실행 모드 전환 시 스키마 섹션 표시/숨김
document.querySelectorAll('input[name="executionMode"]').forEach(radio => {
    radio.addEventListener('change', function () {
        const schemaSection = document.getElementById('schemaSection');
        if (this.value === 'EXECUTABLE') {
            schemaSection.classList.remove('hidden');
            document.getElementById('schemaDdl').required = true;
            document.getElementById('answerSql').required = true;
        } else {
            schemaSection.classList.add('hidden');
            document.getElementById('schemaDdl').required = false;
            document.getElementById('answerSql').required = false;
        }
    });
});

// ── 가이드 모달 ────────────────────────────────────────────────
const AI_PROMPT = `당신은 SQLD 문제를 passQL JSON 명세로 변환하는 전문가입니다.
아래 규칙을 엄격히 따라 JSON 코드블록 하나만 출력하세요. 설명, 주석, 마크다운 없이 JSON만.

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

=== 변환할 문제 ===

[여기에 SQLD 문제 붙여넣기]`;

function openGuideModal() {
    document.getElementById('guidePromptText').value = AI_PROMPT;
    document.getElementById('copySuccessMsg').classList.add('hidden');
    document.getElementById('guideModal').showModal();
    lucide.createIcons();
}

function copyPrompt() {
    navigator.clipboard.writeText(AI_PROMPT).then(() => {
        const msg = document.getElementById('copySuccessMsg');
        msg.classList.remove('hidden');
        setTimeout(() => msg.classList.add('hidden'), 2000);
    }).catch(() => {
        const ta = document.getElementById('guidePromptText');
        ta.select();
        document.execCommand('copy');
    });
}

// ── Sandbox 실행 테스트 ─────────────────────────────────────────
async function testSandbox() {
    const ddl = document.getElementById('schemaDdl').value.trim();
    const sampleData = document.getElementById('schemaSampleData').value.trim();
    const sql = document.getElementById('answerSql').value.trim();

    if (!ddl) { AdminUi.toast('DDL을 입력해주세요.', 'warning'); return; }
    if (!sql) { AdminUi.toast('정답 SQL을 입력해주세요.', 'warning'); return; }

    const statusEl = document.getElementById('sandboxStatus');
    const resultEl = document.getElementById('sandboxResult');
    const outputEl = document.getElementById('sandboxOutput');

    statusEl.textContent = '실행 중...';
    resultEl.classList.add('hidden');

    try {
        const data = await AdminApi.post('/admin/sandbox/execute', { ddl, sampleData, sql });

        if (data.status === 'OK') {
            statusEl.textContent = '✓ 성공 (' + data.elapsedMs + 'ms, ' + data.rowCount + '행)';
            statusEl.className = 'text-sm text-success font-medium';
            const header = (data.columns || []).join(' | ');
            const rows = (data.rows || []).map(r => r.join(' | ')).join('\n');
            const pre = document.createElement('pre');
            pre.className = 'p-4';
            pre.textContent = header + '\n' + '-'.repeat(header.length) + '\n' + rows;
            outputEl.replaceChildren(pre);
        } else {
            statusEl.textContent = '✗ ' + (data.errorCode || 'ERROR');
            statusEl.className = 'text-sm text-error font-medium';
            const pre = document.createElement('pre');
            pre.className = 'p-4';
            pre.textContent = data.errorMessage || '';
            outputEl.replaceChildren(pre);
        }
        resultEl.classList.remove('hidden');
    } catch (error) {
        statusEl.textContent = '요청 실패: ' + error.message;
        statusEl.className = 'text-sm text-error font-medium';
    }
}
