# -*- coding: utf-8 -*-
"""SQLD 공부 글 4편 원본: 개념 정리 3편(#1088, NULL 함정, 윈도우 함수, 조인 종류) + passQL 학습 순서(#1078)
사이트 전용으로 새로 쓴 글 (앱 개념 글 복사 아님), 공식 시험 범위 안 일반 지식, 예시 결과는 실행해 확인한 값
블록 형식: ("p", 문장) | ("sql", 코드) | ("table", 이름, [열], [[값]]) | ("list", [문장]) | ("tip", 문장)
문장 안 `글자`는 코드 글꼴로 표시, 값 None 은 표에서 NULL
"""

# 예시 테이블 (세 글이 같은 이름을 다른 뜻으로 쓰지 않게 글마다 따로 둠)
MEMBER_POINT_TABLE = ("table", "MEMBER", ["MEM_ID", "POINT"], [["A", 100], ["B", None], ["C", 300]])
EXAM_SCORE_TABLE = ("table", "EXAM_SCORE", ["NAME", "SCORE"], [["가", 90], ["나", 85], ["다", 85], ["라", 70]])
DEPT_TABLE = ("table", "DEPT", ["DEPT_ID", "DEPT_NAME"], [[10, "영업"], [20, "개발"], [30, "인사"]])
EMP_TABLE = ("table", "EMP", ["EMP_ID", "NAME", "DEPT_ID", "MGR_ID", "SAL"],
             [[1, "김하늘", 10, None, 5200], [2, "이바다", 20, 1, 4100], [3, "박구름", None, 1, 2900], [4, "최별", 10, 2, 3600]])

# 글 경로 > 글: h1(강조 부분 분리), 머리말, 관련 기출 고르는 기준, 구역 [(제목, [블록])]
# related_rule: ("topic", [토픽 코드]) 또는 ("keyword", 문자열) 또는 None (관련 기출 없음)
STUDY_GUIDE_ARTICLES = {
    "sqld/guide/null-traps/": {
        "h1": ("SQLD ", "NULL 함정", " 정리"),
        "lead": "NULL은 0도 빈칸도 아닌 '알 수 없는 값'이에요. 비교, NOT IN, 집계, 정렬에서 NULL이 어떻게 움직이는지 예시 결과와 함께 정리했어요.",
        "related_rule": ("keyword", "NULL"),
        "sections": [
            ("NULL은 값이 아니라 '모름'", [
                MEMBER_POINT_TABLE,
                ("p", "NULL과 무엇을 비교하든 결과는 참도 거짓도 아닌 UNKNOWN이에요. WHERE 절은 결과가 참인 행만 남기므로 `POINT = NULL`은 어떤 행도 고르지 못해요."),
                ("sql", "SELECT MEM_ID FROM MEMBER WHERE POINT = NULL;   -- 0행\nSELECT MEM_ID FROM MEMBER WHERE POINT IS NULL;  -- B"),
                ("p", "NULL과의 사칙연산도 NULL이에요. `POINT + 10`은 B 행에서 NULL이 돼요. Oracle은 길이가 0인 문자열 `''`도 NULL로 다뤄서 `WHERE NAME = ''` 역시 아무 행도 고르지 못해요."),
            ]),
            ("세 값 논리: TRUE, FALSE, UNKNOWN", [
                ("list", [
                    "`UNKNOWN AND FALSE`는 FALSE, `UNKNOWN AND TRUE`는 UNKNOWN이에요.",
                    "`UNKNOWN OR TRUE`는 TRUE, `UNKNOWN OR FALSE`는 UNKNOWN이에요.",
                    "`NOT UNKNOWN`은 여전히 UNKNOWN이라 부정해도 행이 살아나지 않아요.",
                ]),
                ("tip", "WHERE 조건을 손으로 따질 때는 행마다 TRUE인지 먼저 확인하고, NULL이 끼면 UNKNOWN으로 두고 AND, OR 규칙으로 마무리해요."),
            ]),
            ("NOT IN 목록에 NULL이 섞이면 0행", [
                ("p", "`IN`은 OR로 풀려서 NULL이 섞여도 맞는 값은 찾아요. 반대로 `NOT IN`은 AND로 풀리기 때문에 목록에 NULL이 하나라도 있으면 모든 행이 UNKNOWN이 돼요."),
                ("sql", "SELECT MEM_ID FROM MEMBER WHERE POINT IN (100, NULL);      -- A\nSELECT MEM_ID FROM MEMBER WHERE POINT NOT IN (100, NULL);  -- 0행"),
                ("p", "서브쿼리 결과에 NULL이 섞일 때도 같아요. `NOT IN (SELECT ...)`이 갑자기 0행을 돌려주면 서브쿼리 열에 NULL이 있는지 먼저 보세요. `NOT EXISTS`는 행이 있는지만 따지므로 이 함정이 없어요."),
            ]),
            ("집계 함수는 NULL을 건너뛴다", [
                ("p", "`COUNT(*)`는 행 수를 그대로 세지만, `COUNT(열)`, `SUM`, `AVG`, `MAX`, `MIN`은 NULL인 칸을 빼고 계산해요. 그래서 평균의 분모가 달라져요."),
                ("sql", "SELECT COUNT(*), COUNT(POINT), SUM(POINT), AVG(POINT), AVG(NVL(POINT, 0))\n  FROM MEMBER;\n-- 3, 2, 400, 200, 133.33..."),
                ("p", "조건에 맞는 행이 하나도 없으면 `COUNT`는 0을, `SUM`과 `AVG`는 NULL을 돌려줘요. 'NULL을 0으로 쳐서' 라는 조건이 보이면 `NVL` 이나 `COALESCE`로 먼저 바꿨는지 확인하세요."),
            ]),
            ("정렬할 때 NULL의 자리", [
                ("p", "Oracle은 NULL을 가장 큰 값처럼 다뤄서 오름차순이면 맨 뒤, 내림차순이면 맨 앞에 둬요. SQL Server는 반대로 NULL을 가장 작은 값처럼 다뤄요. Oracle에서는 `NULLS FIRST`, `NULLS LAST`로 자리를 직접 정할 수 있어요."),
            ]),
            ("NULL을 다루는 함수", [
                ("list", [
                    "`NVL(값, 대체값)`: 값이 NULL이면 대체값 (SQL Server는 `ISNULL`).",
                    "`COALESCE(a, b, c)`: 왼쪽부터 처음 만나는 NULL이 아닌 값, 모두 NULL이면 NULL.",
                    "`NVL2(값, A, B)`: 값이 NULL이 아니면 A, NULL이면 B.",
                    "`NULLIF(a, b)`: 두 값이 같으면 NULL, 다르면 a.",
                ]),
                ("tip", "`NULLIF`는 NULL을 없애는 함수가 아니라 만드는 함수예요. 보기에서 결과가 NULL이 되는 SQL을 고르라고 하면 `NULLIF` 부터 계산해 보세요."),
            ]),
        ],
    },
    "sqld/guide/window-functions/": {
        "h1": ("SQLD ", "윈도우 함수", " 정리"),
        "lead": "윈도우 함수는 행을 줄이지 않고 각 행 옆에 순위, 누적 합, 앞뒤 행 값을 붙여요. 시험에 자주 나오는 순위 함수, 누적 합의 기본 범위, LAG와 LEAD를 예시로 정리했어요.",
        "related_rule": ("topic", ["sql_window"]),
        "sections": [
            ("기본 모양과 GROUP BY와의 차이", [
                ("sql", "함수명(인자) OVER ([PARTITION BY 묶을 열] [ORDER BY 정렬 열] [ROWS | RANGE 범위])"),
                ("p", "`GROUP BY`는 묶은 그룹마다 한 행으로 줄이지만, 윈도우 함수는 원래 행 수를 그대로 두고 계산 결과를 열로 붙여요. `PARTITION BY`는 계산을 나눌 묶음, `ORDER BY`는 그 안의 순서예요."),
                ("p", "윈도우 함수는 WHERE, GROUP BY, HAVING이 끝난 뒤에 계산돼요. 그래서 WHERE 절에 순위 조건을 바로 쓸 수 없고, 인라인 뷰로 감싼 다음 바깥에서 걸러야 해요."),
            ]),
            ("순위 함수 세 가지", [
                EXAM_SCORE_TABLE,
                ("sql", "SELECT NAME, SCORE,\n       RANK()       OVER (ORDER BY SCORE DESC) AS RNK,\n       DENSE_RANK() OVER (ORDER BY SCORE DESC) AS DRNK,\n       ROW_NUMBER() OVER (ORDER BY SCORE DESC) AS RN\n  FROM EXAM_SCORE;"),
                ("table", "결과", ["NAME", "SCORE", "RNK", "DRNK", "RN"],
                 [["가", 90, 1, 1, 1], ["나", 85, 2, 2, 2], ["다", 85, 2, 2, 3], ["라", 70, 4, 3, 4]]),
                ("list", [
                    "`RANK`: 동점은 같은 순위, 다음 순위는 동점 수만큼 건너뛰어요 (1, 2, 2, 4).",
                    "`DENSE_RANK`: 동점은 같은 순위, 다음 순위를 건너뛰지 않아요 (1, 2, 2, 3).",
                    "`ROW_NUMBER`: 동점이어도 1부터 차례로 다른 번호를 줘요. 동점끼리 누가 앞인지는 정렬 열을 더 주지 않으면 보장되지 않아요.",
                ]),
            ]),
            ("누적 합과 기본 범위", [
                ("p", "집계 함수에 `ORDER BY`를 붙이면 누적 계산이 돼요. 범위를 적지 않으면 기본값은 `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` 예요. RANGE는 정렬 값이 같은 행을 한 덩어리로 보기 때문에 동점 행은 누적 합이 같아요."),
                ("sql", "SELECT NAME, SCORE,\n       SUM(SCORE) OVER (ORDER BY SCORE DESC) AS RANGE_SUM,\n       SUM(SCORE) OVER (ORDER BY SCORE DESC\n                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ROWS_SUM\n  FROM EXAM_SCORE;"),
                ("table", "결과", ["NAME", "SCORE", "RANGE_SUM", "ROWS_SUM"],
                 [["가", 90, 90, 90], ["나", 85, 260, 175], ["다", 85, 260, 260], ["라", 70, 330, 330]]),
                ("tip", "`ORDER BY` 없이 `SUM(SCORE) OVER ()`처럼 쓰면 누적이 아니라 묶음 전체 합계가 모든 행에 붙어요. 보기에서 ORDER BY가 있는지부터 확인하세요."),
            ]),
            ("앞뒤 행 값: LAG, LEAD", [
                ("p", "`LAG(열, n, 기본값)`은 n행 앞, `LEAD(열, n, 기본값)`은 n행 뒤의 값을 가져와요. n을 생략하면 1이고, 가져올 행이 없으면 기본값을, 기본값도 없으면 NULL을 돌려줘요."),
                ("sql", "SELECT NAME, SCORE,\n       LAG(SCORE)        OVER (ORDER BY SCORE DESC, NAME) AS PREV_SCORE,\n       LEAD(SCORE, 1, 0) OVER (ORDER BY SCORE DESC, NAME) AS NEXT_SCORE\n  FROM EXAM_SCORE;"),
                ("table", "결과", ["NAME", "SCORE", "PREV_SCORE", "NEXT_SCORE"],
                 [["가", 90, None, 85], ["나", 85, 90, 85], ["다", 85, 85, 70], ["라", 70, 85, 0]]),
            ]),
            ("비율 함수 한 줄 정리", [
                ("list", [
                    "`PERCENT_RANK`: (순위 - 1) / (행 수 - 1). 첫 행은 0, 마지막 행은 1이에요.",
                    "`CUME_DIST`: 정렬 순서상 나보다 앞이거나 나와 같은 값인 행 수 / 전체 행 수. 동점은 같은 값이에요.",
                    "`NTILE(n)`: 행을 n개 묶음으로 나눠 번호를 줘요. 나머지 행은 앞 묶음부터 하나씩 더 받아요.",
                    "`RATIO_TO_REPORT(열)`: 묶음 합계에서 내 값이 차지하는 비율이에요.",
                ]),
            ]),
        ],
    },
    "sqld/guide/join-types/": {
        "h1": ("SQLD ", "조인 종류", " 정리"),
        "lead": "INNER, OUTER, CROSS 조인과 셀프 조인, 비등가 조인을 같은 두 테이블로 비교했어요. 조인 문제는 결과 행 수를 세는 문제가 많아서 행이 왜 남고 사라지는지에 집중했어요.",
        "related_rule": ("topic", ["sql_join"]),
        "sections": [
            ("예시 테이블", [
                DEPT_TABLE,
                EMP_TABLE,
                ("p", "박구름은 부서가 없고(DEPT_ID NULL), 인사 부서(30)에는 직원이 없어요. 이 두 행이 조인 종류마다 남는지 사라지는지가 핵심이에요."),
            ]),
            ("INNER JOIN: 양쪽에 짝이 있는 행만", [
                ("sql", "SELECT E.NAME, D.DEPT_NAME\n  FROM EMP E INNER JOIN DEPT D ON E.DEPT_ID = D.DEPT_ID;\n-- 3행: 김하늘 영업, 이바다 개발, 최별 영업"),
                ("p", "NULL은 어떤 값과도 같지 않으므로 박구름은 짝을 못 찾고, 인사 부서도 짝이 없어 둘 다 빠져요."),
            ]),
            ("OUTER JOIN: 한쪽 행은 짝이 없어도 남긴다", [
                ("list", [
                    "`EMP E LEFT OUTER JOIN DEPT D`: 4행. 박구름이 DEPT_NAME NULL로 남아요.",
                    "`EMP E RIGHT OUTER JOIN DEPT D`: 4행. 인사 부서가 NAME NULL로 남아요.",
                    "`EMP E FULL OUTER JOIN DEPT D`: 5행. 짝 있는 3행 + 박구름 + 인사.",
                ]),
                ("p", "OUTER JOIN에서 조건을 ON에 두느냐 WHERE에 두느냐에 따라 결과가 달라져요. 안쪽(NULL이 채워지는 쪽) 테이블 조건을 WHERE에 쓰면 NULL 행이 걸러져 INNER JOIN처럼 돼요."),
                ("sql", "-- ON 에 조건: 4행 (영업이 아니면 DEPT_NAME 만 NULL)\nSELECT E.NAME, D.DEPT_NAME\n  FROM EMP E LEFT JOIN DEPT D\n    ON E.DEPT_ID = D.DEPT_ID AND D.DEPT_NAME = '영업';\n\n-- WHERE 에 조건: 2행 (김하늘, 최별)\nSELECT E.NAME, D.DEPT_NAME\n  FROM EMP E LEFT JOIN DEPT D ON E.DEPT_ID = D.DEPT_ID\n WHERE D.DEPT_NAME = '영업';"),
                ("tip", "Oracle 전용 표기 `WHERE E.DEPT_ID = D.DEPT_ID(+)`는 (+)가 붙은 쪽이 NULL로 채워지는 쪽이에요. 이 식은 EMP 기준 LEFT OUTER JOIN과 같아요."),
            ]),
            ("CROSS JOIN, NATURAL JOIN, USING", [
                ("p", "`CROSS JOIN`은 조건 없이 모든 조합을 만들어 4 x 3 = 12행이 나와요. 조인 조건을 빠뜨린 쉼표 조인도 같은 결과예요."),
                ("p", "`NATURAL JOIN`은 이름이 같은 열을 모두 같다는 조건으로 묶고, `USING (DEPT_ID)`는 지정한 열만으로 묶어요. 두 방식 모두 조인 열 앞에 `E.` 같은 별칭을 붙이면 Oracle에서 오류가 나요."),
            ]),
            ("셀프 조인: 같은 테이블을 두 번", [
                ("p", "직원과 상사가 한 테이블에 있을 때는 별칭을 둘로 나눠 자기 자신과 조인해요. MGR_ID가 상사의 EMP_ID예요."),
                ("sql", "SELECT E.NAME AS 직원, M.NAME AS 상사\n  FROM EMP E JOIN EMP M ON E.MGR_ID = M.EMP_ID;\n-- 3행: 이바다 김하늘, 박구름 김하늘, 최별 이바다"),
                ("p", "상사가 없는 김하늘까지 보려면 `LEFT JOIN`으로 바꿔요. 그러면 4행이 되고 김하늘의 상사는 NULL이에요."),
            ]),
            ("비등가 조인: 범위로 짝 찾기", [
                ("p", "`=` 대신 `BETWEEN` 이나 크기 비교로 조인하는 방식이에요. 급여 등급표처럼 값이 범위 안에 드는 행을 찾을 때 써요."),
                ("table", "SAL_GRADE", ["GRADE", "LOSAL", "HISAL"], [[1, 0, 2999], [2, 3000, 3999], [3, 4000, 4999], [4, 5000, 9999]]),
                ("sql", "SELECT E.NAME, E.SAL, G.GRADE\n  FROM EMP E JOIN SAL_GRADE G\n    ON E.SAL BETWEEN G.LOSAL AND G.HISAL;\n-- 김하늘 4, 이바다 3, 박구름 1, 최별 2"),
                ("tip", "범위가 겹치거나 빈틈이 있는 등급표가 나오면 한 행이 두 번 나오거나 사라질 수 있어요. 경계값(2999, 3000)이 어느 범위에 드는지 꼭 확인하세요."),
            ]),
        ],
    },
    # passQL 학습 순서 (#1078): 앱 학습 가이드 화면과 같은 단계
    "sqld/guide/passql-route/": {
        "h1": ("passQL로 SQLD ", "합격까지 공부 순서", ""),
        "lead": "기능이 많아도 순서가 있어야 합격까지 가요. 매일 할 일, 기출 복원과 모의고사를 넓혀 가는 4단계, 언제나 쓰는 오답노트를 앱 화면 순서 그대로 정리했어요.",
        "related_rule": None,
        "sections": [
            ("매일 꾸준히", [
                ("list", [
                    "개념 학습: 단원 순서대로 핵심 개념을 익히고, 본문 끝 OX로 바로 확인해요.",
                    "오늘의 세트: 하루 몇 문제로 감을 유지해요. 틀린 문제는 오답노트에 자동으로 모여요.",
                    "잠금화면 문제(Android): 휴대폰을 켤 때마다 한 문제, 가끔은 OX 복습 카드가 나와요.",
                ]),
            ]),
            ("1단계 최신 기출 복원 (52회 이후)", [
                ("p", "2024년 개정 범위가 적용된 52회부터 최신 회차까지 기출 복원을 먼저 반복해요. 처음에는 학습 모드로 한 문제씩 정답과 해설, 실행 결과를 확인하고, 익숙해지면 실전 모드로 90분 안에 풀어요."),
                ("tip", "가장 최근 기출 회차 하나는 무료로 풀 수 있어요."),
            ]),
            ("2단계 이전 기출로 넓히기", [
                ("p", "최신 범위가 손에 익으면 이전 회차 기출로 문제 유형을 넓혀요. 개정 전 회차는 지금 범위와 다른 문항이 섞여 있을 수 있어요."),
            ]),
            ("3단계 모의고사로 신유형 대비", [
                ("p", "모의고사는 같은 문제라도 보기를 새로 만들어 외운 답으로 풀 수 없게 했어요. 과목별 과락과 예상 합격률로 약한 곳을 확인해요."),
            ]),
            ("4단계 시험 직전 FINAL과 오답률 TOP 30", [
                ("p", "시험 3일 전에 고난도 FINAL 회차가 열리고 알림으로 알려 드려요. 많은 사람이 틀린 오답률 TOP 30으로 마지막 함정을 점검해요."),
            ]),
            ("전 과정에서", [
                ("list", [
                    "오답노트: 틀린 문제가 과목별로 모이고, 다시 맞히면 정리돼요.",
                    "실행 결과 비교: 보기 SQL을 직접 실행해 왜 그 결과가 나오는지 확인해요.",
                    "즐겨찾기: 다시 보고 싶은 문제에 별을 눌러 모아 풀어요.",
                ]),
                ("tip", "앱의 학습 가이드 화면에서 단계마다 내 진행(완료, 진행 중)과 지금 할 단계를 볼 수 있어요."),
            ]),
        ],
    },
}
# 글마다 끝에 붙이는 관련 공개 문항 최대 개수
RELATED_SAMPLE_LIMIT = 4
