"""
점검 결과 1건 형태: 심각도·규칙 코드·문제 id·메시지 (lint·verify·해설 검증 공통)
심각도 3개: error(등록 차단), warning(검토 필요), info(경향 권장)
"""
from dataclasses import dataclass, asdict

SEVERITY_ERROR = "error"
SEVERITY_WARNING = "warning"
SEVERITY_INFO = "info"
SEVERITY_ORDER = {SEVERITY_ERROR: 0, SEVERITY_WARNING: 1, SEVERITY_INFO: 2}


@dataclass(frozen=True)
class Finding:
    severity: str
    rule: str
    question_id: str
    message: str

    def to_dict(self):
        return asdict(self)

    def to_line(self):
        return f"  [{self.severity}] {self.question_id} {self.rule}: {self.message}"


def has_blocking_finding(findings):
    return any(finding.severity == SEVERITY_ERROR for finding in findings)


def sort_findings(findings):
    """심각도 > 문제 id > 규칙 순 정렬 (리포트 출력 순서 고정)"""
    return sorted(findings, key=lambda finding: (SEVERITY_ORDER[finding.severity], finding.question_id, finding.rule))
