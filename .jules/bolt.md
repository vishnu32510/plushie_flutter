## 2024-05-18 - Concurrent File Existence Check Optimization
**Learning:** Using `Future.wait()` on an iterable of futures, such as `File(path).exists()`, significantly speeds up IO bound tasks over sequential loops, by taking advantage of concurrency.
**Action:** Always favor `Future.wait()` to resolve multiple independent I/O futures over `await`ing sequentially inside a `for` loop.

## 2024-05-30 - Optimized CustomPaint by adding RepaintBoundary
**Learning:** For static, complex `CustomPaint` shapes like background patterns, wrapping them in `RepaintBoundary` prevents unnecessary rasterization/repainting whenever sibling or parent widgets (like an overlapping loading animation) update their state.
**Action:** Always consider `RepaintBoundary` for expensive, static custom painters that sit behind frequently updating UI elements.

## 2026-09-17 - Memory footprint optimization for raw user images
**Learning:** Loading unrestricted user-provided images via `Image.memory` or `Image.file` without `cacheWidth` or `cacheHeight` is a significant memory hazard in Flutter that can consume massive amounts of RAM (e.g. 50MB for a 12MP camera photo) and cause OOM crashes or jank.
**Action:** Always specify `cacheWidth` or `cacheHeight` (e.g. `cacheWidth: 900`) when decoding potentially large user-provided images to downsample them during decode and drastically reduce memory footprint (~3MB).
