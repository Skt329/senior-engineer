# Accessibility (WCAG 2.1 AA)

## Perceivable
- Text contrast at least 4.5:1 (3:1 for text 24 pixels and larger, or 19 pixels bold). Icons and control borders at least 3:1 against what is next to them.
- Never use color alone to carry meaning; add text, an icon, or a pattern.
- Every meaningful image has alternative text; decorative images are hidden from screen readers.
- Text can be resized to 200 percent without breaking the layout.
- Videos have captions.

## Operable
- Everything works with a keyboard alone, in a logical tab order, with no keyboard traps.
- Focus is always visible, with a clear focus ring.
- Touch targets are at least 44 by 44 CSS pixels on the web (Android: 48 by 48 dp), with spacing between them.
- Nothing flashes more than three times per second.
- Time limits can be extended, and moving content can be paused.

## Understandable
- Every input has a visible label (placeholders are not labels).
- Errors say what went wrong and how to fix it, next to the field, and are announced to screen readers.
- Navigation and naming are consistent across screens.
- The page language is set.

## Robust
- Semantic HTML first: button, a, nav, main, header, label, and real headings in order.
- ARIA only where HTML has no native element, and ARIA states (aria-expanded, aria-invalid) kept in sync with the UI.
- Status messages use live regions so screen readers announce them.

## Android specifics
- contentDescription on meaningful icons and images; null for decorative ones.
- In Compose, use semantics modifiers for custom controls, and mergeDescendants where a row reads as one item.
- Support the system font scale and display size; avoid fixed heights for text containers.
- Check new screens with TalkBack and the Accessibility Scanner app.

## Testing
- Automated: axe (web) or Accessibility Scanner (Android) on key screens. Automated tools find about a third of issues.
- Manual: navigate with the keyboard only, use a screen reader (NVDA on Windows, VoiceOver, TalkBack), and zoom to 200 percent.
