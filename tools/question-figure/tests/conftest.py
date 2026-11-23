"""생성기 모듈을 테스트에서 바로 import (tools/question-figure 를 경로 맨 앞에)"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
