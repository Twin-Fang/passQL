"""계층 의존 방향 강제: apis > services > clients, models·core 는 상위 계층을 모름 (소스 import 스캔)"""
import ast
from pathlib import Path

import pytest

SOURCE_ROOT = Path(__file__).resolve().parent.parent / "src"

# 계층 폴더 > import 금지 대상 패키지
FORBIDDEN_IMPORT_PREFIXES_BY_LAYER = {
    # 라우터는 외부 시스템을 직접 부르지 않고 services 를 거침
    "apis": ("src.clients",),
    "services": ("src.apis",),
    "clients": ("src.apis", "src.services"),
    "models": ("src.apis", "src.services", "src.clients"),
    "core": ("src.apis", "src.services", "src.clients"),
    "utils": ("src.apis", "src.services", "src.clients"),
}


def _read_imported_module_names(source_file: Path) -> list[str]:
    """파일의 import / from-import 대상 모듈 이름 목록"""
    syntax_tree = ast.parse(source_file.read_text(encoding="utf-8"))
    imported_module_names = []
    for node in ast.walk(syntax_tree):
        if isinstance(node, ast.Import):
            imported_module_names.extend(alias.name for alias in node.names)
        elif isinstance(node, ast.ImportFrom) and node.module:
            imported_module_names.append(node.module)
    return imported_module_names


def _find_layer_violations(
    source_root: Path, layer: str, forbidden_prefixes: tuple[str, ...]
) -> list[str]:
    """계층 폴더 전체 스캔 > 금지 import 목록 ("파일: 모듈")"""
    violations = []
    for source_file in sorted((source_root / layer).rglob("*.py")):
        for module_name in _read_imported_module_names(source_file):
            if module_name.startswith(forbidden_prefixes):
                violations.append(f"{source_file.relative_to(source_root)}: {module_name}")
    return violations


@pytest.mark.parametrize("layer", sorted(FORBIDDEN_IMPORT_PREFIXES_BY_LAYER))
def test_layer_does_not_import_forbidden_layers(layer):
    assert (SOURCE_ROOT / layer).is_dir(), f"계층 폴더 없음: {layer}"
    assert _find_layer_violations(SOURCE_ROOT, layer, FORBIDDEN_IMPORT_PREFIXES_BY_LAYER[layer]) == []


def test_rule_scan_detects_violation(tmp_path):
    # 스캔 자체 동작 확인 (항상 통과하는 빈 규칙 방지)
    fake_router_folder = tmp_path / "apis"
    fake_router_folder.mkdir()
    (fake_router_folder / "bad_router.py").write_text(
        "from src.clients.gemini_client import gemini_client\n", encoding="utf-8"
    )
    assert _find_layer_violations(tmp_path, "apis", ("src.clients",)) == [
        "apis/bad_router.py: src.clients.gemini_client"
    ]
