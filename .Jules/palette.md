## 2024-05-18 - Tooltips for Custom Icon Buttons
**Learning:** In Flutter, when building custom icon buttons with `GestureDetector` instead of `IconButton`, they lack both hover tooltips and accessibility labels by default. Wrapping them in `Tooltip` solves both issues simultaneously.
**Action:** Always wrap custom icon-only gesture detectors in `Tooltip` widgets to ensure accessibility and better desktop/web UX.

## 2024-05-24 - Improve Accessibility of Icon-Only Buttons
**Learning:** Icon-only buttons built with custom `GestureDetector` lack proper context for screen readers and tooltips on hover for desktop users.
**Action:** Wrap `GestureDetector`-based icon-only widgets (like `_CircleAction` in `plushie_result_card.dart`) in a `Tooltip` widget with a descriptive message to enhance clarity and accessibility.
## 2026-09-15 - Add Tooltips to Custom Icon Buttons
**Learning:** Found an icon-only `GestureDetector` acting as a close button on the `LoginScreen` without a tooltip, which means it lacked screen reader context and hover feedback.
**Action:** Always wrap custom icon-only gesture detectors (like close buttons) in `Tooltip` widgets to ensure accessibility and better desktop/web UX.
## 2024-10-25 - Improve Clarity of Image Upload Options
**Learning:** Having a large "Upload photo" button that opens a secondary sheet to choose between Gallery and Camera, while a secondary "Camera" button exists next to it, is redundant and increases cognitive load.
**Action:** When offering multiple distinct actions on a primary screen (e.g., choosing an image vs taking a photo), map primary buttons directly to specific actions instead of introducing intermediary selection dialogs when an alternative option is already presented visibly on the screen.
## 2026-09-17 - [Feature Discoverability] \n**Learning:** [Hidden interactions (like long-press to compare) need clear visual indicators or hints for users to discover them.] \n**Action:** [Always pair hidden gesture interactions with explicit visual cues or hint texts, especially when they represent a core feature of the UI.]
## 2026-09-18 - Add CTA to Empty State\n**Learning:** Empty states should not just inform but also guide the user to their next logical action to improve discoverability.\n**Action:** Add clear, actionable CTA buttons (e.g., 'Create a Plushie') to empty views to improve the user journey.
