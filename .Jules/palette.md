## 2024-05-18 - Tooltips for Custom Icon Buttons
**Learning:** In Flutter, when building custom icon buttons with `GestureDetector` instead of `IconButton`, they lack both hover tooltips and accessibility labels by default. Wrapping them in `Tooltip` solves both issues simultaneously.
**Action:** Always wrap custom icon-only gesture detectors in `Tooltip` widgets to ensure accessibility and better desktop/web UX.
