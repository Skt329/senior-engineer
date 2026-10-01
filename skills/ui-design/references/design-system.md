# Design system and tokens

Tokens are named design decisions: color, type, spacing, radius, elevation, and motion. Components use tokens, never raw values, so the whole product stays consistent and themes such as dark mode come almost for free.

## Use what exists
If the repository has a design system, component library, or theme, use it exactly. Add a new token or component only when nothing fits, and follow the existing naming.

## Token layers
1. Primitives: the raw palette and scales (blue-600, space-4, font-size-16).
2. Semantic tokens: roles that components use (color-primary, color-surface, color-text-muted, color-danger, space-gap-md).
3. Component tokens, only where needed (button-padding-x).

Components reference semantic tokens. Themes (light and dark, or brands) remap the semantic tokens to different primitives.

## Scales
- Spacing: a 4 or 8 pixel base (4, 8, 12, 16, 24, 32, 48, 64).
- Type: a modular scale with a small set of sizes (for example 12, 14, 16, 20, 24, 32, 40), with line height around 1.4 to 1.6 for body text and 1.1 to 1.3 for headings. Body text at least 16 pixels on the web.
- Radius: two or three values used consistently.
- Elevation: a few levels, defined once.
- Motion: durations (fast about 150 ms, normal about 250 ms) and easing curves, defined once.

## Color roles
Define primary, secondary, surface, background, text (default and muted), border, and status colors (success, warning, danger, info), each with an "on" color for text on top, and check every pair for contrast (accessibility reference).

## Web implementation
CSS custom properties on :root, a dark theme override under a data-theme attribute or a prefers-color-scheme media query, and utility classes or component styles that reference the variables. In Tailwind, put the tokens in the theme configuration instead of using arbitrary values.

## Android implementation
A Material 3 theme: ColorScheme with light and dark variants (and dynamic color where allowed), Typography from the type scale, and Shapes. Use MaterialTheme values in composables instead of literals, and extend the theme with a CompositionLocal for custom tokens such as spacing.

## Components
Every component defines its variants, sizes, and states (default, hover, focus, pressed, disabled, loading, error), its accessibility behavior, and usage notes saying when to use it and when not to.
