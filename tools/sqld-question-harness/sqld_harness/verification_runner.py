"""
검증 실행기: 캐시 조회 > 미스분만 병렬 실행 > 캐시 저장 (입력 순서 유지)
캐시 키: 실행에 영향 주는 필드(ddl, data, answerSql, pick, 보기 body·isCorrect·expect) + 검증 규칙 버전
"""
import hashlib
import json
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from .choice_verifier import VerificationResult, verify_question_with_executor
from .question_schema import get_choices

# 검증 규칙이 바뀌면 올림 > 기존 캐시 전부 무효
VERIFY_RULE_VERSION = "2"
# 기본 캐시 위치: tools/sqld-question-harness/.cache/verify-cache.json (gitignore)
DEFAULT_CACHE_PATH = Path(__file__).resolve().parents[1] / ".cache" / "verify-cache.json"
# 기본 병렬 수: Oracle Free 세션 부담 고려
DEFAULT_WORKER_COUNT = 4


def compute_verification_cache_key(question):
    """문제 > 실행 관련 필드 해시 (지문·해설·태그 수정은 재검증 불필요)"""
    execution_fields = {
        "ruleVersion": VERIFY_RULE_VERSION,
        "ddl": question.get("ddl"),
        "data": question.get("data"),
        "answerSql": question.get("answerSql"),
        "pick": question.get("pick"),
        "choices": [
            {"body": str(choice.get("body")), "isCorrect": bool(choice.get("isCorrect")), "expect": choice.get("expect")}
            for choice in get_choices(question)
        ],
    }
    serialized = json.dumps(execution_fields, ensure_ascii=False, sort_keys=True, default=str)
    return hashlib.sha256(serialized.encode("utf-8")).hexdigest()


class VerificationCache:
    """검증 결과 파일 캐시 {키: 결과}. path None 이면 비활성"""

    def __init__(self, path=None):
        self.path = Path(path) if path else None
        self.entries = {}
        if self.path and self.path.is_file():
            try:
                self.entries = json.loads(self.path.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                self.entries = {}

    def get(self, cache_key):
        entry = self.entries.get(cache_key)
        if entry is None:
            return None
        result = VerificationResult.from_dict(entry)
        result.is_from_cache = True
        return result

    def put(self, cache_key, result):
        if result.is_harness_error:
            return
        entry = result.to_dict()
        entry["isFromCache"] = False
        self.entries[cache_key] = entry

    def save(self):
        if not self.path:
            return
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(json.dumps(self.entries, ensure_ascii=False, indent=1), encoding="utf-8")


def run_verifications(executor, questions, cache=None, worker_count=DEFAULT_WORKER_COUNT):
    """문제 목록 > 결과 목록 (입력 순서). 캐시 적중분은 실행 생략"""
    cache = cache or VerificationCache()
    cache_keys = [compute_verification_cache_key(question) for question in questions]
    results = [cache.get(cache_key) for cache_key in cache_keys]
    pending_indexes = [index for index, result in enumerate(results) if result is None]

    def verify_at(index):
        return index, verify_question_with_executor(executor, questions[index])

    with ThreadPoolExecutor(max_workers=max(1, worker_count)) as pool:
        for index, result in pool.map(verify_at, pending_indexes):
            results[index] = result
            cache.put(cache_keys[index], result)
    # 캐시 결과는 같은 실행 내용의 다른 id 일 수 있어 현재 id 로 다시 기록
    for question, result in zip(questions, results):
        result.question_id = str(question["id"])
    cache.save()
    return results
