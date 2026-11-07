import 'package:flutter/widgets.dart';

/// 메모 도구 3종: 펜(가는 선), 형광펜(굵은 반투명 노랑), 지우개(닿은 획 통째로)
enum PassqlMemoTool { pen, highlighter, eraser }

/// 펜 색 3종. 실제 색은 테마가 정함 (label: 라이트 검정·다크 흰색)
enum PassqlMemoInk { red, blue, label }

/// 획 하나: 도구(펜·형광펜) + 색 + 점 목록 (메모 층 좌표, 내용과 함께 스크롤)
/// 형광펜은 색 고정 (ink 무시)
@immutable
class PassqlMemoStroke {
  const PassqlMemoStroke({
    required this.tool,
    required this.ink,
    required this.points,
  });

  final PassqlMemoTool tool;
  final PassqlMemoInk ink;
  final List<Offset> points;

  // 선 굵기: 펜 / 형광펜 (시안 2.5 · 14)
  static const double penWidth = 2.5;
  static const double highlighterWidth = 14;

  double get width =>
      tool == PassqlMemoTool.highlighter ? highlighterWidth : penWidth;

  /// 지우개 원(중심 [point], 반지름 [radius])이 선에 닿는지: 점·선분까지 거리 <= 반지름 + 선 반폭
  bool isTouchedBy(Offset point, double radius) {
    final reach = radius + width / 2;
    if (points.length == 1) return (points.first - point).distance <= reach;
    for (var index = 1; index < points.length; index++) {
      if (_distanceToSegment(point, points[index - 1], points[index]) <=
          reach) {
        return true;
      }
    }
    return false;
  }

  /// 점 > 선분(start-end) 최단 거리
  static double _distanceToSegment(Offset point, Offset start, Offset end) {
    final segment = end - start;
    final segmentLengthSquared = segment.distanceSquared;
    if (segmentLengthSquared == 0) return (point - start).distance;
    final projection =
        ((point - start).dx * segment.dx + (point - start).dy * segment.dy) /
        segmentLengthSquared;
    final closest = start + segment * projection.clamp(0.0, 1.0);
    return (point - closest).distance;
  }
}

/// 풀이 화면 메모 상태: 켬·끔, 도구·색, 문항별 획, 문항별 되돌리기 기록
/// 기기 메모리에만 (서버 저장 없음). 화면 State 가 만들고 dispose 하면 응시 메모도 사라짐
class PassqlMemoController extends ChangeNotifier {
  bool _isMemoMode = false;
  PassqlMemoTool _selectedTool = PassqlMemoTool.pen;
  PassqlMemoInk _selectedInk = PassqlMemoInk.red;
  final Map<Object, List<PassqlMemoStroke>> _strokesByPageKey = {};
  final Map<Object, List<List<PassqlMemoStroke>>> _undoSnapshotsByPageKey = {};

  /// 이번 지우개 동작에서 되돌리기 기록을 남겼는지 (한 번 문지르기 = 되돌리기 1번)
  bool _hasRecordedCurrentErase = false;

  /// true: 그리기 층이 터치를 받음, false: 메모는 흐리게 보이기만 하고 터치는 아래 내용으로
  bool get isMemoMode => _isMemoMode;
  PassqlMemoTool get selectedTool => _selectedTool;
  PassqlMemoInk get selectedInk => _selectedInk;

  List<PassqlMemoStroke> strokesOf(Object pageKey) =>
      _strokesByPageKey[pageKey] ?? const [];

  bool hasStrokesOn(Object pageKey) => strokesOf(pageKey).isNotEmpty;

  bool canUndoOn(Object pageKey) =>
      _undoSnapshotsByPageKey[pageKey]?.isNotEmpty ?? false;

  void toggleMemoMode() {
    _isMemoMode = !_isMemoMode;
    notifyListeners();
  }

  void turnOffMemoMode() {
    if (!_isMemoMode) return;
    _isMemoMode = false;
    notifyListeners();
  }

  void selectTool(PassqlMemoTool tool) {
    if (_selectedTool == tool) return;
    _selectedTool = tool;
    notifyListeners();
  }

  /// 색 고름 > 펜으로 전환 (형광펜은 색 고정, 지우개는 색 없음)
  void selectInk(PassqlMemoInk ink) {
    _selectedInk = ink;
    _selectedTool = PassqlMemoTool.pen;
    notifyListeners();
  }

  void addStroke(Object pageKey, PassqlMemoStroke stroke) {
    _recordUndoSnapshot(pageKey);
    _strokesByPageKey[pageKey] = [...strokesOf(pageKey), stroke];
    notifyListeners();
  }

  /// 지우개 손가락 내림: 이번 동작의 되돌리기 기록 아직 없음
  void startEraseGesture() => _hasRecordedCurrentErase = false;

  /// 지우개 원에 닿은 획 제거 (동작당 되돌리기 기록 1번, 지운 게 없으면 기록 없음)
  void eraseStrokesTouchedBy(Object pageKey, Offset point, double radius) {
    final strokes = strokesOf(pageKey);
    final remainingStrokes = [
      for (final stroke in strokes)
        if (!stroke.isTouchedBy(point, radius)) stroke,
    ];
    if (remainingStrokes.length == strokes.length) return;
    if (!_hasRecordedCurrentErase) {
      _recordUndoSnapshot(pageKey);
      _hasRecordedCurrentErase = true;
    }
    _strokesByPageKey[pageKey] = remainingStrokes;
    notifyListeners();
  }

  /// 마지막 동작(그리기·지우기) 하나 되돌림
  void undo(Object pageKey) {
    final snapshots = _undoSnapshotsByPageKey[pageKey];
    if (snapshots == null || snapshots.isEmpty) return;
    _strokesByPageKey[pageKey] = snapshots.removeLast();
    notifyListeners();
  }

  void _recordUndoSnapshot(Object pageKey) {
    _undoSnapshotsByPageKey
        .putIfAbsent(pageKey, () => [])
        .add(strokesOf(pageKey));
  }
}
