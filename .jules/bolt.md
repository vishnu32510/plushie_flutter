## 2024-09-14 - Optimize Image Decoding Memory for Thumbnails
**Learning:** Loading full-resolution files (like 12MP camera photos or 1024x1024 generated PNGs) into small containers (e.g., 60x60 bottom bar preview, or 3-column GridView) causes Flutter to decode the full image into memory, leading to massive RAM usage and potential UI jank.
**Action:** Use `cacheWidth` or `cacheHeight` on `Image.file()`, `Image.asset()`, and `Image.network()` to force the engine to decode the image at a smaller resolution, drastically reducing the memory footprint for thumbnails.
