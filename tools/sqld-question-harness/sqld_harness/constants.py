"""
하네스 공통 상수: 보기 키, 토픽, 난이도 범위, 스키마 버전, 품질 임계값
서버 규칙과 묶인 값은 위치를 함께 적음
"""

# 보기 키 (SQLD 4지선다, 서버 CuratedChoiceValidator.CURATED_CHOICE_COUNT 와 같은 4개)
CHOICE_KEYS = ["A", "B", "C", "D"]

# 문제 YAML 스키마 버전: 1 = #511 원형, 2 = #524 (의도·함정·난이도 근거·개념·경향 태그)
SCHEMA_VERSION_LEGACY = 1
SCHEMA_VERSION_CURRENT = 2

# 서버 topic 테이블 코드 (server/PQL-Web db/migration V0_0_22 기준, 관리자에서 추가되면 경고만 발생)
KNOWN_TOPIC_CODES = frozenset({
    "data_modeling",
    "sql_basic_select",
    "sql_ddl_dml_tcl",
    "sql_function",
    "sql_group_aggregate",
    "sql_hierarchy_pivot",
    "sql_join",
    "sql_subquery",
    "sql_window",
})

# 난이도 범위 (서버 Question.difficulty 1~5)
MINIMUM_DIFFICULTY = 1
MAXIMUM_DIFFICULTY = 5

# 보기 expect 종류: 정답 SQL 결과와 비교 / 보기 SQL 실행 / 실행 불가 설명형
ANSWER_COMPARE_EXPECT_TYPES = ("rows", "scalar")
CHOICE_EXECUTION_EXPECT_TYPES = ("same_as_answer", "error", "body_rows", "count")
CONCEPT_EXPECT_TYPE = "concept"
ALL_EXPECT_TYPES = ANSWER_COMPARE_EXPECT_TYPES + CHOICE_EXECUTION_EXPECT_TYPES + (CONCEPT_EXPECT_TYPE,)

# pick: 보기 count 비교 기준 (max 가장 많은 것, min 가장 적은 것)
PICK_TYPES = ("max", "min")

# 품질 임계값
# 오답 '왜 그럴듯한지' 최소 글자 수 (한 단어짜리 성의 없는 사유 차단)
MINIMUM_PLAUSIBLE_REASON_LENGTH = 8
# TEXT 보기 길이 균형: 정답이 오답 평균보다 이 배수 이상 길면 정답이 티 남
CORRECT_CHOICE_LENGTH_RATIO_LIMIT = 1.6
# 정답 위치 분포: 한 키가 이 비율을 넘으면 경고 (문항 수가 아래 값 이상일 때만 판정)
ANSWER_POSITION_SHARE_LIMIT = 0.4
ANSWER_POSITION_MINIMUM_SAMPLE = 8
# 중복 탐지: 지문+SQL+보기 정규화 문자열 유사도 경고 기준 (0~1)
DUPLICATE_SIMILARITY_THRESHOLD = 0.9
# 2026 경향: 개념 2~3개 결합 권장 (concepts 개수 하한)
RECOMMENDED_MINIMUM_CONCEPT_COUNT = 2
# 2026 경향: 2과목 결과 추적형 비율 목표 (설명형 20% 이하)
TARGET_RESULT_TRACING_SHARE = 0.8

# 해설 (#521 구조화 해설): keyConcepts 개수 범위
MINIMUM_KEY_CONCEPT_COUNT = 1
MAXIMUM_KEY_CONCEPT_COUNT = 5
