import { useMemo, useReducer } from "react";
import {
  isStrokeTouchedBy,
  type SolvingMemoInk,
  type SolvingMemoPoint,
  type SolvingMemoStroke,
  type SolvingMemoTool,
} from "../lib/solvingMemoStroke";

interface SolvingMemoState {
  // true: 그리기 층이 터치를 받음, false: 메모는 흐리게 보이기만 하고 터치는 아래 내용으로
  readonly isMemoMode: boolean;
  readonly selectedTool: SolvingMemoTool;
  readonly selectedInk: SolvingMemoInk;
  readonly strokesByPageKey: Readonly<Record<string, readonly SolvingMemoStroke[]>>;
  // 문항별 되돌리기 기록 (동작 직전 획 목록)
  readonly undoSnapshotsByPageKey: Readonly<Record<string, readonly (readonly SolvingMemoStroke[])[]>>;
  // 되돌리기 기록을 남긴 마지막 지우개 동작 (한 번 문지르기 = 되돌리기 1번)
  readonly recordedEraseGestureId: number | null;
}

type SolvingMemoAction =
  | { readonly type: "toggleMemoMode" }
  | { readonly type: "selectTool"; readonly tool: SolvingMemoTool }
  | { readonly type: "selectInk"; readonly ink: SolvingMemoInk }
  | { readonly type: "addStroke"; readonly pageKey: string; readonly stroke: SolvingMemoStroke }
  | {
      readonly type: "erase";
      readonly pageKey: string;
      readonly point: SolvingMemoPoint;
      readonly radiusPixels: number;
      readonly gestureId: number;
    }
  | { readonly type: "undo"; readonly pageKey: string };

const INITIAL_STATE: SolvingMemoState = {
  isMemoMode: false,
  selectedTool: "pen",
  selectedInk: "red",
  strokesByPageKey: {},
  undoSnapshotsByPageKey: {},
  recordedEraseGestureId: null,
};

const NO_STROKES: readonly SolvingMemoStroke[] = [];

/** 문항 획 목록 교체 + (기록할 때) 직전 목록을 되돌리기 기록에 쌓음 */
function replaceStrokes(
  state: SolvingMemoState,
  pageKey: string,
  nextStrokes: readonly SolvingMemoStroke[],
  shouldRecordUndo: boolean,
): SolvingMemoState {
  const previousStrokes = state.strokesByPageKey[pageKey] ?? NO_STROKES;
  const undoSnapshots = state.undoSnapshotsByPageKey[pageKey] ?? [];
  return {
    ...state,
    strokesByPageKey: { ...state.strokesByPageKey, [pageKey]: nextStrokes },
    undoSnapshotsByPageKey: shouldRecordUndo
      ? { ...state.undoSnapshotsByPageKey, [pageKey]: [...undoSnapshots, previousStrokes] }
      : state.undoSnapshotsByPageKey,
  };
}

function reduceSolvingMemo(state: SolvingMemoState, action: SolvingMemoAction): SolvingMemoState {
  switch (action.type) {
    case "toggleMemoMode":
      return { ...state, isMemoMode: !state.isMemoMode };
    case "selectTool":
      return { ...state, selectedTool: action.tool };
    // 색 고름 > 펜으로 전환 (형광펜은 색 고정, 지우개는 색 없음)
    case "selectInk":
      return { ...state, selectedInk: action.ink, selectedTool: "pen" };
    case "addStroke":
      return replaceStrokes(state, action.pageKey, [...(state.strokesByPageKey[action.pageKey] ?? NO_STROKES), action.stroke], true);
    // 닿은 획 제거, 지운 게 없으면 그대로 (기록도 없음)
    case "erase": {
      const strokes = state.strokesByPageKey[action.pageKey] ?? NO_STROKES;
      const remainingStrokes = strokes.filter((stroke) => !isStrokeTouchedBy(stroke, action.point, action.radiusPixels));
      if (remainingStrokes.length === strokes.length) return state;
      const shouldRecordUndo = state.recordedEraseGestureId !== action.gestureId;
      return { ...replaceStrokes(state, action.pageKey, remainingStrokes, shouldRecordUndo), recordedEraseGestureId: action.gestureId };
    }
    case "undo": {
      const undoSnapshots = state.undoSnapshotsByPageKey[action.pageKey] ?? [];
      if (undoSnapshots.length === 0) return state;
      return {
        ...state,
        strokesByPageKey: { ...state.strokesByPageKey, [action.pageKey]: undoSnapshots[undoSnapshots.length - 1] },
        undoSnapshotsByPageKey: { ...state.undoSnapshotsByPageKey, [action.pageKey]: undoSnapshots.slice(0, -1) },
      };
    }
  }
}

export interface SolvingMemo {
  readonly isMemoMode: boolean;
  readonly selectedTool: SolvingMemoTool;
  readonly selectedInk: SolvingMemoInk;
  readonly strokesOf: (pageKey: string) => readonly SolvingMemoStroke[];
  readonly hasStrokesOn: (pageKey: string) => boolean;
  readonly canUndoOn: (pageKey: string) => boolean;
  readonly toggleMemoMode: () => void;
  readonly selectTool: (tool: SolvingMemoTool) => void;
  readonly selectInk: (ink: SolvingMemoInk) => void;
  readonly addStroke: (pageKey: string, stroke: SolvingMemoStroke) => void;
  readonly eraseStrokesTouchedBy: (pageKey: string, point: SolvingMemoPoint, radiusPixels: number, gestureId: number) => void;
  readonly undo: (pageKey: string) => void;
}

/**
 * 풀이 화면 메모 상태 (#904, 앱 PassqlMemoController 대응): 켬·끔, 도구·색, 문항별 획·되돌리기
 * 브라우저 메모리에만 (서버·저장소 저장 없음). 풀이 화면이 들고 있어 화면을 벗어나면 사라짐
 */
export function useSolvingMemo(): SolvingMemo {
  const [state, dispatch] = useReducer(reduceSolvingMemo, INITIAL_STATE);
  return useMemo(
    () => ({
      isMemoMode: state.isMemoMode,
      selectedTool: state.selectedTool,
      selectedInk: state.selectedInk,
      strokesOf: (pageKey) => state.strokesByPageKey[pageKey] ?? NO_STROKES,
      hasStrokesOn: (pageKey) => (state.strokesByPageKey[pageKey]?.length ?? 0) > 0,
      canUndoOn: (pageKey) => (state.undoSnapshotsByPageKey[pageKey]?.length ?? 0) > 0,
      toggleMemoMode: () => dispatch({ type: "toggleMemoMode" }),
      selectTool: (tool) => dispatch({ type: "selectTool", tool }),
      selectInk: (ink) => dispatch({ type: "selectInk", ink }),
      addStroke: (pageKey, stroke) => dispatch({ type: "addStroke", pageKey, stroke }),
      eraseStrokesTouchedBy: (pageKey, point, radiusPixels, gestureId) =>
        dispatch({ type: "erase", pageKey, point, radiusPixels, gestureId }),
      undo: (pageKey) => dispatch({ type: "undo", pageKey }),
    }),
    [state],
  );
}
