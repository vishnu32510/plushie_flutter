## 2024-05-18 - Tooltips for Custom Icon Buttons
**Learning:** In Flutter, when building custom icon buttons with `GestureDetector` instead of `IconButton`, they lack both hover tooltips and accessibility labels by default. Wrapping them in `Tooltip` solves both issues simultaneously.
**Action:** Always wrap custom icon-only gesture detectors in `Tooltip` widgets to ensure accessibility and better desktop/web UX.

## 2024-05-24 - Improve Accessibility of Icon-Only Buttons
**Learning:** Icon-only buttons built with custom `GestureDetector` lack proper context for screen readers and tooltips on hover for desktop users.
**Action:** Wrap `GestureDetector`-based icon-only widgets (like `_CircleAction` in `plushie_result_card.dart`) in a `Tooltip` widget with a descriptive message to enhance clarity and accessibility.
