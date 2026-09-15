## 2024-05-18 - Concurrent File Existence Check Optimization
**Learning:** Using `Future.wait()` on an iterable of futures, such as `File(path).exists()`, significantly speeds up IO bound tasks over sequential loops, by taking advantage of concurrency.
**Action:** Always favor `Future.wait()` to resolve multiple independent I/O futures over `await`ing sequentially inside a `for` loop.
