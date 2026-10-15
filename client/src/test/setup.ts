import "@testing-library/jest-dom/vitest";

// Node 25+ 내장 localStorage(저장 파일 미지정 시 undefined)가 jsdom 저장소를 가림 > 메모리 저장소로 대체
if (typeof globalThis.localStorage?.getItem !== "function") {
  const storedValueByKey = new Map<string, string>();
  const memoryStorage: Storage = {
    get length() { return storedValueByKey.size; },
    clear: () => storedValueByKey.clear(),
    getItem: (key) => storedValueByKey.get(key) ?? null,
    key: (index) => [...storedValueByKey.keys()][index] ?? null,
    removeItem: (key) => { storedValueByKey.delete(key); },
    setItem: (key, value) => { storedValueByKey.set(key, String(value)); },
  };
  Object.defineProperty(globalThis, "localStorage", { value: memoryStorage, configurable: true });
}
