## 2024-05-18 - Concurrent File Existence Check Optimization
**Learning:** Using `Future.wait()` on an iterable of futures, such as `File(path).exists()`, significantly speeds up IO bound tasks over sequential loops, by taking advantage of concurrency.
**Action:** Always favor `Future.wait()` to resolve multiple independent I/O futures over `await`ing sequentially inside a `for` loop.

## 2024-05-30 - Optimized CustomPaint by adding RepaintBoundary
**Learning:** For static, complex `CustomPaint` shapes like background patterns, wrapping them in `RepaintBoundary` prevents unnecessary rasterization/repainting whenever sibling or parent widgets (like an overlapping loading animation) update their state.
**Action:** Always consider `RepaintBoundary` for expensive, static custom painters that sit behind frequently updating UI elements.
