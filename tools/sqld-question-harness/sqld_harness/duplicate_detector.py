"""
중복 문제 탐지: 가져오기 항목 모양 지문(지문+표+SQL)·정답 SQL·보기 정규화 > 쌍별 유사도
대상 2개: 이번 묶음 안, 기존 문제 풀(관리자 내보내기 JSON)과 이번 묶음
"""
import difflib
import json
import re
from pathlib import Path

from .constants import DUPLICATE_SIMILARITY_THRESHOLD
from .findings import SEVERITY_ERROR, SEVERITY_WARNING, Finding
from .sql_script import normalize_sql_text

# 지문 앞머리 상투구 (모든 결과형 문제가 공유 > 유사도 부풀림 방지)
BOILERPLATE_STEM_PATTERN = re.compile(r"다음\s*(sql|SQL)\s*(의|을|를)?\s*(실행\s*)?(결과|수행)[^?]*\?")


def build_fingerprint(import_item):
    """가져오기 항목 > 비교 문자열 (상투구 제거, 공백 정리, 대문자)"""
    stem = BOILERPLATE_STEM_PATTERN.sub(" ", import_item.get("stem") or "")
    choice_bodies = " | ".join(str(choice.get("body")) for choice in import_item.get("choices") or [])
    return normalize_sql_text(f"{stem} || {import_item.get('answerSql') or ''} || {choice_bodies}")


def calculate_similarity(left_fingerprint, right_fingerprint):
    matcher = difflib.SequenceMatcher(None, left_fingerprint, right_fingerprint, autojunk=False)
    # quick_ratio 는 상한값 > 기준 미만이면 정밀 계산 생략
    if matcher.quick_ratio() < DUPLICATE_SIMILARITY_THRESHOLD:
        return matcher.quick_ratio()
    return matcher.ratio()


def find_duplicate_findings(labeled_items, pool_items=None):
    """
    (문제 id, 가져오기 항목) 목록 > 중복 경고
    같은 정답 SQL·같은 보기 > error, 유사도 기준 이상 > warning
    """
    findings = []
    fingerprints = [(question_id, item, build_fingerprint(item)) for question_id, item in labeled_items]
    for left_index, (left_id, left_item, left_fingerprint) in enumerate(fingerprints):
        for right_id, right_item, right_fingerprint in fingerprints[left_index + 1:]:
            finding = _compare_pair(left_id, left_item, left_fingerprint, right_id, right_item, right_fingerprint)
            if finding:
                findings.append(finding)
    for pool_index, pool_item in enumerate(pool_items or []):
        pool_label = f"pool#{pool_index + 1}" + (f"({pool_item['questionUuid']})" if pool_item.get("questionUuid") else "")
        pool_fingerprint = build_fingerprint(pool_item)
        for question_id, item, fingerprint in fingerprints:
            # 같은 uuid 는 기존 문제 수정본 > 중복 아님
            if item.get("questionUuid") and item.get("questionUuid") == pool_item.get("questionUuid"):
                continue
            finding = _compare_pair(question_id, item, fingerprint, pool_label, pool_item, pool_fingerprint)
            if finding:
                findings.append(finding)
    return findings


def _compare_pair(left_id, left_item, left_fingerprint, right_id, right_item, right_fingerprint):
    if _is_same_answer_and_choices(left_item, right_item):
        return Finding(SEVERITY_ERROR, "duplicate.identical", left_id, f"{right_id} 와 정답 SQL·보기가 같음")
    similarity = calculate_similarity(left_fingerprint, right_fingerprint)
    if similarity >= DUPLICATE_SIMILARITY_THRESHOLD:
        return Finding(SEVERITY_WARNING, "duplicate.similar", left_id, f"{right_id} 와 유사도 {similarity:.2f}")
    return None


def _is_same_answer_and_choices(left_item, right_item):
    left_bodies = sorted(normalize_sql_text(str(choice.get("body"))) for choice in left_item.get("choices") or [])
    right_bodies = sorted(normalize_sql_text(str(choice.get("body"))) for choice in right_item.get("choices") or [])
    left_answer = normalize_sql_text(left_item.get("answerSql"))
    return bool(left_bodies) and left_bodies == right_bodies and left_answer == normalize_sql_text(right_item.get("answerSql"))


def load_pool_items(path):
    """관리자 내보내기·가져오기 JSON (배열) > 항목 목록"""
    document = json.loads(Path(path).read_text(encoding="utf-8"))
    return document if isinstance(document, list) else document.get("items", [])
