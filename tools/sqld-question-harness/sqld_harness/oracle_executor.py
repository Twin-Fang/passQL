"""
Oracle 실행기: 문제 1건 전용 스키마 세션 (생성 > DDL·데이터 > 실행 > 삭제), 스레드마다 관리자 연결 1개
세션 인터페이스 3개: run(script) > (행, 오류), reset(), rollback()  (테스트용 다른 실행기도 같은 모양)
"""
import hashlib
import os
import re
import threading

from .sql_script import normalize_rows, split_sql_script

# Oracle Free 컨테이너 접속 (docker run -p 1521:1521 gvenzl/oracle-free:23-slim-faststart)
ORACLE_DSN = os.environ.get("SQLD_HARNESS_DSN", "localhost:1521/FREEPDB1")
ORACLE_ADMIN_USER = os.environ.get("SQLD_HARNESS_ADMIN_USER", "system")
ORACLE_ADMIN_PASSWORD = os.environ.get("SQLD_HARNESS_ADMIN_PASSWORD", "harness")
# 문제별 임시 스키마: SQLDQ_{id 앞 17자}_{id 해시 6자} (30자 이내, 병렬 실행 시 이름 충돌 방지)
QUESTION_SCHEMA_PREFIX = "SQLDQ_"
QUESTION_SCHEMA_ID_LENGTH = 17
QUESTION_SCHEMA_HASH_LENGTH = 6
QUESTION_SCHEMA_PASSWORD = "harness"


def to_question_schema_name(question_id):
    """문제 id > 스키마 이름 (대문자·영숫자·밑줄)"""
    readable_part = re.sub(r"[^A-Z0-9]", "_", str(question_id).upper())[:QUESTION_SCHEMA_ID_LENGTH]
    hash_part = hashlib.sha1(str(question_id).encode("utf-8")).hexdigest()[:QUESTION_SCHEMA_HASH_LENGTH].upper()
    return f"{QUESTION_SCHEMA_PREFIX}{readable_part}_{hash_part}"


class OracleExecutor:
    """Oracle 세션 공급자: 스레드별 관리자 연결 (oracledb 연결은 동시 사용 불가)"""

    def __init__(self, dsn=ORACLE_DSN, admin_user=ORACLE_ADMIN_USER, admin_password=ORACLE_ADMIN_PASSWORD):
        import oracledb  # 지연 import: 오프라인 lint·report 는 드라이버 없이 동작

        self.oracledb = oracledb
        self.dsn = dsn
        self.admin_user = admin_user
        self.admin_password = admin_password
        self._thread_local = threading.local()
        self._admin_connections = []
        self._lock = threading.Lock()

    def _get_admin_connection(self):
        connection = getattr(self._thread_local, "admin_connection", None)
        if connection is None:
            connection = self.oracledb.connect(user=self.admin_user, password=self.admin_password, dsn=self.dsn)
            connection.autocommit = True
            self._thread_local.admin_connection = connection
            with self._lock:
                self._admin_connections.append(connection)
        return connection

    def open_session(self, question_id, setup_script):
        return OracleQuestionSession(self, question_id, setup_script)

    def close(self):
        with self._lock:
            for connection in self._admin_connections:
                connection.close()
            self._admin_connections.clear()


class OracleQuestionSession:
    """문제 1건 전용 스키마: 생성 > DDL·데이터 적용 > 사용 > 삭제 (성공·실패 공통)"""

    def __init__(self, executor, question_id, setup_script):
        self.executor = executor
        self.admin_connection = executor._get_admin_connection()
        self.schema_name = to_question_schema_name(question_id)
        self.setup_script = setup_script
        self.connection = None

    def __enter__(self):
        self._drop_schema()
        with self.admin_connection.cursor() as cursor:
            cursor.execute(f'CREATE USER {self.schema_name} IDENTIFIED BY "{QUESTION_SCHEMA_PASSWORD}" QUOTA UNLIMITED ON USERS')
            cursor.execute(f"GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE TO {self.schema_name}")
        self.connection = self.executor.oracledb.connect(user=self.schema_name, password=QUESTION_SCHEMA_PASSWORD, dsn=self.executor.dsn)
        self.reset()
        return self

    def run(self, script):
        """스크립트 > (마지막 SELECT 행 또는 None, 오류 첫 줄 또는 None)"""
        try:
            return self._run_script(script), None
        except self.executor.oracledb.Error as error:
            return None, str(error).splitlines()[0]

    def _run_script(self, script):
        last_rows = None
        with self.connection.cursor() as cursor:
            for statement in split_sql_script(script):
                cursor.execute(statement)
                if cursor.description is not None:
                    last_rows = normalize_rows(cursor.fetchall())
        return last_rows

    def reset(self):
        """초기 데이터 복원: 기존 객체 삭제 > 설정 스크립트 재적용 (보기마다 같은 출발점)"""
        with self.connection.cursor() as cursor:
            cursor.execute("SELECT object_name, object_type FROM user_objects WHERE object_type IN ('TABLE','VIEW','SEQUENCE')")
            for object_name, object_type in cursor.fetchall():
                suffix = " CASCADE CONSTRAINTS PURGE" if object_type == "TABLE" else ""
                cursor.execute(f'DROP {object_type} "{object_name}"{suffix}')
        self._run_script(self.setup_script)
        self.connection.commit()

    def rollback(self):
        self.connection.rollback()

    def __exit__(self, exc_type, exc, traceback):
        if self.connection is not None:
            self.connection.close()
        self._drop_schema()

    def _drop_schema(self):
        with self.admin_connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) FROM dba_users WHERE username = :name", name=self.schema_name)
            if cursor.fetchone()[0]:
                cursor.execute(f"DROP USER {self.schema_name} CASCADE")
